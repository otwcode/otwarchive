module WorksHelper

  # List of date, chapter and length info for the work show page
  def work_meta_list(work, chapter = nil)
    # if we're previewing, grab the unsaved date, else take the saved first chapter date
    published_date = (chapter && work.preview_mode) ? chapter.published_at : work.first_chapter.published_at
    list = [[ts('Published:'), 'published', localize(published_date)],
            [ts('Words:'), 'words', work.word_count],
            [ts('Chapters:'), 'chapters', work.chapter_total_display]]

    if (comment_count = work.count_visible_comments) > 0
      list.concat([[ts('Comments:'), 'comments', work.count_visible_comments.to_s]])
    end

    if work.all_kudos_count > 0
      list.concat([[ts('Kudos:'), 'kudos', work.all_kudos_count.to_s]])
    end

    if (bookmark_count = work.public_bookmarks_count) > 0
      list.concat([[ts('Bookmarks:'), 'bookmarks', link_to(bookmark_count.to_s, work_bookmarks_path(work))]])
    end
    list.concat([[ts('Hits:'), 'hits', work.hits]]) if show_hit_count?(work)

    if work.chaptered? && work.revised_at
      prefix = work.is_wip ? ts('Updated:') : ts('Completed:')
      latest_date = (work.preview_mode && work.backdate) ? published_date : date_in_user_time_zone(work.revised_at).to_date
      list.insert(1, [prefix, 'status', localize(latest_date)])
    end
    list = list.map { |list_item| content_tag(:dt, list_item.first, class: list_item.second) + content_tag(:dd, list_item.last.to_s, class: list_item.second) }.join.html_safe
    content_tag(:dl, list.to_s, class: 'stats').html_safe
  end

  def show_hit_count?(work)
    return false if logged_in? && current_user.preference.try(:hide_all_hit_counts)
    author_wants_to_see_hits = is_author_of?(work) && !current_user.preference.try(:hide_private_hit_count)
    all_authors_want_public_hits = work.users.select { |u| u.preference.try(:hide_public_hit_count) }.empty?
    author_wants_to_see_hits || (!is_author_of?(work) && all_authors_want_public_hits)
  end

  def show_hit_count_to_public?(work)
    !Preference.where(user_id: work.pseuds.pluck(:user_id), hide_public_hit_count: true).exists?
  end

  def recipients_link(work)
    # join doesn't maintain html_safe, so mark the join safe
    work.gifts.not_rejected.includes(:pseud).map { |gift| link_to(h(gift.recipient), gift.pseud ? user_gifts_path(gift.pseud.user) : gifts_path(recipient: gift.recipient_name)) }.join(", ").html_safe
  end

  # select the default warning if this is a new work
  def check_archive_warning(work, warning)
    if work.nil? || work.archive_warning_strings.empty?
      warning.name == nil
    else
      work.archive_warning_strings.include?(warning.name)
    end
  end

  # select default rating if this is a new work
  def rating_selected(work)
    work.nil? || work.rating_string.empty? ? ArchiveConfig.RATING_DEFAULT_TAG_NAME : work.rating_string
  end

  # Determines whether or not to expand the related work association fields when the work form loads
  def check_parent_box(work)
    !work.parents.blank? ||
    (params[:work] && !(work_parent_value(:url).blank? && work_parent_value(:title).blank? && work_parent_value(:author).blank?))
  end

  # Passes value of fields for related works back to form when an error occurs on posting
  def work_parent_value(field)
    if params[:work] && params[:work][:parent_attributes]
      params[:work][:parent_attributes][field]
    end
  end

  # Passes value of series ID back to form when an error occurs on posting.
  # Thanks to the way that series_attributes= is defined, series are saved
  # and added to the work even before the work is saved. The only time that the
  # series isn't added is when the work is a new record, and therefore the
  # SerialWork can't be created.
  def work_series_id(work)
    if work.new_record? && (series = work.series.first)
      series.id
    end
  end

  def language_link(work)
    if work.respond_to?(:language) && work.language
      link_to work.language.name, work.language
    else
      "N/A"
    end
  end

  # Check whether this user has permission to view this work even if it's
  # unrevealed and they're not listed as a creator:
  def can_see_work(work, user)
    # Invited co-creators can also see unrevealed works, even though they're
    # not officially listed as creators (because creators are allowed to edit,
    # and invited co-creators aren't):
    if work.user_has_creator_invite?(current_user)
      return true
    end

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
    if current_page?(controller: 'chapters', action: 'show')
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
    current_page?(controller: 'chapters', action: 'show') ?
      chapter_path(@work.last_posted_chapter.id, anchor: 'children') :
      "#children"
  end

  def get_inspired_by(work)
    work.approved_related_works.where(translation: false)
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
    text << "<p>Words: #{work.word_count}, Chapters: #{work.chapter_total_display}, Language: #{work.language ? work.language.name : 'English'}</p>"
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
    work.parent_work_relationships.present? ||
    work.approved_related_works.present?
  end

  # Returns true or false to determine whether the work associations should be included
  def show_associations?(work)
    work.gifts.not_rejected.present? ||
    work.approved_related_works.where(translation: true).exists? ||
    work.parent_work_relationships.exists? ||
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
end
