class PeopleController < ApplicationController

  before_filter :load_collection
    
  def index
    if @collection
      @pseuds_alphabet = @collection.participants.find(:all, :select => 'name')
    else
      if params[:show] == "authors"
        @pseuds_alphabet = Pseud.find(:all).select {|a| a.visible_works_count > 0}
      elsif params[:show] == "reccers"
        @pseuds_alphabet = Pseud.find(:all).select {|a| a.bookmarks.recs.visible.size > 0}
      else
        # much faster
        @pseuds_alphabet = Pseud.find(:all, :select => 'name')
      end
    end
    @pseuds_alphabet = @pseuds_alphabet.collect {|pseud| pseud.name.scan(/./mu)[0].upcase}.uniq.sort
    
    if params[:letter] && params[:letter].is_a?(String)
      letter = params[:letter][0,1]
    else
      letter = @pseuds_alphabet[0]
    end
    
    if @collection
      @authors = @collection.participants.alphabetical.starting_with(letter).paginate(:per_page => (params[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), :page => (params[:page] || 1))
    else
      if params[:show] == "authors"
        @authors = Pseud.alphabetical.starting_with(letter).select{|pseud| pseud.visible_works_count > 0}.paginate(:per_page => (params[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), :page => (params[:page] || 1))
      elsif params[:show] == "reccers"
        @authors = Pseud.alphabetical.starting_with(letter).select{|pseud| pseud.bookmarks.recs.visible.size > 0}.paginate(:per_page => (params[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), :page => (params[:page] || 1))
      else
        @authors = Pseud.authors.starting_with(letter).paginate(:per_page => (params[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), :page => (params[:page] || 1))
      end
    end
  end 

end
