class PeopleController < ApplicationController
  
  def index
    authored_items_scope = ""
    if params[:show] == "authors"
      authored_items_scope = ".select{|a| a.visible_works_count > 0}"
    elsif params[:show] == "reccers"
      authored_items_scope = logged_in_as_admin? ? ".select{|a| a.bookmarks.count > 0}" : ".select{|a| a.bookmarks.visible.size > 0}"
    end
    @pseuds_alphabet = eval("Pseud.find(:all)#{authored_items_scope}").collect {|pseud| pseud.name[0,1].upcase}.uniq.sort
    
    if params[:letter] && params[:letter].is_a?(String)
      letter = params[:letter][0,1]
    else
      letter = @pseuds_alphabet[0]
    end
    @authors = eval("Pseud.alphabetical.starting_with(letter)#{authored_items_scope}").paginate(:per_page => (params[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), :page => (params[:page] || 1))
  end 

end
