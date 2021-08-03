module BookmarksHelper

  # if the current user has the current object bookmarked return the existing bookmark
  # since the user may have multiple bookmarks for different pseuds we prioritize by current default pseud if more than one bookmark exists
  def bookmark_if_exists(bookmarkable)
    return nil unless logged_in?
    bookmarkable = bookmarkable.work if bookmarkable.class == Chapter
    bookmarks = Bookmark.where(bookmarkable_id: bookmarkable.id, bookmarkable_type: bookmarkable.class.name.to_s, pseud_id: current_user.pseuds.collect(&:id))
    if bookmarks.count > 1
      bookmarks.where(pseud_id: current_user.default_pseud.id).first || bookmarks.last
    else
      bookmarks.last
    end
  end

  # returns just a url to the new bookmark form
  def get_new_bookmark_path(bookmarkable)
    return case bookmarkable.class.to_s
    when "Chapter"
      new_work_bookmark_path(bookmarkable.work)
    when "Work"
      new_work_bookmark_path(bookmarkable)
    when "ExternalWork"
      new_external_work_bookmark_path(bookmarkable)
    when "Series"
      new_series_bookmark_path(bookmarkable)
    end
  end

  # tag_bookmarks_path was behaving badly for tags with slashes
  def link_to_tag_bookmarks(tag)
    {controller: 'bookmarks', action: 'index', tag_id: tag}
  end

  def link_to_bookmarkable_bookmarks(bookmarkable, link_text='')
    if link_text.blank?
      link_text = Bookmark.count_visible_bookmarks(bookmarkable, current_user)
    end
    path = case bookmarkable.class.name
           when "Work"
             then work_bookmarks_path(bookmarkable)
           when "ExternalWork"
             then external_work_bookmarks_path(bookmarkable)
           when "Series"
             then series_bookmarks_path(bookmarkable)
           end
    link_to link_text, path
  end

  # returns the appropriate small single icon for a bookmark -- not hardcoded, these are in css so they are skinnable
  def get_symbol_for_bookmark(bookmark)
    if bookmark.private?
      css_class = "private"
      title_string = "Private Bookmark"
    elsif bookmark.hidden_by_admin?
      css_class = "hidden"
      title_string = "Bookmark Hidden by Admin"
    elsif bookmark.rec?
      css_class = "rec"
      title_string = "Rec"
    else
      css_class = "public"
      title_string = "Public Bookmark"
    end
    link_to_help('bookmark-symbols-key', content_tag(:span, content_tag(:span, title_string, class: "text"), class: css_class, title: title_string))
  end

  def bookmark_form_path(bookmark, bookmarkable)
    if bookmark.new_record?
      if bookmarkable.new_record?
        bookmarks_path
      else
        polymorphic_path([bookmarkable, bookmark])
      end
    else
      bookmark_path(bookmark)
    end
  end

  def get_count_for_bookmark_blurb(bookmarkable)
    count = bookmarkable.public_bookmark_count
    link = link_to (count < 100 ? count.to_s : "*"),
              polymorphic_path([bookmarkable, Bookmark])
    content_tag(:span, link, class: "count")
  end

end
