class PeopleController < ApplicationController

  before_filter :load_collection

  def search
    @query = params[:query] || {}
    unless @query.blank?
      begin
        page = params[:page] || 1
        errors, @people = Pseud.search_with_sphinx(@query, page)
        flash.now[:error] = errors.join(" ") unless errors.blank?
      rescue Riddle::ConnectionError
        flash.now[:error] = t('errors.search_engine_down', :default => "The search engine seems to be down at the moment, sorry!")
      end
    end
  end  

    
  def index
    if @collection
      @pseuds_alphabet = @collection.participants.find(:all, :select => 'name')
    else
      @navigation = People.all
    end
    
    if @collection
      @authors = @collection.participants.alphabetical.starting_with(letter).paginate(:per_page => (params[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), :page => (params[:page] || 1))
    end
  end 
 
  def show
    @navigation = People.all
    @character = People.find(params[:id])
    case params[:show]
      when "authors"
        @people = @character.authors.paginate(:per_page => (params[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), :page => (params[:page] || 1))
        @rec_counts = Pseud.rec_counts_for_pseuds(@people)
        @what = "Authors"
      when "reccers"
        @people = @character.reccers.paginate(:per_page => (params[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), :page => (params[:page] || 1))
        @work_counts = Pseud.work_counts_for_pseuds(@people)
        @what = "Reccers"
      else
        @people = @character.pseuds.paginate(:per_page => (params[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), :page => (params[:page] || 1))
        @rec_counts = Pseud.rec_counts_for_pseuds(@people)
        @work_counts = Pseud.work_counts_for_pseuds(@people)
        @what = "People"
    end
  end

end
