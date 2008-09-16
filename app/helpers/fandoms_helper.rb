module FandomsHelper
  
  # Prints link to fandom page with user-appropriate number of works
  # (The total should reflect the number of works the user can actually see.)
  def print_fandom_works_link(fandom)
    link_to fandom.name + " (" + fandom.visible_work_count(current_user).to_s + ")", fandom_path(fandom)
  end
  
end
