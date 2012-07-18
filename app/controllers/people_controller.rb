class PeopleController < ApplicationController

  before_filter :load_collection
  
  def do_search
    if @collection
      # constrain by ids of the participants
      @query[:id] = @collection.participants.value_of(:pseud_id).join(',')
    end
    begin
      page = params[:page] || 1
      errors, @people = Query.search_with_sphinx(Pseud, @query, page)
      setflash; flash.now[:error] = errors.join(" ") unless errors.blank?
    rescue Riddle::ConnectionError
      setflash; flash.now[:error] = ts("The search engine seems to be down at the moment, sorry!")
    end
    # @people could contain nils from sphinx
    @rec_counts = Pseud.rec_counts_for_pseuds(@people.compact)
    @work_counts = Pseud.work_counts_for_pseuds(@people.compact)
  end

  def search
    @query = {}
    if params[:query]
      @query = Query.standardize(params[:query])
      do_search
    end
  end

  def index
    @people = []
    if params[:query] 
      if params[:query].length < 3
        setflash; flash[:error] = ts("Your search needs to be at least 3 characters long for performance reasons, sorry!")
      else
        # wildcard the search by default 
        @query = {}
        @query[:text] = "*#{params[:query]}*".gsub("**", '*')
        do_search
        @query = params[:query]
      end
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
