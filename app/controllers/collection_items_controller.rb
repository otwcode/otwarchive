class CollectionItemsController < ApplicationController
  before_filter :load_collection
  before_filter :load_collectible_item, :only => [ :new, :create ]
  
  def load_collectible_item
    if params[:work_id] 
      @item = Work.find(params[:work_id])
    end
  end
  
  def new
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def create
    unless params[:collection_names] 
      flash[:error] = t('collection_items.no_collections', :default => "What collections did you want to add?")
      redirect_to :back and return
    end
    unless @item
      flash[:error] = t('collection_items.no_item', :default => "What did you want to add to a collection?")
      redirect_to :back and return
    end
    @item.collection_names = params[:collection_names] + ", " + @item.collection_names
    if @item.save
      flash[:notice] = t('collection_items.created', :default => "Added to collection.")
      redirect_to(@item)
    else
      render :action => :new
    end
  end
  
  
  def approve
    
  end
  
  def reject
    
  end

  def destroy
    @collection_item = CollectionItem.find(params[:id])
  end

end
