module UsersHelper
  
  # Can be used to check ownership of items
  def is_author_of?(item) 
    logged_in? ? current_user.is_author_of?(item) : false
  end
  
  #print all works that belong to a given pseud
  def print_works(pseud)
    result = ""
	  conditions = logged_in? ? "posted = 1" : "posted = 1 AND restricted = 0 OR restricted IS NULL"
	  pseud.works.find(:all, :order => "works.revised_at DESC", :conditions => conditions).each do |work|
      result += (render :partial => 'works/work_blurb', :locals => {:work => work})
    end
    result
  end
  
  # Prints user pseuds with links to anchors for each pseud on the page and the description as the title
  def print_pseuds(user)
    user.pseuds.collect(&:name).join(", ")
  end
  
  # Prints coauthors
  def print_coauthors(user)
    user.coauthors.collect(&:name).join(", ")
  end 
  
  # Prints link to bookmarks page with user-appropriate number of bookmarks
  # (The total should reflect the number of bookmarks the user can actually see.)
  def print_bookmarks_link(user)
    total = logged_in_as_admin? ? @user.bookmarks.count : @user.bookmarks.visible.size
    prefix = (@user == current_user) ? "My " : ""
    link_to_unless_current prefix + "Bookmarks" + " (" + total.to_s + ")", user_bookmarks_path(@user)
  end
  
  # Prints link to works page with user-appropriate number of works
  # (The total should reflect the number of works the user can actually see.)
  def print_works_link(user)
    total = user.visible_work_count
    prefix = (@user == current_user) ? "My " : ""
    link_to_unless_current prefix + "Works" + " (" + total.to_s + ")", user_works_path(@user)
  end
  
  def print_pseud_works_link(pseud)
    total = Work.written_by_conditions([pseud]).visible.count(:distinct => true, :select => 'works.id')
    prefix = (@user == current_user) ? "My " : ""
    link_to_unless_current prefix + "Works" + " (" + total.to_s + ")", user_pseud_works_path(@user, pseud.id)
  end

  # Prints link to series page with user-appropriate number of series
  # There's no option to restrict the visibility of a series right now, but there probably will be in the future
  def print_series_link(user)
    total = @user.series.count
    prefix = (@user == current_user) ? "My " : ""
    link_to_unless_current prefix + "Series" + " (#{total})", user_series_index_path(@user)
  end
  
  def print_pseud_series_link(pseud)
    total = pseud.series.count
    prefix = (@user == current_user) ? "My " : ""
    link_to_unless_current prefix + "Series" + " (#{total})", user_pseud_series_index_path(@user, pseud.id)
  end

  def print_drafts_link(user)
    total = @user.unposted_works.size
    link_to_unless_current "My Drafts" + " (#{total})", drafts_user_works_path(@user)
  end
  
#  def print_pseud_drafts_link(pseud)
#    total = pseud.unposted_works.size
#    link_to_unless_current "My Drafts" + " (#{total})", drafts_user_pseud_works_path(@user, pseud)
#  end

  def user_invitations(user)
    invitations = user.invitation_limit == 1 ? 'invitation' : 'invitations'
    user.invitation_limit.to_s + ' ' + invitations
  end
  
  def authors_header(collection)
    if collection.total_pages < 2
      case collection.size
      when 0; "0 Authors"
      when 1; "1 Author"
      else; collection.total_entries.to_s + " Authors"
      end
    else
      %{ %d - %d of %d }% [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ] + "Authors"
    end
  end
  
end
