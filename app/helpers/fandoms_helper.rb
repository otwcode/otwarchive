module FandomsHelper
  
  # Prints link to fandom page with user-appropriate number of works
  # (The total should reflect the number of works the user can actually see.)
  def print_fandom_works_link(fandom)
    total = logged_in_as_admin? ? fandom.works.count : fandom.works.visible(current_user).size
    link_to fandom.name + " (" + total.to_s + ")", fandom_path(fandom)
  end
  
end
