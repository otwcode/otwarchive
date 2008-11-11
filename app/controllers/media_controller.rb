class MediaController < ApplicationController
  
  def index
    @media = Media.all(:order => 'taggings_count DESC')
    @fandom_listing = {}
    @media.each do |medium|
      fandoms = medium.fandoms.find(:all, :limit => 6, :order => 'taggings_count DESC')
      fandom_hash = {
        :fandoms => fandoms[0...5].collect{|fandom| 
                        [fandom, fandom.visible_works.size]},
        :more => fandoms[5].blank? ? false : true
                 }
      @fandom_listing[medium] = fandom_hash
    end
  end
  
  def show
    @medium = Media.find(params[:id])
    @fandoms = @medium.fandoms.canonical.find(:all, :order => :name).paginate(:page => params[:page])
  end
end
