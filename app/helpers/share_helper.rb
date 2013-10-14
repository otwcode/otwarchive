module ShareHelper

  private
    def add_label_for_embed(label, text, tag='') ; text.blank? ? nil : label + text + tag; end

  public
  # get a nicely formatted bit of text for pasting into other services
  
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
    warning_text = add_label_for_embed(ts("Warnings: "), work.warnings.map {|warning| warning_display_name(warning.name)}.join(', '), tag("br"))
    relationship_text = add_label_for_embed(ts("Relationships: "), work.relationships.map {|rel| rel.name}.join(', '), tag("br"))
    char_text = add_label_for_embed(ts("Characters: "), work.characters.map {|char| char.name}.join(', '), tag("br"))
    tags_text = add_label_for_embed(ts("Additional Tags: "), work.freeforms.map {|freeform| freeform.name}.join(', '), tag("br"))
    if work.series.count != 0
      series_text = add_label_for_embed(ts("Series: "), series_list_for_feeds(work), tag("br"))
    end
    summary_text = add_label_for_embed(ts("Summary: "), sanitize_field(work, :summary))
    
    if work.series.count != 0
      [chapters_text, fandom_text, rating_text, warning_text, relationship_text, char_text, tags_text, series_text, summary_text].compact.join
    else
      [chapters_text, fandom_text, rating_text, warning_text, relationship_text, char_text, tags_text, summary_text].compact.join
    end   
  end
  
  # combine title, word count, creator, and meta to make copy and paste share code for a work
  def get_embed_link(work)
    [get_embed_link_title(work), tag("br"), get_embed_link_meta(work)].compact.join
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
      [work_embed, bookmark_meta].compact.join
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
      [work_meta, bookmark_meta].compact.join
    end
  end
  
  def get_tweet_text(work)
    if work.unrevealed?
      ts("Mystery Work")
    else
      names = work.anonymous? ? ts("Anonymous") : work.pseuds.map(&:name).join(', ')
      fandoms = work.fandoms.size > 2 ? ts("Multifandom") : work.fandoms.string
      "#{work.title} by #{names} - #{fandoms}".truncate(95)
    end
  end
  
  def get_tweet_text_for_bookmark(bookmark)
    if bookmark.bookmarkable.is_a?(Work)
      names = bookmark.bookmarkable.anonymous? ? ts("Anonymous") : bookmark.bookmarkable.pseuds.map(&:name).join(', ')
      fandoms = bookmark.bookmarkable.fandoms.size > 2 ? ts("Multifandom") : bookmark.bookmarkable.fandoms.string
      "Bookmark of #{bookmark.bookmarkable.title} by #{names} - #{fandoms}".truncate(83)
    end
  end
  
end