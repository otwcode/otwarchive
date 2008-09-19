module UsersHelper
  #print all works that belong to a given pseud
  def print_works(pseud)
    result = ""
	  conditions = logged_in? ? "posted = 1" : "posted = 1 AND restricted = 0 OR restricted IS NULL"
	  pseud.works.find(:all, :order => "works.created_at DESC", :conditions => conditions).each do |work|
      result += (render :partial => 'works/work_blurb', :locals => {:work => work})
    end
    result
  end
  
  # Prints user pseuds with links to anchors for each pseud on the page and the description as the title
  def print_pseuds(user)
    user.pseuds.collect(&:name).join(", ")
  end 
  
  # Prints link to bookmarks page with user-appropriate number of bookmarks
  # (The total should reflect the number of bookmarks the user can actually see.)
  def print_bookmarks_link(user)
    total = logged_in_as_admin? ? @user.bookmarks.count : @user.bookmarks.visible.size
    prefix = (@user == current_user) ? "My ".t : ""
    link_to_unless_current prefix + "Bookmarks".t + " (" + total.to_s + ")", user_bookmarks_path(@user)
  end
  
  # Prints link to works page with user-appropriate number of works
  # (The total should reflect the number of works the user can actually see.)
  def print_works_link(user)
    total = logged_in_as_admin? ? @user.works.count : @user.works.visible.size
    prefix = (@user == current_user) ? "My ".t : ""
    link_to_unless_current prefix + "Works".t + " (" + total.to_s + ")", user_works_path(@user)
  end
  
  # Prints link to series page with user-appropriate number of series
  # There's no option to restrict the visibility of a series right now, but there probably will be in the future
  def print_series_link(user)
    total = @user.series.count(:all)
    prefix = (@user == current_user) ? "My ".t : ""
    link_to_unless_current prefix + "Series".t + " (#{total})", user_series_index_path(@user)
  end
  
  def print_drafts_link(user)
    total = @user.unposted_works.size
    link_to_unless_current "My Drafts".t + "(#{total})", drafts_user_works_path(@user)
  end
  
end
