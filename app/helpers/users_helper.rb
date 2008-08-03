module UsersHelper
  #print all works that belong to a given pseud
  def print_works(pseud)
    result = ""
	  conditions = logged_in? ? "posted = 1" : "posted = 1 AND restricted = 0 OR restricted IS NULL"
	  pseud.works.find(:all, :order => "created_at DESC", :conditions => conditions).each do |work|
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
    total = (@user == current_user) ? @user.total_bookmark_count : @user.public_bookmark_count
    prefix = (@user == current_user) ? "My " : ""
    link_to_unless_current prefix + "Bookmarks (" + total.to_s + ")", user_bookmarks_path(@user)
  end
  
  # Prints link to works page with user-appropriate number of works
  # (The total should reflect the number of works the user can actually see.)
  def print_works_link(user)
    total = current_user.is_a?(User) ? @user.works.count : @user.works.count(:all, :conditions => {:restricted => false})
    prefix = (@user == current_user) ? "My " : ""
    link_to_unless_current prefix + "Works (" + total.to_s + ")", user_works_path(@user)
  end
  
  # Prints link to series page with user-appropriate number of series
  # There's no option to restrict the visibility of a series right now, but there probably will be in the future
  def print_series_link(user)
    total = @user.series.count(:all)
    prefix = (@user == current_user) ? "My " : ""
    link_to_unless_current prefix + "Series (" + total.to_s + ")", user_series_index_path(@user)
  end
  
end
