module Tolk
  class SearchesController < Tolk::ApplicationController
    before_filter :find_locale
  
    def show
      @phrases = @locale.search_phrases(params[:q], params[:page])
    end

    private

    def find_locale
      @locale = Tolk::Locale.find_by_name!(params[:locale])
    end
  end
end
