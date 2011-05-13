class OwnedTagSetsController < ApplicationController
  cache_sweeper :tag_set_sweeper

  before_filter :load_tag_set, :only => [ :show, :edit, :update, :destroy, :nominate, :review ]
  before_filter :users_only, :only => [ :new, :create, :nominate ]
  before_filter :moderators_only, :only => [ :edit, :update, :review ]
  before_filter :owners_only, :only => [ :destroy ]
  before_filter :nominated_only, :only => [:nominate, :review]
  
  def load_tag_set
    @tag_set = OwnedTagSet.find(params[:id])
    unless @tag_set
      flash[:notice] = ts("What tag set did you want to look at?")
      redirect_to tag_sets_path and return
    end
  end
  
  def moderators_only
    is_tag_set_mod?(@tag_set, current_user) || access_denied
  end
  
  def owners_only
    !(@tag_set.owners & current_user.pseuds).empty? || access_denied
  end

  def nominated_only
    @tag_set.nominated || access_denied
  end

  def is_tag_set_mod?(owned_tag_set, user)
    !(owned_tag_set.moderators & current_user.pseuds).empty?
  end

  ### ACTIONS

  def index
    @tag_sets = OwnedTagSet.where(:visible => true).paginate(:per_page => (params[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), :page => (params[:page] || 1))
  end
  
  def show
    unless @tag_set.visible || is_tag_set_mod?(@tag_set, current_user)
      flash[:error] = ts("That tag set is not available for public viewing.")
      redirect_to tag_sets_path and return
    end
      
    if params[:tag_type] && TagSet::TAG_TYPES.include?(params[:tag_type])
      @tag_type = params[:tag_type]
      @tags = @tag_set.with_type(@tag_type)
    else
      @tags = @tag_set.tags
    end
  end

  def new
    @tag_set = TagSet.new
  end

  def create
    @tag_set = TagSet.new(params[:tag_set])
    @tag_set.owners << current_user
    if @tag_set.save
      flash[:notice] = ts('Tag set was successfully created.')
      redirect_to(@tag_set) and return
    end 
    render :action => "new" and return
  end

  def edit    
  end
  
  def update
    if @tag_set.update_attributes(params[:tag_set])
      flash[:notice] = ts("Tag set was successfully updated.")
      redirect_to @tag_set
    else
      render :action => :edit
    end
  end

  def destroy
    @tag_set.destroy
    flash[:notice] = ts("Tag set was successfully deleted.")
    redirect_to tag_sets_path
  end

  def nominate
  end
  
  def review
  end


end
