class SearchController < ApplicationController

  def index
    @languages = Language.default_order
    @search = WorkSearch.new(params[:work_search])
  end
  
end
