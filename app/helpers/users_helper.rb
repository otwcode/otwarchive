module UsersHelper
  #print all works that belong to a given pseud
  def print_works(pseud)
    result = ""
    pseud.works.each do |work|
      if work.posted
        result += "<h4>" + link_to(h(work.metadata.title), work_path(work)) + "</h4>"

        if current_user == pseud.user
          result += link_to 'Edit'.t, edit_work_path(work)
        end
      end
    end
    result
  end
end
