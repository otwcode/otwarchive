class CollectionProfileController < ApplicationController

  before_action :load_collection

  def show
    unless @collection
      flash[:error] = "What collection did you want to look at?"
      redirect_to collections_path and return
    end
    @page_subtitle = t(".page_title", collection_title: @collection.title)
  end

end
