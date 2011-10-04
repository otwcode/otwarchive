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

      @fandom_keys_from_other_tags = []
      if @tag_set.tag_set.has_type?("character")
        @character_hash = TagSetAssociation.names_by_parent(TagSetAssociation.for_tag_set(@tag_set), "character")
        canonical_hash = Tag.names_by_parent(Character.in_tag_set(@tag_set.tag_set), "fandom") 
        # merge the values of the two hashes (each value is an array) as a set (ie remove duplicates)
        @character_hash.merge!(canonical_hash) {|key, oldval, newval| (oldval | newval) }
        remaining = @tag_set.tag_set.with_type("character").with_no_parents.value_of(:name)
        @character_hash["(No linked fandom - might need association)"] ||= []; @character_hash["(No linked fandom - might need association)"] += remaining unless remaining.empty?
        @fandom_keys_from_other_tags += @character_hash.keys
      end 

      if @tag_set.tag_set.has_type?("relationship") 
        @relationship_hash = TagSetAssociation.names_by_parent(TagSetAssociation.for_tag_set(@tag_set), "relationship")
        canonical_hash = Tag.names_by_parent(Relationship.in_tag_set(@tag_set.tag_set), "fandom") 
        @relationship_hash.merge!(canonical_hash) {|key, oldval, newval| (oldval | newval) }
        remaining = @tag_set.tag_set.with_type("relationship").with_no_parents.value_of(:name)
        @relationship_hash["(No linked fandom - might need association)"] ||= []; @relationship_hash["(No linked fandom - might need association)"] += remaining unless remaining.empty?
        @fandom_keys_from_other_tags += @relationship_hash.keys
      end 

      @fandom_keys_from_other_tags.uniq!.sort! {|a,b| a.gsub(/^(the |an |a )/, '') <=> b.gsub(/^(the |an |a )/, '')}

      if @tag_set.tag_set.has_type?("fandom")
        @fandom_hash = Tag.names_by_parent(Fandom.in_tag_set(@tag_set.tag_set), "media") 
        @fandom_hash["(No Media)"] ||= []; @fandom_hash["(No Media)"] += @tag_set.tag_set.with_type("fandom").with_no_parents.value_of(:name)

        # we want to collect and warn about any chars or relationships not in the fandoms
        @character_seen = {}
        @relationship_seen = {}
        @fandom_keys_from_other_tags -= @fandom_hash.values.flatten
        unless @fandom_keys_from_other_tags.empty?
          if @character_hash
            @unassociated_chars = @character_hash.values_at(*@fandom_keys_from_other_tags).flatten.compact.uniq
          end 
          if @relationship_hash
            @unassociated_rels = @relationship_hash.values_at(*@fandom_keys_from_other_tags).flatten.compact.uniq
          end
        end
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
    # get the tags for which we have a parent nomination which doesn't already exist in the database 
    @tags_to_associate = Tag.joins(:set_taggings).where("set_taggings.tag_set_id = ?", @tag_set.tag_set_id).
      joins("INNER JOIN tag_nominations ON tag_nominations.tagname = tags.name").
      joins("INNER JOIN tag_set_nominations ON tag_nominations.tag_set_nomination_id = tag_set_nominations.id").
      where("tag_set_nominations.owned_tag_set_id = ?", @tag_set.id).
      where("tag_nominations.parented = 0 AND tag_nominations.rejected != 1 AND EXISTS 
        (SELECT * from tags WHERE tags.name = tag_nominations.parent_tagname)")
      
    # skip already associated tags
    associated_tag_ids = TagSetAssociation.where(:owned_tag_set_id => @tag_set.id).value_of :tag_id    
    @tags_to_associate = @tags_to_associate.where("tags.id NOT IN (?)", associated_tag_ids) unless associated_tag_ids.empty?
          
    # now get out just the tags and nominated parent tagnames in order of # nominations
    @tags_to_associate = @tags_to_associate.select("DISTINCT tags.id, tags.name, tag_nominations.parent_tagname").
      order("tags.name ASC")
      
  end
    
end
