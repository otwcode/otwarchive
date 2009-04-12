module PseudsHelper
  
  # Prints array of pseuds with links to user pages
  # used on Profile page
  def print_pseud_list(pseuds)
    pseuds.collect {|pseud| link_to_unless_current(pseud.name, [pseud.user, pseud])}.join(", ")
  end
  
  # used in the sidebar
  def print_pseud_selector(pseuds)
    pseuds -= [@pseud] if @pseud && @pseud.new_record?
    pseuds.sort.collect {|pseud| "<li>" + link_to_unless_current(pseud.name, [pseud.user, pseud]) + "</li>"}.join("")
  end
end
