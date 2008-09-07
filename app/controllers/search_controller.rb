class SearchController < ApplicationController
  
  def show
    if params[:query]
      @search = Ultrasphinx::Search.new(:query => params[:query])
      @search.run
      @results = @search.results.paginate( :page => params[:page])
    end
    @tag_categories = TagCategory.official
  end
  
end
