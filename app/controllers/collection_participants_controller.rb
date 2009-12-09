class CollectionParticipantsController < ApplicationController
  before_filter :load_collection
  before_filter :load_participant_and_collection, :only => [:update, :destroy]
  before_filter :collection_maintainers_only, :only => [:index, :add, :update]
  
  def load_participant_and_collection
    if params[:collection_participant]
      @participant = CollectionParticipant.find(params[:collection_participant][:id])
    else
      @participant = CollectionParticipant.find(params[:id])
    end
    @collection = @participant.collection unless @collection
  end    
  
  def index
    @collection_participants = @collection.collection_participants.sort_by {|participant| participant.pseud.name.downcase }
  end
  
  def update
    @role = params[:collection_participant][:participant_role]
    access_denied unless @participant && @participant.user_allowed_to_promote?(current_user, @role)
    if @participant.update_attributes(params[:collection_participant])
      flash[:notice] = t('collection_participants.update_success', :default => "Updated {{participant}}.", :participant => @participant.pseud.name)
    else
      flash[:error] = t('collection_participants.update_failure', :default => "Couldn't update {{participant}}.", :participant => @participant.pseud.name)
    end
    redirect_to collection_participants_path(@collection)
  end
  
  def destroy
    access_denied unless @participant.user_allowed_to_destroy?(current_user)
    @participant.destroy
    flash[:notice] = t('collection_participants.destroy', :default => "Removed {{participant}} from collection.", :participant => @participant.pseud.name)
    redirect_to collection_participants_path(@collection)
  end

  def add
    @participants_added = []
    pseud_results = Pseud.parse_bylines(params[:participants_to_invite])
    pseud_results[:pseuds].each do |pseud|
      unless @collection.participants.include?(pseud)
        participant = CollectionParticipant.new(:collection => @collection, :pseud => pseud, :participant_role => CollectionParticipant::MEMBER)
        @participants_added << participant if participant.save
      end
    end
    @participants_added = @participants_added.sort_by {|participant| participant.pseud.name.downcase }
    flash[:notice] = t('collection_participants.add', :default => "New members added: {{added}}", :added => @participants_added.collect(&:pseud).collect(&:byline).join(', '))
    redirect_to collection_participants_path(@collection)
  end

end
