class FandomsController < ApplicationController
  before_filter :load_collection

  def index
    if @collection
      if AdminSetting.enable_test_caching?      
        @fandoms = Rails.cache.fetch("collection#{@collection.id}-fandoms", :expires_in => AdminSetting.cache_expiration.minutes) do
          Fandom.for_collections([@collection] + @collection.children)
        end
      else
        @fandoms = Fandom.for_collections([@collection] + @collection.children)
      end
    elsif params[:medium_id]
      if @medium = Media.find_by_name(params[:medium_id])
        if @medium == Media.uncategorized
          @fandoms = @medium.fandoms.by_name
        else
          fandom_ids = @medium.fandoms.canonical.collect(&:id)
          @fandoms = Fandom.by_name.with_count.find(:all, :conditions => {:id => fandom_ids})
        end      
      else
        raise ActiveRecord::RecordNotFound, "Couldn't find media category named '#{params[:medium_id]}'"
      end
    else
      @fandoms = Fandom.canonical.by_name.with_count
    end
  end
  
  def show
    @fandom = Fandom.find_by_name(params[:id])
    @characters = @fandom.characters.canonical
  end
end