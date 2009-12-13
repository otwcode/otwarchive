class CollectionItemsController < ApplicationController
  before_filter :load_collection
  before_filter :load_item_and_collection, :only => [:update, :destroy]
  before_filter :load_collectible_item, :only => [ :new, :create ]
  before_filter :collection_maintainers_only, :only => [:index, :destroy, :update]

  def not_allowed
    flash[:error] = t('collection_items.not_allowed', :default => "Sorry, you're not allowed to do that.")
    redirect_to collection_path(@collection)
    false
  end

  def load_item_and_collection
    if params[:collection_item]
      @collection_item = CollectionItem.find(params[:collection_item][:id])
    else
      @collection_item = CollectionItem.find(params[:id])
    end
    not_allowed and return unless @collection_item
    @collection = @collection_item.collection
  end    

  
  # def allowed_to_destroy
  #   @collection_item.user_allowed_to_destroy?(current_user) || not_allowed
  # end
  
  
  def index
    @collection_items = @collection.collection_items
  end
  
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
  
  def update
    if @collection_item.update_attributes(params[:collection_item])
      flash[:notice] = t('collection_item.update_success', :default => "Updated item.")
    else
      flash[:error] = t('collection_item.update_failure', :default => "Couldn't update item.")
    end
    redirect_to collection_items_path(@collection)
  end
  
  def destroy
    @collection_item.destroy
    flash[:notice] = t('collection_items.destroyed', :default => "Item completely removed from collection")
    redirect_to collection_items_path(@collection)
  end

end
