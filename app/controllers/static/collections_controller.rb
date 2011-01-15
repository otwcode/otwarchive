class Static::CollectionsController < ApplicationController
  layout 'static'
  caches_page :show

  def show
    @collection = Collection.find_by_name(params[:id])
    if @collection.nil?
      redirect_to root_path, :error => "Sorry, we couldn't find that collection."
    elsif @collection.unrevealed?
      redirect_to root_path, :error => "Sorry, this collection isn't revealed yet."      
    end
    @media = Media.canonical.by_name - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME)]
  end
end
