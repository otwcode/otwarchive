class PeopleController < ApplicationController

  before_filter :load_collection
  
  def do_search
    options = { :query => params[:query], :page => params[:page] || 1 }
    if @collection
      options[:collection_id] = @collection.id
    end
    @people = PseudSearch.search(options)
    # TODO: move to search index
    @rec_counts = Pseud.rec_counts_for_pseuds(@people)
    @work_counts = Pseud.work_counts_for_pseuds(@people)
  end

  def search
    if params[:query].present?
      do_search
    end
  end

  def index
    @people = []
    if params[:query].present?
      do_search
    else
      @random = true
      if @collection
        @people = @collection.participants.order("RAND()").limit(10)
      else
        @people = Pseud.order("RAND()").limit(10)
      end
      @rec_counts = Pseud.rec_counts_for_pseuds(@people)
      @work_counts = Pseud.work_counts_for_pseuds(@people)      
    end
  end

end
