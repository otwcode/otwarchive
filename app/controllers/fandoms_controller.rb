class FandomsController < ApplicationController
  before_filter :load_collection

  def index
    if @collection
      @fandoms = Fandom.for_collections([@collection] + @collection.children)
    elsif params[:medium_id]
      if @medium = Media.find_by_name(params[:medium_id])
        if @medium == Media.uncategorized
          @fandoms = @medium.fandoms.by_name
        else
          fandom_ids = @medium.fandoms.canonical.collect(&:id)
          @fandoms = Fandom.by_name.with_count.where(:id => fandom_ids)
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
