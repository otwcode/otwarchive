class CollectionProfileController < ApplicationController

  before_filter :load_collection

  def show
    unless @collection
      flash[:error] = "What collection did you want to look at?"
      redirect_to collections_path
    end
  end

end
