class Static::BaseController < ApplicationController
  layout 'static'
  before_filter :load_static_controller
  before_filter :load_media

  protected

  def load_static_controller
    @collection = Collection.find_by_name(params[:collection_id])
    if @collection.nil?
      redirect_to root_path, :error => "Sorry, we couldn't find that collection."
    elsif @collection.unrevealed?
      redirect_to root_path, :error => "Sorry, this collection isn't revealed yet."      
    end
  end

  def load_media
    @media = Media.canonical - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME)]
  end

end
