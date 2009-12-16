class MediaController < ApplicationController
  before_filter :load_collection

  def index
    @media = Media.all - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME)]
    @fandom_listing = {}
    @media.each do |medium|
      if medium == Media.uncategorized
        @fandom_listing[medium] = medium.fandoms.find(:all, :order => 'created_at DESC', :limit => 5)
      else
        @fandom_listing[medium] = (logged_in? || logged_in_as_admin?) ? medium.fandoms.unhidden_top(5).find(:all, :conditions => {:canonical => true}) : medium.fandoms.public_top(5).find(:all, :conditions => {:canonical => true})
      end
    end
  end

  def show
    redirect_to medium_fandoms_path(:medium_id => params[:id])
  end
end
