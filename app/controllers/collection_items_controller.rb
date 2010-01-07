class CollectionItemsController < ApplicationController
  before_filter :load_collection
  before_filter :load_item_and_collection, :only => [:update, :destroy]
  before_filter :load_collectible_item, :only => [ :new, :create ]
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

    if @collection && @collection.user_is_maintainer?(current_user)
      @collection_items = @collection.collection_items.include_for_works
    elsif params[:user_id] && (@user = User.find_by_login(params[:user_id])) && @user == current_user
      @collection_items = @user.work_collection_items + @user.bookmark_collection_items
    else
      flash[:error] = t('collection_items.no_items_found', :default => "We couldn't find any items for you to view.")
      redirect_to root_path and return
    end

    # @has_received = {}
    # if @collection && @collection.gift_exchange?
    #   @gift_recipients = Gift.in_collection(@collection).name_only.collect(&:recipient_name).uniq
    #   @gift_recipients.each {|recip| @has_received[recip] = true}
    # end

    case params[:sort]
    when "item"
      @collection_items = @collection_items.sort_by {|ci| ci.title}
    when "collection"
      @collection_items = @collection_items.sort_by {|ci| ci.collection.title}
    when "word_count"
      @collection_items = @collection_items.sort_by {|ci| ci.item.respond_to?(:word_count) ? ci.item.word_count : 0 }      
    when "creator"
      @collection_items = @collection_items.sort_by {|ci| ci.item_creator_names }
    when "member"
      @collection_items = @collection_items.sort_by {|ci| ci.item_creator_pseuds.map {|pseud| @collection.user_is_posting_participant?(pseud.user) ? "Y" : "N"}.join(", ") }      
    when "user_approval"
      @collection_items = @collection_items.sort_by {|ci| ci.user_approval_status}
    when "collection_approval"
      @collection_items = @collection_items.sort_by {|ci| ci.collection_approval_status}
    when "recipient"
      @collection_items = @collection_items.sort_by {|ci| ci.recipients } if @collection.gift_exchange?
    # when "received"
    #   @collection_items = @collection_items.sort_by {|ci| ci.check_gift_received(@has_received)} if @collection.gift_exchange?
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
    @collection_item = CollectionItem.find(params[:collection_item][:id])
    if params[:user_id] && (@user = User.find_by_login(params[:user_id])) && @user == current_user
      @collection_item.user_approval_status = params[:collection_item][:user_approval_status]
      if @collection_item.save
        flash[:notice] = t('collection_items.updated', :default => "Updated {{item}}.", :item => @collection_item.title)
      else
        flash[:error] = t('collection_items.update_failed', :default => "We couldn't update {{item}}: {{errors}}", :item => @collection_item.title, :errors => @collection_item.errors.each {|attrib, msg| msg}.join(", "))
      end
      redirect_to user_collection_items_path(@user) and return
    elsif @collection && @collection.user_is_maintainer?(current_user)
      # update as allowed -- currently just approval status
      @collection_item.collection_approval_status = params[:collection_item][:collection_approval_status]
      @collection_item.anonymous = params[:collection_item][:anonymous]
      if @collection_item.unrevealed && (params[:collection_item][:unrevealed] == "0")
        @collection_item.reveal!
      else
        @collection_item.unrevealed = params[:collection_item][:unrevealed]
      end
      if @collection_item.save
        flash[:notice] = t('collection_items.updated', :default => "Updated {{item}}.", :item => @collection_item.title)
      else
        flash[:error] = t('collection_items.update_failed', :default => "We couldn't update {{item}}: {{errors}}", :item => @collection_item.title, :errors => @collection_item.errors.each {|attrib, msg| msg}.join(", "))
      end
      redirect_to collection_items_path(@collection) and return
    else
      flash[:error] = t('collection_items.update_not_allowed', :default => "You're not allowed to make that change.")
      redirect_to :back and return
    end
  end
  
  def destroy
    @user = User.find_by_login(params[:user_id]) if params[:user_id]
    @collectible_item = @collection_item.item
    @collection_item.destroy
    flash[:notice] = t('collection_items.destroyed', :default => "Item completely removed from collection {{title}}.", :title => @collection.title)
    if @user
      redirect_to user_collection_items_path(@user) and return
    elsif (@collection.user_is_maintainer?(current_user))
      redirect_to collection_items_path(@collection) and return
    end
  end

end
