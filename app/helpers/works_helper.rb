module WorksHelper

  # List of date, chapter and length info for the work show page
  def work_meta_list(work, chapter=nil)
    # if we're previewing, grab the unsaved date, else take the saved first chapter date
    published_date = (chapter && work.preview_mode) ? chapter.published_at : work.first_chapter.published_at
    list = [[ts("Published:"), localize(published_date)],
            [ts("Words:"), work.word_count],
            [ts("Chapters:"), work.chapter_total_display]]

    if (comment_count = work.count_visible_comments) > 0
      list.concat([[ts('Comments:'), work.count_visible_comments.to_s]])
    end

    if work.all_kudos_count > 0
      list.concat([[ts('Kudos:'), work.all_kudos_count.to_s]])
    end

    if (bookmark_count = work.bookmarks.is_public.count) > 0
      list.concat([[ts('Bookmarks:'), link_to(bookmark_count.to_s, work_bookmarks_path(work))]])
    end
    list.concat([[ts("Hits:"), work.hits]]) if show_hit_count?(work)

    if work.chaptered? && work.revised_at
      prefix = work.is_wip ? ts("Updated:") : ts("Completed:")
      latest_date = (work.preview_mode && work.backdate) ? published_date : date_in_user_time_zone(work.revised_at).to_date
      list.insert(1, [prefix, localize(latest_date)])
    end
    list = list.map {|list_item| content_tag(:dt, list_item.first) + content_tag(:dd, list_item.last.to_s)}.join.html_safe
    content_tag(:dl, list.to_s, :class => "stats").html_safe
  end

  def show_hit_count?(work)
    return false if logged_in? && current_user.preference.try(:hide_all_hit_counts)
    author_wants_to_see_hits = is_author_of?(work) && !current_user.preference.try(:hide_private_hit_count)
    all_authors_want_public_hits = work.users.select {|u| u.preference.try(:hide_public_hit_count)}.empty?
    author_wants_to_see_hits || (!is_author_of?(work) && all_authors_want_public_hits)
  end
  
  def show_hit_count_to_public?(work)
    !Preference.where(:user_id => work.pseuds.value_of(:user_id), :hide_public_hit_count => true).exists?
  end

  def recipients_link(work)
    # join doesn't maintain html_safe, so mark the join safe
    work.gifts.map {|gift| link_to(h(gift.recipient), gift.pseud ? user_gifts_path(gift.pseud.user) : gifts_path(:recipient => gift.recipient_name))}.join(", ").html_safe
  end

  # select the default warning if this is a new work
  def check_warning(work, warning)
    if work.nil? || work.warning_strings.empty?
      warning.name == ArchiveConfig.WARNING_DEFAULT_TAG_NAME
    else
      work.warning_strings.include?(warning.name)
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

  def language_link(work)
    if work.respond_to?(:language) && work.language
      link_to work.language.name, work.language
    else
      "N/A"
    end
  end

  def can_see_work(work, user)
    unless work.collections.empty?
      for collection in work.collections
        return true if collection.user_is_maintainer?(user)
      end
    end
    false
  end

  def marked_for_later?(work)
    return unless current_user
    reading = Reading.find_by_work_id_and_user_id(work.id, current_user.id)
    reading && reading.toread?
  end
  
  def marktoread_link(work)
    link_to ts("Mark for later"), marktoread_work_path(work)
  end
  
  def markasread_link(work)
    link_to ts("Mark as read"), marktoread_work_path(work)
  end
  
  def get_endnotes_link
    current_page?(:controller => 'chapters', :action => 'show') ?
      chapter_path(@work.last_chapter.id, :anchor => 'work_endnotes') :
      "#work_endnotes"
  end
  
  def get_related_works_url
    current_page?(:controller => 'chapters', :action => 'show') ?
      chapter_path(@work.last_chapter.id, :anchor => 'children') :
      "#children"
  end
  
  def get_inspired_by(work)
    work.approved_related_works.where(translation: false)
  end

  def download_url_for_work(work, format)
    url_for ("/#{work.download_folder}/#{work.download_title}.#{format}").gsub(' ', '%20')
  end
  
  # Generates a list of a work's tags and details for use in feeds
  def feed_summary(work)
    tags = work.tags.group_by(&:type)
    text = "<p>by #{byline(work, :visibility => 'public')}</p>"
    text << work.summary if work.summary
    text << "<p>Words: #{work.word_count}, Chapters: #{work.chapter_total_display}, Language: #{work.language ? work.language.name : 'English'}</p>"
    unless work.series.count == 0
      text << "<p>Series: #{series_list_for_feeds(work)}</p>"
    end
    # Create list of tags
    text << "<ul>"
    %w(Fandom Rating Warning Category Character Relationship Freeform).each do |type|
      if tags[type]
        label = case type
        when 'Freeform'
          'Additional Tags'
        when 'Rating'
          'Rating'
        else
          type.pluralize
        end
        text << "<li>#{label}: #{tags[type].map{ |t| link_to_tag_works(t) }.join(', ')}</li>"
      end
    end
    text << "</ul>"
    text
  end

  # Returns true or false to determine whether the work notes module should display
  def show_work_notes?(work)
    work.notes.present? ||
    work.endnotes.present? ||
    work.recipients.present? ||
    work.challenge_claims.present? ||
    work.parent_work_relationships.present? ||
    work.approved_related_works.present?
  end
    
  
end


