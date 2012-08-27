class SearchController < ApplicationController

  def index
    @languages = Language.default_order
    # @query = {}
    # if params[:query]
    #   @query = Query.standardize(params[:query])
    #   unless @query == params[:query]
    #     params[:query] = @query
    #     redirect_to url_for(params)
    #   end
    # end
    @search = WorkSearch.new(params[:work_search])
  end

  
end
