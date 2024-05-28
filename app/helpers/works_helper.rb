module WorksHelper

  # List of date, chapter and length info for the work show page
  def work_meta_list(work, chapter = nil)
    # if we're previewing, grab the unsaved date, else take the saved first chapter date
    published_date = (chapter && work.preview_mode) ? chapter.published_at : work.first_chapter.published_at
    list = [[ts("Published:"), "published", localize(published_date)],
            [ts("Words:"), "words", number_with_delimiter(work.word_count)],
            [ts("Chapters:"), "chapters", chapter_total_display(work)]]

    if (comment_count = work.count_visible_comments) > 0
      list.concat([[ts("Comments:"), "comments", number_with_delimiter(work.count_visible_comments)]])
    end

    if work.all_kudos_count > 0
      list.concat([[ts("Kudos:"), "kudos", number_with_delimiter(work.all_kudos_count)]])
    end

    if (bookmark_count = work.public_bookmarks_count) > 0
      list.concat([[ts("Bookmarks:"), "bookmarks", link_to(number_with_delimiter(bookmark_count), work_bookmarks_path(work))]])
    end
    list.concat([[ts("Hits:"), "hits", number_with_delimiter(work.hits)]])

    if work.chaptered? && work.revised_at
      prefix = work.is_wip ? ts('Updated:') : ts('Completed:')
      latest_date = (work.preview_mode && work.backdate) ? published_date : date_in_user_time_zone(work.revised_at).to_date
      list.insert(1, [prefix, 'status', localize(latest_date)])
    end
    list = list.map { |list_item| content_tag(:dt, list_item.first, class: list_item.second) + content_tag(:dd, list_item.last.to_s, class: list_item.second) }.join.html_safe
    content_tag(:dl, list.to_s, class: 'stats').html_safe
  end

  def recipients_link(work)
    # join doesn't maintain html_safe, so mark the join safe
    work.gifts.not_rejected.includes(:pseud).map { |gift| link_to(h(gift.recipient), gift.pseud ? user_gifts_path(gift.pseud.user) : gifts_path(recipient: gift.recipient_name)) }.join(", ").html_safe
  end

  # select default rating if this is a new work
  def rating_selected(work)
    work.nil? || work.rating_string.empty? ? ArchiveConfig.RATING_DEFAULT_TAG_NAME : work.rating_string
  end

  # Determines whether or not to expand the related work association fields when the work form loads
  def check_parent_box(work)
    work.parents_after_saving.present?
  end

  # Determines whether or not "manage series" dropdown should appear
  def check_series_box(work)
    work.series.present? || work_series_value(:id).present? || work_series_value(:title).present?
  end

  # Passes value of fields for work series back to form when an error occurs on posting
  def work_series_value(field)
    params.dig :work, :series_attributes, field
  end

  def language_link(work)
    if work.respond_to?(:language) && work.language
      link_to work.language.name, work.language, lang: work.language.short
    else
      "N/A"
    end
  end

  # Check whether this non-admin user has permission to view the unrevealed work
  def can_access_unrevealed_work(work, user)
    # Creators and invited can see their works
    return true if work.user_is_owner_or_invited?(user)

    # Moderators can see unrevealed works:
    work.collections.each do |collection|
      return true if collection.user_is_maintainer?(user)
    end

    false
  end

  def marked_for_later?(work)
    return unless current_user
    reading = Reading.find_by(work_id: work.id, user_id: current_user.id)
    reading && reading.toread?
  end

  def mark_as_read_link(work)
    link_to ts("Mark as Read"), mark_as_read_work_path(work)
  end

  def mark_for_later_link(work)
    link_to ts("Mark for Later"), mark_for_later_work_path(work)
  end

  def get_endnotes_link
    if current_page?({ controller: "chapters", action: "show" })
      if @work.posted?
        chapter_path(@work.last_posted_chapter.id, anchor: 'work_endnotes')
      else
        chapter_path(@work.last_chapter.id, anchor: 'work_endnotes')
      end
    else
      "#work_endnotes"
    end
  end

  def get_related_works_url
    current_page?({ controller: "chapters", action: "show" }) ?
      chapter_path(@work.last_posted_chapter.id, anchor: 'children') :
      "#children"
  end

  def get_inspired_by(work)
    work.approved_related_works.where(translation: false)
  end

  def related_work_note(related_work, relation, download: false)
    work_link = link_to related_work.title, polymorphic_url(related_work)
    language = tag.span(related_work.language.name, lang: related_work.language.short) if related_work.language
    default_locale = download ? :en : nil

    creator_link = if download
                     byline(related_work, visibility: "public", only_path: false)
                   else
                     byline(related_work)
                   end

    if related_work.respond_to?(:unrevealed?) && related_work.unrevealed?
      if relation == "translated_to"
        t(".#{relation}.unrevealed_html",
          language: language)
      else
        t(".#{relation}.unrevealed",
          locale: default_locale)
      end
    elsif related_work.restricted? && (download || !logged_in?)
      t(".#{relation}.restricted_html",
        language: language,
        locale: default_locale,
        creator_link: creator_link)
    else
      t(".#{relation}.revealed_html",
        language: language,
        locale: default_locale,
        work_link: work_link,
        creator_link: creator_link)
    end
  end

  # Can the work be downloaded, i.e. is it posted and visible to all registered
  # users.
  def downloadable?
    @work.posted? && !@work.hidden_by_admin && !@work.in_unrevealed_collection?
  end

  def download_url_for_work(work, format)
    path = Download.new(work, format: format).public_path
    url_for("#{path}?updated_at=#{work.updated_at.to_i}").gsub(' ', '%20')
  end

  # Generates a list of a work's tags and details for use in feeds
  def feed_summary(work)
    tags = work.tags.group_by(&:type)
    text = "<p>by #{byline(work, { visibility: 'public', full_path: true })}</p>"
    text << work.summary if work.summary
    text << "<p>Words: #{work.word_count}, Chapters: #{chapter_total_display(work)}, Language: #{work.language ? work.language.name : 'English'}</p>"
    unless work.series.count == 0
      text << "<p>Series: #{series_list_for_feeds(work)}</p>"
    end
    # Create list of tags
    text << "<ul>"
    %w(Fandom Rating ArchiveWarning Category Character Relationship Freeform).each do |type|
      if tags[type]
        text << "<li>#{type.constantize.label_name}: #{tags[type].map { |t| link_to_tag_works(t, full_path: true) }.join(', ')}</li>"
      end
    end
    text << "</ul>"
    text
  end

  # Returns true or false to determine whether the work notes module should display
  def show_work_notes?(work)
    work.notes.present? ||
      work.endnotes.present? ||
      work.gifts.not_rejected.present? ||
      work.challenge_claims.present? ||
      work.parents_after_saving.present? ||
      work.approved_related_works.present?
  end

  # Returns true or false to determine whether the work associations should be included
  def show_associations?(work)
    work.gifts.not_rejected.present? ||
      work.approved_related_works.where(translation: true).exists? ||
      work.parents_after_saving.present? ||
      work.challenge_claims.present?
  end

  def all_coauthor_skins
    users = @work.users.to_a
    users << User.current_user if User.current_user.is_a?(User)
    WorkSkin.approved_or_owned_by_any(users).order(:title)
  end

  def sorted_languages
    Language.default_order
  end

  # 1/1, 2/3, 5/?, etc.
  def chapter_total_display(work)
    current = work.posted? ? work.number_of_posted_chapters : 1
    number_with_delimiter(current) + "/" + number_with_delimiter(work.wip_length)
  end

  # For works that are more than 1 chapter, returns "current #/expected #" of chapters
  # (e.g. 3/5, 2/?), with the current # linked to that chapter. If the work is 1 chapter,
  # returns the un-linked version.
  def chapter_total_display_with_link(work)
    total_posted_chapters = work.number_of_posted_chapters
    if total_posted_chapters > 1
      link_to(number_with_delimiter(total_posted_chapters),
              work_chapter_path(work, work.last_posted_chapter.id)) +
        "/" +
        number_with_delimiter(work.wip_length)
    else
      chapter_total_display(work)
    end
  end

  def get_open_assignments(user)
    offer_signups = user.offer_assignments.undefaulted.unstarted.sent
    pinch_hits = user.pinch_hit_assignments.undefaulted.unstarted.sent

    (offer_signups + pinch_hits)
  end
end
