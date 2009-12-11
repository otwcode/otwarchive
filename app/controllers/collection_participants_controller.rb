class CollectionParticipantsController < ApplicationController
  before_filter :load_collection
  before_filter :load_participant_and_collection, :only => [:update, :destroy]
  before_filter :allowed_to_promote, :only => [:update]
  before_filter :allowed_to_destroy, :only => [:destroy]
  before_filter :has_other_owners, :only => [:update, :destroy]
  before_filter :collection_maintainers_only, :only => [:index, :add, :update]
  before_filter :users_only, :only => [:join]


  def owners_required
    flash[:error] = t('collection_participants.owners_required', :default => "You can't remove the only owner!")
    redirect_to collection_participants_path(@collection)
    false
  end
  
  def not_allowed
    flash[:error] = t('collection_participants.not_allowed', :default => "Sorry, you're not allowed to do that.")
    redirect_to collection_participants_path(@collection)
    false
  end
  
  def no_participant
    flash[:error] = t('no_participant', :default => "Which participant did you want to work with?")
    redirect_to root_path
  end
  
  def load_participant_and_collection
    if params[:collection_participant]
      @participant = CollectionParticipant.find(params[:collection_participant][:id])
      @new_role = params[:collection_participant][:participant_role]
    else
      @participant = CollectionParticipant.find(params[:id])
    end
    no_participant and return unless @participant
    @collection = @participant.collection
  end    

  def allowed_to_promote
    @participant.user_allowed_to_promote?(current_user, @new_role) || not_allowed
  end
  
  def allowed_to_destroy
    @participant.user_allowed_to_destroy?(current_user) || not_allowed
  end

  def has_other_owners
    !@participant.is_owner? || (@collection.owners != [@participant.pseud]) || owners_required
  end
  
  
  
  ## ACTIONS

  def join
    unless @collection
      flash[:error] = t('no_collection', :default => "Which collection did you want to join?")
      redirect_to :back and return
    end
    participants = CollectionParticipant.in_collection(@collection).for_user(current_user)
    if participants.empty?
      @participant = CollectionParticipant.new(:collection => @collection, :pseud => current_user.default_pseud, 
                        :participant_role => CollectionParticipant::NONE)
      @participant.save
      flash[:notice] = t('applied_to_join_collection', :default => "You have applied to join {{collection}}.", :collection => @collection.title)
    else
      participants.each do |participant|
        if participant.is_invited?
          participant approve_membership!
          flash[:notice] = t('collection_participants.accepted_invite', :default => "You are now a member of {{collection}}.", :collection => @collection.title)
          redirect_to :back and return
        end
      end
      
      flash[:notice] = t('collection_participants.no_invitation', :default => "You have already joined (or applied to) this collection.")
    end
    
    redirect_to :back
  end 
    
  def index
    @collection_participants = @collection.collection_participants.sort_by {|participant| participant.pseud.name.downcase }
  end
  
  def update
    if @participant.update_attributes(params[:collection_participant])
      flash[:notice] = t('collection_participants.update_success', :default => "Updated {{participant}}.", :participant => @participant.pseud.name)
    else
      flash[:error] = t('collection_participants.update_failure', :default => "Couldn't update {{participant}}.", :participant => @participant.pseud.name)
    end
    redirect_to collection_participants_path(@collection)
  end
  
  def destroy    
    @participant.destroy
    flash[:notice] = t('collection_participants.destroy', :default => "Removed {{participant}} from collection.", :participant => @participant.pseud.name)
    redirect_to :back
  end

  def add
    @participants_added = []
    @participants_invited = []
    pseud_results = Pseud.parse_bylines(params[:participants_to_invite])
    pseud_results[:pseuds].each do |pseud|
      if @collection.participants.include?(pseud)
        participant = CollectionParticipant.find(:collection => @collection, :pseud => pseud)
        if participant && participant.is_none?
          @participants_added << participant if participant.approve_membership! 
        end
      else
        participant = CollectionParticipant.new(:collection => @collection, :pseud => pseud, :participant_role => CollectionParticipant::MEMBER)
        @participants_invited << participant if participant.save
      end
    end
    flash[:notice] = ""
    unless @participants_invited.empty?
      @participants_invited = @participants_invited.sort_by {|participant| participant.pseud.name.downcase }
      flash[:notice] += t('collection_participants.invite', :default => "<strong>New members invited:</strong> {{invited}}", 
                :added => @participants_invited.collect(&:pseud).collect(&:byline).join(', '))
    end

    unless @participants_added.empty?
      @participants_added = @participants_added.sort_by {|participant| participant.pseud.name.downcase }
      flash[:notice] += t('collection_participants.add', :default => "<strong>Members approved:</strong> {{added}}",
                :added => @participants_added.collect(&:pseud).collect(&:byline).join(', '))
    end
    
    redirect_to collection_participants_path(@collection)
  end

end
