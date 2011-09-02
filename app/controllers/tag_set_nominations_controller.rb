class TagSetNominationsController < ApplicationController
  before_filter :users_only
  before_filter :load_tag_set, :except => [ :index ]
  before_filter :load_nomination, :only => [:show, :edit, :update, :destroy]
  before_filter :set_limit, :only => [:new, :edit, :show, :create, :update, :review]
  
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
    if params[:user_id]
      @user = User.find_by_login(params[:user_id])
      if @user != current_user
        flash[:error] = ts("You can only view your own nominations, sorry.")
        redirect_to tag_sets_path and return
      else
        @tag_set_nominations = TagSetNomination.owned_by(@user)
      end
    elsif (@tag_set = OwnedTagSet.find(params[:tag_set_id]))
      if @tag_set.user_is_moderator?(current_user)
        # reviewing nominations
        setup_for_review
      else
        flash[:error] = ts("You can't see those nominations, sorry.")
        redirect_to tag_sets_path and return
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
      request_noncanonical_info
      redirect_to tag_set_nomination_path(@tag_set, @tag_set_nomination)
    else
      build_nominations
      render :action => "new"
    end
  end

  def update
    if @tag_set_nomination.update_attributes(params[:tag_set_nomination])
      flash[:notice] = ts("Your nominations were successfully updated.")
      request_noncanonical_info
      redirect_to tag_set_nomination_path(@tag_set, @tag_set_nomination)
    else
      build_nominations
      render :action => "edit"
    end
  end

  def request_noncanonical_info
    if @tag_set_nomination.fandom_nominations.any? {|tn| !tn.canonical && tn.parent_tagname.blank?} ||
      @tag_set_nomination.character_nominations.any? {|tn| !tn.canonical && (tn.parent_tagname.blank? && !tn.fandom_nomination)} ||
      @tag_set_nomination.relationship_nominations.any? {|tn| !tn.canonical && (tn.parent_tagname.blank? && !tn.fandom_nomination)}
      
      flash[:notice] += ts(" Since some of your nominations are not canonical tags, please consider editing to add some extra information.")
    end
  end

  def destroy
    @tag_set_nomination.destroy
    flash[:notice] = ts("Your nominations were deleted.")
    redirect_to tag_set_path(@tag_set)
  end
  
  # set up various variables for reviewing nominations
  def setup_for_review
    set_limit
    @tag_types = TagSet::TAG_TYPES_INITIALIZABLE.select {|type| @limit[type] > 0}
    @tag_type = params[:tag_type] || @tag_types.first
    # make sure it's a valid tag type before we go send()ing it around
    @tag_type = @tag_types.first unless @tag_types.include?(@tag_type)
    noms = @tag_set.send("#{@tag_type}_nominations").unreviewed
    @nominations = HashWithIndifferentAccess.new
    @nominations[:canonical] = noms.where(:canonical => true)
    @nominations[:existing] = noms.where(:canonical => false, :exists => true)
    @nominations[:nonexistent] = noms.where(:exists => false)    
  end


  # update_multiple gets called from the index/review form. 
  # we get params like "approve_My Awesome Tag" and "reject_My Lousy Tag" for any tag nominations which were
  # marked to be rejected
  def update_multiple
    unless @tag_set.user_is_moderator?(current_user)
      flash[:error] = ts("You don't have permission to do that.")
      redirect_to tag_set_path(@tag_set) and return
    end
    setup_for_review
    
    @tagnames_to_approve = []
    @tagnames_to_reject = []
    params.each_pair do |key,val|
      if val && key.match(/^(approve|synonym)_(.*)$/)
        @tagnames_to_approve << $2
      elsif val && key.match(/^reject_(.*)$/)
        @tagnames_to_reject << $1
      end
    end
    
    unless (intersect = (@tagnames_to_approve & @tagnames_to_reject)).empty?
      flash[:error] = ts("You have both approved and rejected the following tags: %{intersect}", :intersect => intersect.join(", "))
      render :action => "index" and return
    end
    
    @tag_set.tag_set.send("#{@tag_type}_tagnames_to_add=", @tagnames_to_approve.join(","))
    @tag_set.tag_set.tagnames_to_remove = @tagnames_to_reject.join(",")
    
    if @tag_set.save && 
          TagNomination.where("tagname IN (?)", @tagnames_to_approve).update_all(:approved => true, :rejected => false) &&
          TagNomination.where("tagname IN (?)", @tagnames_to_reject).update_all(:rejected => true, :approved => false)
      flash[:notice] = ts("Successfully approved: %{approved}", :approved => @tagnames_to_approve.join(', ')) + " " +
        ts("Successfully rejected: %{rejected}", :rejected => @tagnames_to_reject.join(', '))
      redirect_to tag_set_path(@tag_set) and return
    else
      flash[:error] = ts("We were unable to save your updates.")
      setup_for_review
      render :action => "index"
    end
  end
  
  def destroy_multiple
    unless @tag_set.user_is_owner?(current_user)
      flash[:error] = ts("You don't have permission to do that.")
      redirect_to tag_set_path(@tag_set) and return
    end

    @tag_set.clear_nominations!
    flash[:notice] = ts("All nominations for this tag set have been cleared.")
    redirect_to tag_set_path(@tag_set)
  end
  
end
