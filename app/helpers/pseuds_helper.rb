module PseudsHelper
  
  # Prints array of pseuds with links to user pages
  # used on Profile page
  def print_pseud_list(pseuds)
    pseuds.includes(:user).collect { |pseud| span_if_current(pseud.name, [pseud.user, pseud]) }.join(", ").html_safe
  end
  
  # used in the sidebar
  def print_pseud_selector(pseuds)
    pseuds -= [@pseud] if @pseud && @pseud.new_record?
    list = pseuds.sort.collect {|pseud| "<li>" + span_if_current(pseud.name, [pseud.user, pseud]) + "</li>"}.join("").html_safe
  end

  # For tag list on /people page
  def link_to_tag_with_count(pseud, tag_w_count)
    name = tag_w_count.first.name + " (" + tag_w_count.last.to_s + ")" 
    url = user_pseud_works_path(pseud.user, pseud, selected_tags: [tag_w_count.first.id])
    link_to name, url, class: 'tag'  
  end

  # Controls which of current_user's pseuds is selected when posting or editing 
  # an item. It used to be handled with just @selected_pseuds from the item 
  # type's controller (chapter, series, work), but needs a special case when 
  # current_user is editing a chapter they didn't co-author. When that happens,
  # we want to select all pseuds current_user has listed on the work itself.
  def selected_pseuds(item_type)
    if item_type == "chapter" && @chapter.posted?
      to_select = @to_select.select { |pseud| pseud.user.id == current_user.id }
      pseuds = to_select.empty? ? @work.pseuds : to_select
      pseuds.collect { |pseud| pseud.id }
    else
      @selected_pseuds
    end
  end
end
