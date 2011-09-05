class OwnedTagSetsController < ApplicationController
  cache_sweeper :tag_set_sweeper

  before_filter :load_tag_set, :only => [ :show, :edit, :update, :destroy, :request_wrangling ]
  before_filter :users_only, :only => [ :new, :create, :nominate ]
  before_filter :moderators_only, :only => [ :edit, :update, :review ]
  before_filter :owners_only, :only => [ :destroy ]
  before_filter :nominated_only, :only => [:review]
  
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
    unless @tag_set.visible || @tag_set.user_is_moderator?(current_user)
      flash[:error] = ts("That tag set is not available for public viewing.")
      redirect_to tag_sets_path and return
    end
      
    if params[:tag_type] && TagSet::TAG_TYPES.include?(params[:tag_type])
      @tag_type = params[:tag_type]
      @tags = @tag_set.tag_set.with_type(@tag_type)
    else
      @tags = @tag_set.tag_set.tags
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
  end
  
  def update
    if @tag_set.update_attributes(params[:owned_tag_set])
      flash[:notice] = ts("Tag set was successfully updated.")
      redirect_to tag_set_path(@tag_set)
    else
      render :action => :edit
    end
  end

  def destroy
    @tag_set.destroy
    flash[:notice] = ts("Tag set was successfully deleted.")
    redirect_to tag_sets_path
  end
  
  def request_wrangling
    already_requested_ids = TagWranglingRequest.where(:owned_tag_set_id => @tag_set.id)[:tag_id].map(&:tag_id)
    @unrequested_tags = Tag.joins(:set_taggings).where("set_taggings.tag_set_id = ?", @tag_set.tag_set_id).order("tags.name ASC")
    @unrequested_tags = @unrequested_tags.where("tags.id NOT IN (?)", already_requested_ids) unless already_requested_ids.empty?
    
    # now get most likely tags to request for:
    # noncanonical and unparented tags
    @tags = @unrequested_tags.joins("LEFT JOIN common_taggings ON common_taggings.common_tag_id = tags.id").
                where("filterable_id IS NULL OR tags.canonical = 0")
    @requests = []
    @tags[:id].each {|tag_id| @requests << @tag_set.tag_wrangling_requests.build(:tag_id => tag_id)}

    if @requests.count < 30
      @inline_autocomplete = true
    else
      @inline_autocomplete = false
    end      
  end
  

end
