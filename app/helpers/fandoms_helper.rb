module FandomsHelper
  
  # Prints link to fandom page with user-appropriate number of works
  # (The total should reflect the number of works the user can actually see.)
  def print_fandom_works_link(fandom)
    link_to fandom.name + " (" + fandom.works.visible.count.to_s + ")", tag_path(fandom)
  end
  
end
