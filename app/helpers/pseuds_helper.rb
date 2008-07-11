module PseudsHelper
  
  # Prints array of pseuds with links to user pages
  def print_pseud_list(pseuds)
    pseuds.collect {|pseud| link_to_unless_current(pseud.name, pseud.user)}.join(", ")
  end
end
