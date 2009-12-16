class CollectionsController < ApplicationController
  
  before_filter :users_only, :only => [:new, :edit, :create, :update]
  before_filter :load_collection_from_id, :only => [:show, :edit, :update, :destroy]
  before_filter :collection_owners_only, :only => [:edit, :update, :destroy]
  
  def load_collection_from_id
    @collection = Collection.find_by_name(params[:id])
  end

  def index
    if params[:work_id]
      @work = Work.find(params[:work_id])
      @collections = @work.approved_collections
    elsif params[:collection_id]
      @collection = Collection.find(params[:collection_id])
      @collections = @collection.children
    elsif params[:user_id]
      @user = User.find_by_login(params[:user_id])
      @collections = @user.owned_collections
    else
      @collections = Collection.top_level
    end
  end

  def show
    @collection = Collection.find_by_name(params[:id])
    unless @collection
  	  flash[:error] = t('collection_not_found', :default => "Sorry, we couldn't find the collection you were looking for.")
      redirect_to collections_path and return
    end
  end

  def new
    @collection = Collection.new
    if params[:collection_id] && (@collection_parent = Collection.find_by_name(params[:collection_id]))
      @collection.parent_name = @collection_parent.name
    end
  end

  def edit
  end

  def create
    @collection = Collection.new(params[:collection])

    # add the owner
    owner_attributes = []
    (params[:owner_pseuds] || [current_user.default_pseud]).each do |pseud_id|
      pseud = Pseud.find(pseud_id)
      owner_attributes << {:pseud => pseud, :participant_role => CollectionParticipant::OWNER} if pseud
    end
    @collection.collection_participants.build(owner_attributes)
    
    if @collection.save
      flash[:notice] = 'Collection was successfully created.'
      redirect_to(@collection)
    else
      render :action => "new"
    end
  end

  def update
    if @collection.update_attributes(params[:collection])
      flash[:notice] = 'Collection was successfully updated.'
      redirect_to(@collection)
    else
      render :action => "edit"
    end
  end

  def destroy
    @collection = Collection.find_by_name(params[:id])
    @collection.destroy

    redirect_to(collections_url) 
  end

end
