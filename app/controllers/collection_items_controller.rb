class CollectionItemsController < ApplicationController
  before_filter :load_collection
  before_filter :load_item_and_collection, :only => [:destroy]
  before_filter :load_collectible_item, :only => [ :new, :create ]
  before_filter :allowed_to_destroy, :only => [:destroy]

  cache_sweeper :collection_sweeper

  def load_item_and_collection
    if params[:collection_item]
      @collection_item = CollectionItem.find(params[:collection_item][:id])
    else
      @collection_item = CollectionItem.find(params[:id])
    end
    not_allowed(@collection) and return unless @collection_item
    @collection = @collection_item.collection
  end


  def allowed_to_destroy
    @collection_item.user_allowed_to_destroy?(current_user) || not_allowed(@collection)
  end

  def index

    if @collection && @collection.user_is_maintainer?(current_user)
      @collection_items = @collection.collection_items.include_for_works
      @collection_items = case
      when params[:approved]
        @collection_items.approved_by_collection
      when params[:rejected]
        @collection_items.rejected_by_collection
      else
        @collection_items.unreviewed_by_collection
      end
    elsif params[:user_id] && (@user = User.find_by_login(params[:user_id])) && @user == current_user
      @collection_items = CollectionItem.for_user(@user).includes(:collection)
      @collection_items = case
      when params[:approved]
        @collection_items.approved_by_user
      when params[:rejected]
        @collection_items.rejected_by_user
      else
        @collection_items.unreviewed_by_user
      end
    else
      flash[:error] = ts("You don't have permission to see that, sorry!")
      redirect_to collections_path and return
    end
    
    sort = "created_at DESC"
    # case params[:sort]
    # when "item"
    #   @collection_items = @collection_items.sort_by {|ci| ci.title}
    # when "collection"
    #   @collection_items = @collection_items.sort_by {|ci| ci.collection.title}
    # when "word_count"
    #   @collection_items = @collection_items.sort_by {|ci| ci.item.respond_to?(:word_count) ? ci.item.word_count : 0 }      
    # when "creator"
    #   @collection_items = @collection_items.sort_by {|ci| ci.item_creator_names }
    # when "member"
    #   @collection_items = @collection_items.sort_by {|ci| ci.item_creator_pseuds.map {|pseud| @collection.user_is_posting_participant?(pseud.user) ? "Y" : "N"}.join(", ") }      
    # when "user_approval"
    #   @collection_items = @collection_items.sort_by {|ci| ci.user_approval_status}
    # when "collection_approval"
    #   @collection_items = @collection_items.sort_by {|ci| ci.collection_approval_status}
    # when "recipient"
    #   @collection_items = @collection_items.sort_by {|ci| ci.recipients } if @collection.gift_exchange?
    # when "date"
    #   @collection_items = @collection_items.sort_by {|ci| ci.item_date}
    # end

    @collection_items = @collection_items.order(sort).paginate :page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE          
  end

  def load_collectible_item
    if params[:work_id]
      @item = Work.find(params[:work_id])
    elsif params[:bookmark_id]
      @item = Bookmark.find(params[:bookmark_id])
    end
  end

  def new
  end

  def create
    unless params[:collection_names]
      flash[:error] = ts("What collections did you want to add?")
      redirect_to(request.env["HTTP_REFERER"] || root_path) and return
    end
    unless @item
      flash[:error] = ts("What did you want to add to a collection?")
      redirect_to(request.env["HTTP_REFERER"] || root_path) and return
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
        errors << ts("We couldn't find a collection with the name %{name}. Make sure you are using the one-word name, and not the title?", :name => collection_name)
      elsif @item.collections.include?(collection)
        errors << ts("This item has already been submitted to %{collection_title}.", :collection_title => collection.title)
      elsif collection.closed?
        errors << ts("%{collection_title} is closed to new submissions.", :collection_title => collection.title)
      elsif !current_user.is_author_of?(@item) && !collection.user_is_maintainer(current_user)
        errors << ts("Not allowed: either you don't own this item or are not a moderator of %{collection_title}", :collection_title => collection.title)
      elsif @item.add_to_collection(collection) && @item.save
        if @item.approved_collections.include?(collection)
          new_collections << collection
        else
          unapproved_collections << collection
        end
      else
        errors << ts("Something went wrong trying to add collection %{name}, sorry!", :name => collection_name)
      end
    end

    # messages to the user
    unless errors.empty?
      flash[:error] = ts("We couldn't add your submission to the following collections: ") + errors.join("<br />")
    end
    flash[:notice] = "" unless new_collections.empty? && unapproved_collections.empty?
    unless new_collections.empty?
      flash[:notice] = ts("Added to collection(s): %{collections}.",
                            :collections => new_collections.collect(&:title).join(", "))
    end
    unless unapproved_collections.empty?
      flash[:notice] += "<br />" + ts("Your addition will have to be approved before it appears in %{moderated}.",
        :moderated => unapproved_collections.collect(&:title).join(", "))
    end

    flash[:notice] = (flash[:notice]).html_safe unless flash[:notice].blank?
    flash[:error] = (flash[:error]).html_safe unless flash[:error].blank?

    redirect_to(@item)
  end
  
  def update_multiple
    # whoops, not working because it freezes the hash
    # not_allowed = CollectionItem.where(:id => params[:collection_items].keys)
    # if params[:user_id] && (@user = User.find_by_login(params[:user_id])) && @user == current_user
    #   # TODO should rewrite this as query
    #   not_allowed = not_allowed.reject {|item| @user.is_author_of?(item)}
    # elsif @collection && @collection.user_is_maintainer?(current_user)
    #   not_allowed = not_allowed.where("collection_id != ?", @collection.id)
    # end
    # unless not_allowed.empty?
    #   flash[:error] = ts("You are not allowed to modify that!")
    #   redirect_to root_path and return
    # end
    @collection_items = CollectionItem.update(params[:collection_items].keys, params[:collection_items].values).reject { |item| item.errors.empty? }
    if @collection_items.empty?
      flash[:notice] = ts("Collection status updated!")
      redirect_to (@user ? user_collection_items_path(@user) : collection_items_path(@collection))
    else
      render :action => "index"
    end
  end

  def destroy
    @user = User.find_by_login(params[:user_id]) if params[:user_id]
    @collectible_item = @collection_item.item
    @collection_item.destroy
    flash[:notice] = ts("Item completely removed from collection %{title}.", :title => @collection.title)
    if @user
      redirect_to user_collection_items_path(@user) and return
    elsif (@collection.user_is_maintainer?(current_user))
      redirect_to collection_items_path(@collection) and return
    end
  end

end
