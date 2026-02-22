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

  def work_page_title(work, title, options = {})
    fandoms = work.fandoms
    title_fandom = if fandoms.empty?
                     t("works_helper.work_page_title.unspecified_fandom")
                   elsif fandoms.size > 3
                     t("works_helper.work_page_title.multifandom")
                   else
                     fandoms.first.name
                   end
    author = work.anonymous? ? t("works_helper.work_page_title.anonymous") : work.pseuds.sort.collect(&:byline).join(t("support.array.words_connector"))

    get_page_title(title_fandom, author, title, options)
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

  def mark_as_read_button(work)
    button_to t("works_helper.mark_as_read_button"), mark_as_read_work_path(work), method: :patch
  end

  def mark_for_later_button(work)
    button_to t("works_helper.mark_for_later_button"), mark_for_later_work_path(work), method: :patch
  end

  def get_endnotes_link(work)
    return "#work_endnotes" unless current_page?({ controller: "chapters", action: "show" })

    if work.posted? && work.last_posted_chapter
      chapter_path(work.last_posted_chapter.id, anchor: "work_endnotes")
    else
      chapter_path(work.last_chapter.id, anchor: "work_endnotes")
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
    text = +"<p>by #{byline(work, { visibility: 'public', full_path: true })}</p>"
    text << work.summary if work.summary
    text << "<p>Words: #{work.word_count}, Chapters: #{chapter_total_display(work)}, Language: #{work.language ? work.language.name : 'English'}</p>"
    text << "<p>Series: #{series_list_with_work_position(work)}</p>" unless work.series.count.zero?
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

  # Returns an Open Graph title for a work.
  #
  # Twitter/X seems to have the lowest character limit, with 70 characters listed on
  # https://developer.x.com/en/docs/x-for-websites/cards/overview/markup.
  def og_title_meta(work)
    full_byline = "#{work.title} by #{text_byline(work, visibility: 'public')}"

    # Avoid truncation of creator names.
    return full_byline if full_byline.length <= 70

    "#{text_byline(work, visibility: 'public')}: #{work.title}"
  end

  # Returns an Open Graph description for a work.
  def og_description_meta(work)
    return strip_tags(work.summary) if work.summary.present?

    description = work.fandom_string
    description << ", #{work.relationship_string}" if work.relationship_string.present?
    description << ", #{work.character_string}" if work.character_string.present?
    description
  end

  # Returns an Open Graph image URL for a work.
  #
  # Only image/jpeg, image/gif or image/png are accepted by Facebook.
  # https://developers.facebook.com/docs/sharing/webmasters/#images
  def og_image_url_meta(work)
    tag_groups = work.tag_groups

    symbol_block = []
    ratings = tag_groups["Rating"]
    symbol_block << get_rating_type(ratings)
    warnings = tag_groups["ArchiveWarning"]
    symbol_block << get_warning_type(warnings)
    categories = tag_groups["Category"]
    symbol_block << get_category_type(categories)
    completion_status = work.complete? ? "complete" : "incomplete"
    symbol_block << completion_status

    # TODO: Add remaining images
    "#{root_url}images/work_symbols/#{symbol_block.join('-')}.png"
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

  private

  def get_rating_type(rating_tags = [])
    if rating_tags.blank?
      "notrated"
    else
      names = rating_tags.collect(&:name)
      if names.include?(ArchiveConfig.RATING_EXPLICIT_TAG_NAME)
        "explicit"
      elsif names.include?(ArchiveConfig.RATING_MATURE_TAG_NAME)
        "mature"
      elsif names.include?(ArchiveConfig.RATING_TEEN_TAG_NAME)
        "teen"
      elsif names.include?(ArchiveConfig.RATING_GENERAL_TAG_NAME)
        "generalaudience"
      else
        "notrated"
      end
    end
  end

  def get_warning_type(warning_tags = [])
    return "choosenottowarn" if warning_tags.blank?

    warning_tag_names = warning_tags.map(&:name)
    if warning_tag_names == [ArchiveConfig.WARNING_NONE_TAG_NAME]
      # only one tag and it says "no"
      "nowarning"
    elsif warning_tag_names == [ArchiveConfig.WARNING_DEFAULT_TAG_NAME]
      # only one tag and it says choose not to warn
      "choosenottowarn"
    elsif warning_tag_names.sort == [ArchiveConfig.WARNING_DEFAULT_TAG_NAME, ArchiveConfig.WARNING_NONE_TAG_NAME].sort
      # two tags and they are "choose not to warn" and "no archive warnings apply" in either order
      "choosenottowarn"
    else
      "warning"
    end
  end

  def get_category_type(category_tags)
    return "nocategory" if category_tags.blank?

    if category_tags.length > 1
      "multi"
    else
      case category_tags.first.name
      when ArchiveConfig.CATEGORY_GEN_TAG_NAME
        "gen"
      when ArchiveConfig.CATEGORY_SLASH_TAG_NAME
        "slash"
      when ArchiveConfig.CATEGORY_HET_TAG_NAME
        "het"
      when ArchiveConfig.CATEGORY_FEMSLASH_TAG_NAME
        "femslash"
      when ArchiveConfig.CATEGORY_MULTI_TAG_NAME
        "multi"
      when ArchiveConfig.CATEGORY_OTHER_TAG_NAME
        "other"
      else
        "nocategory"
      end
    end
  end
end
