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
    if @tag_set_nomination.character_nominations.any? {|tn| !tn.canonical && (tn.parent_tagname.blank? && !tn.fandom_nomination)} ||
      @tag_set_nomination.relationship_nominations.any? {|tn| !tn.canonical && (tn.parent_tagname.blank? && !tn.fandom_nomination)}
      
      flash[:notice] += ts(" Since some of your nominations are not canonical tags, please consider editing to add their fandoms.")
    end
  end

  def destroy
    unless @tag_set_nomination.unreviewed? || @tag_set.user_is_moderator?(current_user)
      flash[:error] = ts("You cannot delete nominations after some of them have been reviewed, sorry!")
      redirect_to tag_set_nomination_path(@tag_set, @tag_set_nomination)
    else
      @tag_set_nomination.destroy
      flash[:notice] = ts("Your nominations were deleted.")
      redirect_to tag_set_path(@tag_set)
    end
  end
  
  # set up various variables for reviewing nominations
  def setup_for_review
    set_limit
    nom_limit = 30
    @tag_types = TagSet::TAG_TYPES_INITIALIZABLE.select {|type| @limit[type] > 0}
    
    @nominations = HashWithIndifferentAccess.new
    @tag_types.each do |tag_type|
      noms = "#{tag_type}_nomination".classify.constantize.for_tag_set(@tag_set).unreviewed.limit(nom_limit)
      @nominations[tag_type] = HashWithIndifferentAccess.new
      @nominations[tag_type][:canonical] = noms.where(:canonical => true)
      @nominations[tag_type][:existing] = noms.where(:canonical => false, :exists => true)
      @nominations[tag_type][:nonexistent] = noms.where(:exists => false)
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

  # update_multiple gets called from the index/review form. 
  # we expect params like "character_approve_My Awesome Tag" and "fandom_reject_My Lousy Tag" 
  def update_multiple
    unless @tag_set.user_is_moderator?(current_user)
      flash[:error] = ts("You don't have permission to do that.")
      redirect_to tag_set_path(@tag_set) and return
    end

    @errors = []

    # We start by just sorting out the data the mod has sent us
    @approve = HashWithIndifferentAccess.new
    @synonym = HashWithIndifferentAccess.new
    @reject = HashWithIndifferentAccess.new
    @change = HashWithIndifferentAccess.new
    TagSet::TAG_TYPES.each do |tag_type|
      @approve[tag_type] = []
      @synonym[tag_type] = []
      @reject[tag_type] = []
      @change[tag_type] = []
    end
    
    params.each_pair do |key, val|
      next unless val.present?
      if key.match(/^([a-z]+)_(approve|reject|synonym|change)_(.*)$/)
        type = $1
        action = $2
        name = $3
        if TagSet::TAG_TYPES.include?(type)
          # we're safe
          case action
          when "reject"
            @reject[type] << name
          when "synonym"
            @synonym[type] << name
          when "approve"
            @approve[type] << name unless params["#{type}_change_#{name}"] != name
          when "change"
            next if val == name
            # this is the tricky one: make sure we can do this name change
            tagnom = TagNomination.for_tag_set(@tag_set).where(:type => "#{type.classify}Nomination", :tagname => name).first
            if !tagnom 
              @errors << ts("Couldn't find a #{type} nomination for #{name}")
            elsif !tagnom.change_tagname?(val)
              @errors << ts("Invalid name change for #{name} to #{val}: %{msg}", :msg => tagnom.errors.full_messages.join(', '))
            else
              @change[type] << [name, val]
            end
          end
        end
      end
    end
    
    TagSet::TAG_TYPES.each do |tag_type|
      unless (intersect = @approve[tag_type] & @reject[tag_type]).empty?
        @errors << ts("You have both approved and rejected the following %{type} tags: %{intersect}", :type => tag_type, :intersect => intersect.join(", "))
      end
    end
    
    # If we have errors don't move ahead
    unless @errors.empty?
      setup_for_review
      render :action => "index" and return
    end

    # OK, now we're going ahead and making piles of db changes! eep! D:
    TagSet::TAG_TYPES.each do |tag_type|
      @tagnames_to_add = @approve[tag_type] + @synonym[tag_type]
      @tagnames_to_remove = @reject[tag_type]
      
      # do the name changes
      @change[tag_type].each do |oldname, newname|
        tagnom = TagNomination.for_tag_set(@tag_set).where(:type => "#{tag_type.classify}Nomination", :tagname => oldname).first
        if tagnom && tagnom.change_tagname!(newname)
          @tagnames_to_add << newname
          @tagnames_to_remove << oldname
        else
          # ughhhh
          @errors = tagnom.errors.full_messages
          flash[:error] = ts("Oh no! We ran into a problem partway through saving your updates -- please check over your tag set closely!")
          setup_for_review
          render :action => "index" and return           
        end
      end

      # update the tag set
      @tag_set.tag_set.send("#{tag_type}_tagnames_to_add=", @tagnames_to_add.join(","))
      @tag_set.tag_set.tagnames_to_remove = @tagnames_to_remove.join(",")
      unless @tag_set.save
        # ughhhh
        @errors = @tag_set.errors.full_messages
        flash[:error] = ts("Oh no! We ran into a problem partway through saving your updates -- please check over your tag set closely!")
        setup_for_review
        render :action => "index" and return
      end
      
      # update the nominations -- approve any where an approved tag was either a synonym or the tag itself
      TagNomination.for_tag_set(@tag_set).where(:type => "#{tag_type.classify}Nomination").where("tagname IN (?)", @tagnames_to_add).update_all(:approved => true, :rejected => false)
      TagNomination.for_tag_set(@tag_set).where(:type => "#{tag_type.classify}Nomination").where("synonym IN (?)", @tagnames_to_add).update_all(:approved => true, :rejected => false)          
      TagNomination.for_tag_set(@tag_set).where(:type => "#{tag_type.classify}Nomination").where("tagname IN (?)", @tagnames_to_remove).update_all(:rejected => true, :approved => false)
      @notice << '<li>'.html_safe + ts("Successfully added to set: %{approved}", :approved => @tagnames_to_add.join(', ')) + '</li>'.html_safe
      @notice << '<li>'.html_safe + ts("Successfully rejected: %{rejected}", :rejected => @tagnames_to_remove.join(', ')) + '</li>'.html_safe
    end
    
    # If we got here we made it through, YAY
    flash[:notice] = '<ul>' + @notice.join("\n").html_safe + '</ul>'.html_safe
    redirect_to tag_set_nominations_path(@tag_set) and return
  end

end
