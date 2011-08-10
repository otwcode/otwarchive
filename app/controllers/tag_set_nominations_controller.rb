class TagSetNominationsController < ApplicationController
  before_filter :users_only
  before_filter :load_tag_set, :except => [ :index ]
  before_filter :load_nomination, :only => [:show, :edit, :update, :destroy]
  before_filter :set_limit, :only => [:new, :edit, :show, :create, :update]
  
  def load_tag_set
    @tag_set = OwnedTagSet.find(params[:tag_set_id])
    unless @tag_set
      flash[:notice] = ts("What tag set did you want to nominate for?")
      redirect_to tag_sets_path and return
    end
  end

  def load_nomination
    @tag_set_nomination = TagSetNomination.find(params[:id])
    unless @tag_set_nomination
      flash[:notice] = ts("Which nominations did you want to work with?")
      redirect_to user_tag_set_nominations_path(@user) and return
    end
  end

  def set_limit
    @limit = HashWithIndifferentAccess.new
	  @limit[:fandom] = @tag_set.fandom_nomination_limit
	  @limit[:character] = @tag_set.character_nomination_limit
	  @limit[:relationship] = @tag_set.relationship_nomination_limit 
	  @limit[:freeform] = @tag_set.freeform_nomination_limit
  end
    
  # used in new/edit to build any nominations that don't already exist before we open the form
  def build_nominations
    @limit[:fandom].times do |i|
      fandom_nom = @tag_set_nomination.fandom_nominations[i] || @tag_set_nomination.fandom_nominations.build
      @limit[:character].times {|j| fandom_nom.character_nominations[j] || fandom_nom.character_nominations.build }
      @limit[:relationship].times {|j| fandom_nom.relationship_nominations[j] || fandom_nom.relationship_nominations.build }
    end

    if @limit[:fandom] == 0
      @limit[:character].times {|j| @tag_set_nomination.character_nominations[j] || @tag_set_nomination.character_nominations.build }
      @limit[:relationship].times {|j| @tag_set_nomination.relationship_nominations[j] || @tag_set_nomination.relationship_nominations.build }
    end

    @limit[:freeform].times {|i| @tag_set_nomination.freeform_nominations[i] || @tag_set_nomination.freeform_nominations.build }
  end

            
  def index
    if @tag_set && @tag_set.user_is_moderator?(current_user)
      redirect_to review_tag_set_path(@tag_set) and return
    elsif params[:user_id]
      @user = User.find_by_login(params[:user_id])
      if @user != current_user
        flash[:error] = ts("You can only view your own nominations, sorry.")
        redirect_to tag_sets_path and return
      else
        @tag_set_nominations = TagSetNomination.owned_by(@user)
      end
    else
      flash[:error] = ts("What nominations did you want to work with?")
      redirect_to tag_sets_path and return
    end
  end

  def show
  end

  def new
    if @tag_set_nomination = TagSetNomination.for_tag_set(@tag_set).owned_by(current_user).first
      redirect_to edit_tag_set_nomination_path(@tag_set, @tag_set_nomination)
    else      
      @tag_set_nomination = TagSetNomination.new(:pseud => current_user.default_pseud, :owned_tag_set => @tag_set)
      build_nominations
    end
  end

  def edit
    # build up extra nominations if not all were used
    build_nominations
  end

  def create
    @tag_set_nomination = TagSetNomination.new(params[:tag_set_nomination])
    if @tag_set_nomination.save
      flash[:notice] = ts('Your nominations were successfully submitted.')
      redirect_to tag_set_nomination_path(@tag_set, @tag_set_nomination)
    else
      render :action => "new"
    end
  end

  def update
    if @tag_set_nomination.update_attributes(params[:tag_set_nomination])
      flash[:notice] = ts("Your nominations were successfully updated.")
      redirect_to tag_set_nomination_path(@tag_set, @tag_set_nomination)
    else
      render :action => "edit"
    end
  end

  def destroy
    @tag_set_nomination.destroy
    flash[:notice] = ts("Your nominations were deleted.")
    redirect_to tag_set_path(@tag_set)
  end
end
