class FandomsController < ApplicationController
  before_filter :load_collection

  def index
    if @collection
      if AdminSetting.enable_test_caching?      
        @fandoms = Rails.cache.fetch("collection#{@collection.id}-fandoms", :expires_in => AdminSetting.cache_expiration.minutes) do
          if @collection.children.empty? 
            Fandom.for_collection(@collection)
          else
            Fandom.for_collections([@collection] + @collection.children)
          end               
        end
      else
        if @collection.children.empty? 
          @fandoms = Fandom.for_collection(@collection)
        else
          @fandoms = Fandom.for_collections([@collection] + @collection.children)
        end        
      end
    elsif params[:medium_id]
      @medium = Media.find_by_name(params[:medium_id])
      if @medium == Media.uncategorized
        @fandoms = @medium.fandoms.by_name
      else
        fandom_ids = @medium.fandoms.canonical.collect(&:id)
        @fandoms = Fandom.by_name.with_count.find(:all, :conditions => {:id => fandom_ids})
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