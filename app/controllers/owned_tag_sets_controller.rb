class OwnedTagSetsController < ApplicationController
  cache_sweeper :tag_set_sweeper

  before_filter :load_tag_set, :except => [ :index, :new, :create ]
  before_filter :users_only, :only => [ :new, :create, :nominate ]
  before_filter :moderators_only, :except => [ :index, :new, :create, :show ]
  before_filter :owners_only, :only => [ :destroy ]
  
  def load_tag_set
    @tag_set = OwnedTagSet.find(params[:id])
    unless @tag_set
      flash[:notice] = ts("What tag set did you want to look at?")
      redirect_to tag_sets_path and return
    end
  end
  
  def moderators_only
    @tag_set.user_is_moderator?(current_user) || access_denied
  end
  
  def owners_only
    @tag_set.user_is_owner?(current_user) || access_denied
  end

  def nominated_only
    @tag_set.nominated || access_denied
  end

  ### ACTIONS

  def index
    if @user
      @tag_sets = OwnedTagSet.owned_by(@user).visible
    elsif params[:restriction]
      @restriction = PromptRestriction.find(params[:restriction])
      @tag_sets = OwnedTagSet.visible.in_prompt_restriction(@restriction)
      if @tag_sets.count == 1
        redirect_to tag_set_path(@tag_sets.first, :tag_type => (params[:tag_type] || "fandom")) and return
      end
    else
      @tag_sets = OwnedTagSet.visible
      if params[:query]
        @query = params[:query]
        @tag_sets = @tag_sets.where("title LIKE ?", '%' + params[:query] + '%')
      else
        # show a random selection 
        @tag_sets = @tag_sets.order("RAND()").limit(25)
      end
    end
    @tag_sets = @tag_sets.paginate(:per_page => (params[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), :page => (params[:page] || 1))
  end
  
  def show
    if @tag_set.visible || @tag_set.user_is_moderator?(current_user)
      # 
      # if params[:tag_type] && TagSet::TAG_TYPES.include?(params[:tag_type])
      #   @topmost_tag_type = params[:tag_type]
      # else
      #   @topmost_tag_type =  @tag_set.tag_set.topmost_tag_type
      # end
      # 
      # # Get all the tags of the topmost type with any children in the set, and the associated tags of this set
      # @topmost_tags = @tag_set.tag_set.tags.where(:type => @topmost_tag_type.classify).value_of :id, :name
      # topmost_ids = @topmost_tags.collect {|tt| tt.first}
      # child_ids = @tag_set.tag_set_associations.where(:parent_tag_id => topmost_ids).value_of :tag_id
      # 
      
      # @associations = @tag_set.tag_set_associations
      if @tag_set.tag_set.has_type?("fandom")
        @fandom_hash = Tag.names_by_parent(Fandom.in_tag_set(@tag_set.tag_set), "media") 
      end

      if @tag_set.tag_set.has_type?("character")
        @character_hash = TagSetAssociation.names_by_parent(TagSetAssociation.for_tag_set(@tag_set), "character")
        canonical_hash = Tag.names_by_parent(Character.in_tag_set(@tag_set.tag_set), "fandom") 
        # merge the values of the two hashes (each value is an array) as a set (ie remove duplicates)
        @character_hash.merge!(canonical_hash) {|key, oldval, newval| (oldval | newval) }
      end 

      if @tag_set.tag_set.has_type?("relationship") 
        @relationship_hash = TagSetAssociation.names_by_parent(TagSetAssociation.for_tag_set(@tag_set), "relationship")
        canonical_hash = Tag.names_by_parent(Relationship.in_tag_set(@tag_set.tag_set), "fandom") 
        @relationship_hash.merge!(canonical_hash) {|key, oldval, newval| (oldval | newval) }
      end 
      
    end
  end

  def new
    @tag_set = OwnedTagSet.new
  end

  def create
    @tag_set = OwnedTagSet.new(params[:owned_tag_set])
    @tag_set.add_owner(current_user.default_pseud)
    if @tag_set.save
      flash[:notice] = ts('Tag set was successfully created.')
      redirect_to tag_set_path(@tag_set)
    else 
      render :action => "new"
    end
  end

  def edit
    get_parent_child_tags
  end
  
  def update
    if @tag_set.update_attributes(params[:owned_tag_set])
      flash[:notice] = ts("Tag set was successfully updated.")
      redirect_to tag_set_path(@tag_set)
    else
      get_parent_child_tags
      render :action => :edit
    end
  end

  def destroy
    @tag_set.destroy
    flash[:notice] = ts("Tag set was successfully deleted.")
    redirect_to tag_sets_path
  end
  
  def review_associations
    get_tags_to_associate
  end
  
  def update_associations
    if @tag_set.update_attributes(params[:owned_tag_set])
      flash[:notice] = ts("Nominated associations were added.")
      redirect_to tag_set_path(@tag_set)
    else
      get_tags_to_associate
      render :action => :review_associations
    end
  end

  def batch_load
  end
  
  def do_batch_load
    if params[:batch_associations]
      failed = @tag_set.load_batch_associations!(params[:batch_associations], :do_relationships => (params[:batch_do_relationship] ? true : false))
      if failed.empty?
        flash[:notice] = ts("Tags and associations loaded!")
        redirect_to tag_set_path(@tag_set) and return      
      else
        flash.now[:notice] = ts("We couldn't add all the tags and associations you wanted -- the ones left below didn't work. See the help for suggestions!")
        @failed_batch_associations = failed.join("\n")
        render :action => :batch_load and return
      end
    else
      flash[:error] = ts("What did you want to load?")
      redirect_to :action => :batch_load and return
    end
  end
  
  
  
  
  protected
  
  # for manual associations
  def get_parent_child_tags
    @tags_in_set = Tag.joins(:set_taggings).where("set_taggings.tag_set_id = ?", @tag_set.tag_set_id).order("tags.name ASC")
    @parent_tags_in_set = @tags_in_set.where(:type => 'Fandom').value_of :name, :id
    @child_tags_in_set = @tags_in_set.where("type IN ('Relationship', 'Character')").value_of :name, :id 
  end

  def get_tags_to_associate
    # get the tags for which we have a parent nomination which doesn't already
    # exist in the database 
    @tags_to_associate = Tag.joins(:set_taggings).where("set_taggings.tag_set_id = ?", @tag_set.tag_set_id).
      joins("INNER JOIN tag_nominations ON tag_nominations.tagname = tags.name").
      where("tag_nominations.parented = 0 AND EXISTS 
        (SELECT * from tags WHERE tags.name = tag_nominations.parent_tagname)")

    # also constrain by fandoms added to this set? hmm
    # INNER JOIN set_taggings on set_taggings.tags_id = tags.id
    # WHERE set_taggings.tag_set_id = #{@tag_set.tag_set_id}
        
    # skip already associated tags
    associated_tag_ids = TagSetAssociation.where(:owned_tag_set_id => @tag_set.id).value_of :tag_id    
    @tags_to_associate = @tags_to_associate.where("tags.id NOT IN (?)", associated_tag_ids) unless associated_tag_ids.empty?
          
    # now get out just the tags and nominated parent tagnames in order of # nominations
    @tags_to_associate = @tags_to_associate.select("DISTINCT tags.id, tags.name, tag_nominations.parent_tagname").
      order("tags.name ASC")
      
  end
    
end
