class Static::CollectionsController < ApplicationController
  layout 'static'
  caches_page :show

  def show
    @collection = Collection.find_by_name(params[:id])
    if @collection.nil?
      flash[:error] = ts("Sorry, we couldn't find that collection.")
      redirect_to collections_path
    elsif @collection.unrevealed?
      flash[:error] = ts("Sorry, that collection isn't revealed yet.")
      redirect_to collection_path(@collection)      
    end
    @media = Media.canonical.by_name - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME)]
  end
end
