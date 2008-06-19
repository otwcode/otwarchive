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
    user.pseuds.collect {|pseud| '<a href="' + url_for(:anchor => "pseud-#{pseud.id}") + 
                          '" title="' + pseud.description + '">' + pseud.name + '</a>'}.join(", ")
  end 
  
  # Prints link to bookmarks page with user-appropriate number of bookmarks
  # (The total should reflect the number of bookmarks the user can actually see.)
  def print_bookmarks_link(user)
    @user == current_user ? total = @user.total_bookmark_count : total = @user.public_bookmark_count
    link_to 'Bookmarks (' + total.to_s + ')', user_bookmarks_path(@user)
  end
  
end
