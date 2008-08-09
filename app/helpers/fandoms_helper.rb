module FandomsHelper
  
  # Prints link to fandom page with user-appropriate number of works
  # (The total should reflect the number of works the user can actually see.)
  def print_fandom_works_link(fandom)
    total = current_user.is_a?(User) ? fandom.works.count : fandom.works.count(:all, :conditions => {:restricted => false})
    link_to fandom.name + " (" + total.to_s + ")", fandom_path(fandom)
  end
  
end
