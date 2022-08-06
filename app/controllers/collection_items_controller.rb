class CollectionItemsController < ApplicationController
  before_action :load_collection
  before_action :load_user, only: [:update_multiple]
  before_action :load_item_and_collection, only: [:destroy]
  before_action :load_collectible_item, only: [:new, :create]
  before_action :allowed_to_destroy, only: [:destroy]

  cache_sweeper :collection_sweeper

  def load_item_and_collection
    if params[:collection_item]
      @collection_item = CollectionItem.find(collection_item_params[:id])
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
                            @collection_items.approved_by_both
                          when params[:rejected]
                            @collection_items.rejected_by_collection
                          when params[:invited]
                            @collection_items.invited_by_collection
                          else
                            @collection_items.unreviewed_by_collection
                          end
    elsif params[:user_id] && (@user = User.find_by(login: params[:user_id])) && @user == current_user
      @collection_items = CollectionItem.for_user(@user).includes(:collection)
      @collection_items = case
                          when params[:approved]
                            @collection_items.approved_by_both
                          when params[:rejected]
                            @collection_items.rejected_by_user
                          else
                            @collection_items.unreviewed_by_user
                          end
    else
      flash[:error] = t(".permission_denied.view")
      redirect_to collections_path and return
    end

    sort = "created_at DESC"
    @collection_items = @collection_items.order(sort).paginate page: params[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE
  end

  def load_collectible_item
    if params[:work_id]
      @item = Work.find(params[:work_id])
    elsif params[:bookmark_id]
      @item = Bookmark.find(params[:bookmark_id])
    end
  end

  def load_user
    unless @collection
      @user = User.find_by(login: params[:user_id])
    end
  end

  def new
  end

  def create
    unless params[:collection_names]
      flash[:error] = t(".no_collection")
      redirect_to(request.env["HTTP_REFERER"] || root_path) and return
    end
    unless @item
      flash[:error] = t(".no_item")
      redirect_to(request.env["HTTP_REFERER"] || root_path) and return
    end
    # for each collection name
    # see if it exists, is open, and isn't already one of this item's collections
    # add the collection and save
    # if there are errors, add them to errors
    new_collections = []
    invited_collections = []
    unapproved_collections = []
    errors = []
    params[:collection_names].split(',').map {|name| name.strip}.uniq.each do |collection_name|
      collection = Collection.find_by(name: collection_name)
      if !collection
        errors << t(".errors.not_found", name: collection_name)
      elsif @item.collections.include?(collection)
        if @item.rejected_collections.include?(collection)
          errors << t(".errors.invitation_rejected", collection_title: collection.title, object_type: @item.class.name.humanize.downcase)
        else
          errors << t(".errors.already_submitted", collection_title: collection.title)
        end
      elsif collection.closed? && !collection.user_is_maintainer?(User.current_user)
        errors << t(".errors.closed", collection_title: collection.title)
      elsif (collection.anonymous? || collection.unrevealed?) && !current_user.is_author_of?(@item)
        errors << t(".errors.collection_anonymous_or_unrevealed", collection_title: collection.title)
      elsif !current_user.is_author_of?(@item) && !collection.user_is_maintainer?(current_user)
        errors << t(".errors.own_nor_moderate", collection_title: collection.title)
      elsif @item.is_a?(Work) && @item.anonymous? && !current_user.is_author_of?(@item)
        errors << t(".errors.item_anonymous", collection_title: collection.title)
      # add the work to a collection, and try to save it
      elsif @item.add_to_collection(collection) && @item.save(validate: false)
        # approved_by_user? and approved_by_collection? are both true
        if @item.approved_collections.include?(collection)
          new_collections << collection
        # if the current_user is a maintainer of the collection then approved_by_user must have been false (which means
        # the current_user isn't the owner of the item), then the maintainer is attempting to invite this work to
        # their collection
        elsif collection.user_is_maintainer?(current_user)
          invited_collections << collection
        # otherwise the current_user is the owner of the item and approved_by_COLLECTION was false (which means the
        # current_user isn't a collection_maintainer), so the item owner is attempting to add their work to a moderated
        # collection
        else
          unapproved_collections << collection
        end
      else
        errors << t(".errors.general_error", name: collection_name)
      end
    end

    # messages to the user
    notices = []
    unless errors.empty?
      flash[:error] = t(".error_list", count: errors.count) + "<br><ul><li />" + errors.join("<li />") + "</ul>"
    end
    unless new_collections.empty?
      notices << t(".success", count: new_collections.size, collections: new_collections.collect(&:title).join(", "))
    end
    unless invited_collections.empty?
      invited_collections.each do |needs_user_approval|
        notices << t(".invited", invited_url: view_context.link_to("invited", collection_items_path(needs_user_approval, invited: true)), collection: needs_user_approval.title)
      end
    end
    unless unapproved_collections.empty?
      collection_item_type = params[:bookmark_id] ? "bookmark" : "work"
      notices << t(".submitted", count: unapproved_collections.size, item: collection_item_type, all_collections: unapproved_collections.map(&:title).join(", "))
    end

    flash[:notice] = notices.join("<br/>").html_safe unless notices.empty?
    flash[:error] = flash[:error].html_safe if flash[:error].present?

    redirect_to(@item)
  end

  def update_multiple
    if @collection&.user_is_maintainer?(current_user)
      update_multiple_with_params(
        allowed_items: @collection.collection_items,
        update_params: collection_update_multiple_params,
        success_path: collection_items_path(@collection)
      )
    elsif @user && @user == current_user
      update_multiple_with_params(
        allowed_items: CollectionItem.for_user(@user),
        update_params: user_update_multiple_params,
        success_path: user_collection_items_path(@user)
      )
    else
      flash[:error] = t(".permission_denied.action")
      redirect_to(@collection || @user)
    end
  end

  # The main work performed by update_multiple. Uses the passed-in parameters
  # to update, and only updates items that can be found in allowed_items (which
  # should be a relation on CollectionItems). When all items are successfully
  # updated, redirects to success_path.
  def update_multiple_with_params(allowed_items:, update_params:, success_path:)
    # Collect any failures so that we can display errors:
    @collection_items = []

    # Make sure that the keys are integers so that we can look up the
    # parameters by ID.
    update_params.transform_keys!(&:to_i)

    # By using where() here and updating each item individually, instead of
    # using allowed_items.update(update_params.keys, update_params.values) --
    # which uses find() under the hood -- we ensure that we'll fail silently if
    # the user tries to update an item they're not allowed to.
    allowed_items.where(id: update_params.keys).each do |item|
      item_data = update_params[item.id]
      if item_data[:remove] == "1"
        @collection_items << item unless item.destroy
      else
        @collection_items << item unless item.update(item_data)
      end
    end

    if @collection_items.empty?
      flash[:notice] = t(".update_success")
      redirect_to success_path
    else
      render action: "index"
    end
  end

  def destroy
    @user = User.find_by(login: params[:user_id]) if params[:user_id]
    @collectible_item = @collection_item.item
    @collection_item.destroy
    flash[:notice] = t(".destroy", title: @collection.title)
    if @user
      redirect_to user_collection_items_path(@user) and return
    elsif (@collection.user_is_maintainer?(current_user))
      redirect_to collection_items_path(@collection) and return
    end
  end

  private

  def collection_item_params
    params.require(:collection_item).permit(:id)
  end

  def user_update_multiple_params
    allowed = %i[user_approval_status remove]
    params.slice(:collection_items).permit(collection_items: allowed).
      require(:collection_items)
  end

  def collection_update_multiple_params
    allowed = %i[collection_approval_status unrevealed anonymous remove]
    params.slice(:collection_items).permit(collection_items: allowed).
      require(:collection_items)
  end
end
