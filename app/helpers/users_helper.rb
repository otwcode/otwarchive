module UsersHelper
  #print all works that belong to a given pseud
  def print_works(pseud)
    result = ""
	conditions = logged_in? ? "posted = 1" : "posted = 1 AND restricted = 0 OR restricted IS NULL"
	pseud.works.find(:all, :order => "created_at DESC", :conditions => conditions).each do |work|
      if work.posted
        result += "<h4>" + link_to(h(work.metadata.title), work_path(work)) + "</h4>"

        if current_user == pseud.user
          result += link_to 'Edit this story'.t, edit_work_path(work)
        end
      end
    end
    result
  end
end
