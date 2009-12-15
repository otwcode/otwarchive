class CollectionItemsController < ApplicationController
  before_filter :load_collection
  before_filter :load_item_and_collection, :only => [:update, :destroy]
  before_filter :load_collectible_item, :only => [ :new, :create ]
  before_filter :collection_maintainers_only, :only => [:index, :update]
  before_filter :allowed_to_destroy, :only => [:destroy]

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

  
  def allowed_to_destroy
    @collection_item.user_allowed_to_destroy?(current_user) || not_allowed
  end
  
  def index
    @collection_items = @collection.collection_items
    case params[:sort]
    when "item"
      @collection_items = @collection_items.sort_by {|ci| ci.title}
    when "creator"
      @collection_items = @collection_items.sort_by {|ci| ci.item_creator_names }
    when "user_approval"
      @collection_items = @collection_items.sort_by {|ci| ci.user_approval_status}
    when "collection_approval"
      @collection_items = @collection_items.sort_by {|ci| ci.collection_approval_status}
    when "recipient"
      @collection_items = @collection_items.sort_by {|ci| ci.recipients }
    when "received"
      @collection_items = @collection_items.sort_by {|ci| ci.item_creator_pseuds.map {|pseud| @collection.user_has_received_item(pseud.user) ? "Yes" : "No"}.join(", ")}
    when "date"
      @collection_items = @collection_items.sort_by {|ci| ci.item_date}
    end
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
    # for each collection name
    # see if it exists, is open, and isn't already one of this item's collections
    # add the collection and save
    # if there are errors, add them to errors
    new_collections = []
    unapproved_collections = []
    errors = []
    params[:collection_names].split(',').map {|name| name.strip}.uniq.each do |collection_name|
      collection = Collection.find_by_name(collection_name)
      if !collection
        errors << t('collection_items.not_found', :default => "We couldn't find a collection with the name {{name}}. Make sure you are using the one-word name, and not the title?", :name => collection_name)
      elsif @item.collections.include?(collection)
        errors << t('collection_items.already_there', :default => "This item has already been submitted to {{collection_title}}.", :collection_title => collection.title)
      elsif collection.closed?
        errors << t('collection_items.closed', :default => "{{collection_title}} is closed to new submissions.", :collection_title => collection.title)
      elsif @item.add_to_collection!(collection)
        if @item.approved_collections.include?(collection)
          new_collections << collection
        else
          unapproved_collections << collection
        end
      else
        errors << t('collection_items.something_else', :default => "Something went wrong trying to add collection {{name}}, sorry!", :name => collection_name)
      end
    end

    # messages to the user
    unless errors.empty?
      flash[:error] = t('collection_items.errors', :default => "We couldn't add your submission to the following collections: ") + errors.join("<br />")
    end
    flash[:notice] = "" unless new_collections.empty? && unapproved_collections.empty?
    unless new_collections.empty?
      flash[:notice] = t('collection_items.created', :default => "Added to collection(s): {{collections}}.", 
                            :collections => new_collections.collect(&:title).join(", "))
    end
    unless unapproved_collections.empty?
      flash[:notice] = "<br />" + t('collection_items.unapproved', 
        :default => "Your submission will have to be approved by a moderator before it appears in {{moderated}}.", 
        :moderated => unapproved_collections.collect(&:title).join(", "))
    end

    redirect_to(@item)
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
    @collectible_item = @collection_item.item
    @collection_item.destroy
    flash[:notice] = t('collection_items.destroyed', :default => "Item completely removed from collection {{title}}.", :title => @collection.title)
    if (@collection.user_is_maintainer?(current_user))
      redirect_to collection_items_path(@collection)
    else
      redirect_to @collectible_item
    end
  end

end
