class PeopleController < ApplicationController

  before_filter :load_collection

  def search
    @query = {}
    if params[:query]
      @query = Query.standardize(params[:query])
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
  end


  def index
    if @collection
      @pseuds_alphabet = @collection.participants.find(:all, :select => 'name')
      @pseuds_alphabet = @pseuds_alphabet.collect {|pseud| pseud.name.scan(/./mu)[0].upcase}.uniq.sort
      if params[:letter] && params[:letter].is_a?(String)
        letter = params[:letter][0,1]
      else
  letter = @pseuds_alphabet[0]
      end
      @authors = @collection.participants.alphabetical.starting_with(letter).paginate(:per_page => (params[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), :page => (params[:page] || 1))
      @rec_counts = Pseud.rec_counts_for_pseuds(@authors)
      @work_counts = Pseud.work_counts_for_pseuds(@authors)
    else
      @navigation = People.all
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
