class CollectionsController < ApplicationController

  def index
    if params[:work_id]
      @work = Work.find(params[:work_id])
      @collections = @work.collections
    else
      @collections = Collection.all
    end
  end

  def show
    @collection = Collection.find_by_name(params[:id])
  end

  def new
    @collection = Collection.new
  end

  def edit
    @collection = Collection.find_by_name(params[:id])
  end

  def create
    @collection = Collection.new(params[:collection])

    # add the owner
    owner_attributes = []
    params[:owner_pseuds].each do |pseud_id|
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
    @collection = Collection.find_by_name(params[:id])

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
