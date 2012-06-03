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

  # Return true or false to determine whether the published at field should show on the work form
  def check_backdate_box(work, chapter)

    return true if work.backdate

    if !chapter.created_at.nil?
      # A draft or posted work already exists
      return chapter.created_at.to_date != chapter.published_at
    elsif !chapter.published_at.nil?
      # There's data from the input form but the work that hasn't been
      # stored as a draft yet
      return chapter.published_at != Date.today
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

  private
  def add_label_for_embed(label, text) ; text.blank? ? nil : label + text ; end

  public
  # get a nicely formatted bit of text for pasting into other services
  # title (# words) by authors
  # Chapters: 
  # Fandom:
  # Rating:
  # Warnings:
  # etc
  def get_embed_link(work)
    title_link = link_to(content_tag(:strong, work.title.html_safe), work_url(work)) + " (#{work.word_count} #{ts('words')})"
    if work.anonymous?
      profile_link = ts("Anonymous")
    else
      profile_link = work.pseuds.map {|pseud| link_to(image_tag(root_url + "favicon.ico", :alt => "favicon", :border => "0"), user_profile_url(pseud.user)) +
                                    link_to(content_tag(:strong, pseud.name), user_url(pseud.user))}.join(', ').html_safe
    end

    chapters_text = ts("Chapters: ") + work.chapter_total_display
    fandom_text = add_label_for_embed(ts("Fandom: "), work.fandoms.map {|fandom| link_to fandom.name, tag_url(fandom)}.join(', ').html_safe)
    rating_text = add_label_for_embed(ts("Rating: "), work.ratings.map {|rating| rating.name}.join(', '))
    category_text = add_label_for_embed(ts("Category: "), work.categories.map {|cat| cat.name}.join(', '))
    warning_text = add_label_for_embed(ts("Warning: "), work.warnings.map {|warning| warning_display_name(warning.name)}.join(', '))
    relationship_text = add_label_for_embed(ts("Relationships: "), work.relationships.map {|rel| rel.name}.join(', '))
    char_text = add_label_for_embed(ts("Characters: "), work.characters.map {|char| char.name}.join(', '))
    summary_text = add_label_for_embed(ts("Summary: "), sanitize_field(work, :summary))

    # we deliberately don't html_safe this because we want it escaped
    [title_link + ts(" by ") + profile_link, chapters_text, fandom_text, rating_text, warning_text, relationship_text, char_text, summary_text].compact.join("\n")
  end

  # convert a bookmark into a nicely formatted chunk of text
  def get_bookmark_embed_link(bookmark)
    if bookmark.bookmarkable.is_a?(Work)
      work_embed = get_embed_link(bookmark.bookmarkable)
      tags_text = add_label_for_embed(ts("Bookmarker's Tags: "), bookmark.tags.map {|tag| tag.name}.join(", "))
      bookmark_text = add_label_for_embed(content_tag(:strong, ts("Bookmarker's Notes: ")), raw(sanitize_field(bookmark, :notes)))
      [work_embed, tags_text, bookmark_text].compact.join("\n")
    end
  end
  
  def get_endnotes_link
    current_page?(:controller => 'chapters', :action => 'show') ?
      chapter_path(@work.last_chapter.id, :anchor => 'work_endnotes') :
      "#work_endnotes"
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


