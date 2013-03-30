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
    work.recipients.split(',').map {|name| link_to(h(name), gifts_path(:recipient => name))}.join(", ").html_safe
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

  private
  def add_label_for_embed(label, text, tag='') ; text.blank? ? nil : label + text + tag; end

  public
  # get a nicely formatted bit of text for pasting into other services
  # title (# words) by authors
  # Chapters: 
  # Fandom:
  # Rating:
  # Warnings:
  # etc
  
  # get work title, word count, and creator and add formatting for share code
  def get_embed_link_title(work)
    title_link = link_to(content_tag(:strong, work.title.html_safe), work_url(work)) + " (#{work.word_count} #{ts('words')})"
    if work.anonymous?
      profile_link = ts("Anonymous")
    else
      profile_link = work.pseuds.map {|pseud| link_to(content_tag(:strong, pseud.name), user_url(pseud.user))}.join(', ').html_safe
    end 
    title_link + ts(" by ") + profile_link
  end
  
  # get work information for share code
  def get_embed_link_meta(work)
    chapters_text = ts("Chapters: ") + work.chapter_total_display + tag("br")
    fandom_text = add_label_for_embed(ts("Fandom: "), work.fandoms.map {|fandom| link_to fandom.name, tag_url(fandom)}.join(', ').html_safe, tag("br"))
    rating_text = add_label_for_embed(ts("Rating: "), work.ratings.map {|rating| rating.name}.join(', '), tag("br"))
    category_text = add_label_for_embed(ts("Category: "), work.categories.map {|cat| cat.name}.join(', '), tag("br"))
    warning_text = add_label_for_embed(ts("Warnings: "), work.warnings.map {|warning| warning_display_name(warning.name)}.join(', '), tag("br"))
    relationship_text = add_label_for_embed(ts("Relationships: "), work.relationships.map {|rel| rel.name}.join(', '), tag("br"))
    char_text = add_label_for_embed(ts("Characters: "), work.characters.map {|char| char.name}.join(', '), tag("br"))
    tags_text = add_label_for_embed(ts("Additional Tags: "), work.freeforms.map {|freeform| freeform.name}.join(', '), tag("br"))
    if work.series.count != 0
      series_text = add_label_for_embed(ts("Series: "), series_list_for_feeds(work), tag("br"))
    end
    summary_text = add_label_for_embed(ts("Summary: "), sanitize_field(work, :summary))
    
    if work.series.count != 0
      [chapters_text, fandom_text, rating_text, warning_text, relationship_text, char_text, tags_text, series_text, summary_text].compact.join("")
    else
      [chapters_text, fandom_text, rating_text, warning_text, relationship_text, char_text, tags_text, summary_text].compact.join("")
    end   
  end
  
  # combine title, word count, creator, and meta to make copy and paste share code for a work
  def get_embed_link(work)
    [get_embed_link_title(work) + tag("br"), get_embed_link_meta(work)].compact.join("")
  end

  # get bookmark information for share code
  def get_embed_link_bookmark_meta(bookmark)
    if bookmark.bookmarkable.is_a?(Work)
      tags_text = add_label_for_embed(ts("Bookmarker's Tags: "), bookmark.tags.map {|tag| tag.name}.join(", "), tag("br"))
      bookmark_text = add_label_for_embed(ts("Bookmarker's Notes: "), raw(sanitize_field(bookmark, :notes)))
    end
  end

  # combine full copy and paste share code for a work with bookmark information to make copy and paste share code for a bookmark
  def get_bookmark_embed_link(bookmark)
    if bookmark.bookmarkable.is_a?(Work)
      work_embed = get_embed_link(bookmark.bookmarkable)
      bookmark_meta = get_embed_link_bookmark_meta(bookmark)
      [work_embed, bookmark_meta].compact.join("")
    end
  end
  
  # get work title, word count, and creator and add app short name, but do not add formatting so it can be link text for Tumblr sharing
  def get_tumblr_embed_link_title(work)
    title = work.title + " (#{work.word_count} #{ts('words')})".html_safe
    if work.anonymous?
      pseud = ts("Anonymous")
    else
      pseud = work.pseuds.map {|pseud| (pseud.name)}.join(', ').html_safe
    end
    title + ts(" by ") + pseud + ts(" [#{ArchiveConfig.APP_SHORT_NAME}]")
  end
  
  # combine work information and bookmark information to make body of link post for Tumblr sharing
  def get_tumblr_bookmark_embed_link(bookmark)
    if bookmark.bookmarkable.is_a?(Work)
      work_meta = get_embed_link_meta(bookmark.bookmarkable)
      bookmark_meta = get_embed_link_bookmark_meta(bookmark)
      [work_meta, bookmark_meta].compact.join("")
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

  def tweet_text(work)
    if work.unrevealed?
      ts("Mystery Work")
    else
      names = work.anonymous? ? ts("Anonymous") : work.pseuds.map(&:name).join(', ')
      fandoms = work.fandoms.size > 2 ? ts("Multifandom") : work.fandoms.string
      "#{work.title} by #{names} - #{fandoms}".truncate(95)
    end
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


