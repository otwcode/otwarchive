class ChaptersController < ApplicationController
  # only registered users and NOT admin should be able to create new chapters
  before_filter :users_only, :except => [ :index, :show, :destroy ]
  before_filter :load_work, :except => [:index, :auto_complete_for_pseud_name, :update_positions]
  before_filter :set_instance_variables, :only => [ :new, :create, :edit, :update, :preview, :post ]
  # only authors of a work should be able to edit its chapters
  before_filter :check_ownership, :only => [ :edit, :update, :manage, :destroy ]
  before_filter :check_visibility, :only => [ :show]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]

  cache_sweeper :feed_sweeper

  # GET /work/:work_id/chapters
  # GET /work/:work_id/chapters.xml
  def index
    # this route is never used
    redirect_to work_path(params[:work_id])
  end

  # GET /work/:work_id/chapters/manage
  def manage
    @chapters = @work.chapters_in_order(false).select(&:posted)
  end

  # GET /work/:work_id/chapters/:id
  # GET /work/:work_id/chapters/:id.xml
  def show
    if params[:view_adult]
      session[:adult] = true
    elsif @work.adult? && !see_adult?
      render "works/_adult", :layout => "application" and return
    end

    if params[:selected_id]
      redirect_to url_for(:controller => :chapters, :action => :show, :work_id => @work.id, :id => params[:selected_id]) and return
    end
    @chapter = @work.chapters.find(params[:id])
    @chapters = @work.chapters_in_order(false)
    if !logged_in? || !current_user.is_author_of?(@work)
      @chapters = @chapters.select(&:posted)
    end
    if !@chapters.include?(@chapter)
      access_denied
    else
      if @chapters.length > 1
        chapter_position = @chapters.index(@chapter)
        @previous_chapter = @chapters[chapter_position-1] unless chapter_position == 0
        @next_chapter = @chapters[chapter_position+1]
      end
      @commentable = @work
      @comments = @chapter.comments

      @page_title = @work.unrevealed? ? ts("Mystery Work - Chapter %{position}", :position => @chapter.position.to_s) :
        get_page_title(@work.fandoms.string,
          @work.anonymous? ? ts("Anonymous") : @work.pseuds.sort.collect(&:byline).join(', '),
          @work.title + " - Chapter " + @chapter.position.to_s)

      @kudos = @work.kudos.with_pseud.includes(:pseud => :user).order("created_at DESC")

      if current_user.respond_to?(:subscriptions)
        @subscription = current_user.subscriptions.where(:subscribable_id => @work.id,
                                                         :subscribable_type => 'Work').first ||
                        current_user.subscriptions.build(:subscribable => @work)
      end

      # TEMPORARY hack-like thing to fix the fact that chaptered works weren't hit-counted or added to history at all
      if chapter_position == 0
        Reading.update_or_create(@work, current_user) if current_user
        Rails.logger.debug "Chapter remote addr: #{request.remote_ip}"
        @work.increment_hit_count(request.remote_ip)
      end

      respond_to do |format|
        format.html
        format.js
      end
    end
  end

  # GET /work/:work_id/chapters/new
  # GET /work/:work_id/chapters/new.xml
  def new
  end

  # GET /work/:work_id/chapters/1/edit
  def edit
    if params["remove"] == "me"
      @chapter.pseuds = @chapter.pseuds - current_user.pseuds
      @chapter.save
      flash[:notice] = ts("You have been removed as an author from the chapter")
     redirect_to @work
    end
  end

  def draft_flash_message(work)
    delete_schedule = work.posted ? "" : " (unposted work drafts are automatically deleted one " +
      "month after creation; this chapter's work is scheduled for deletion at " +
      "#{view_context.date_in_user_time_zone(work.created_at + 1.month)})"
      # "#{(work.created_at + 1.week).in_time_zone(User.current_user.preference.time_zone)})"
    flash[:notice] = ts("This is a draft showing what this chapter will look like when it's posted to the Archive. You should probably read the whole thing to check for problems before posting. The chapter draft will be stored until you post or discard it, or until its parent work is deleted#{delete_schedule}.")
  end

  # POST /work/:work_id/chapters
  # POST /work/:work_id/chapters.xml
  def create
  	@work.wip_length = params[:chapter][:wip_length]
    load_pseuds

    if !@chapter.invalid_pseuds.blank? || !@chapter.ambiguous_pseuds.blank?
      @chapter.valid? ? (render :_choose_coauthor) : (render :new)
    elsif params[:edit_button]
      render :new
    elsif params[:cancel_button]
      redirect_back_or_default('/')
    else  # :post_without_preview, :preview or :cancel_coauthor_button
      @work.major_version = @work.major_version + 1
      @chapter.posted = true if params[:post_without_preview_button] 
      @work.set_revised_at_by_chapter(@chapter)
      if @chapter.save && @work.save
        if @chapter.posted
          post_chapter
          redirect_to [@work, @chapter]
        else
          draft_flash_message(@work)
          redirect_to [:preview, @work, @chapter]
        end
      else
        render :new
      end
    end
  end

  # PUT /work/:work_id/chapters/1
  # PUT /work/:work_id/chapters/1.xml
  def update
    @chapter.attributes = params[:chapter]
    @work.wip_length = params[:chapter][:wip_length]
    load_pseuds

    if !@chapter.invalid_pseuds.blank? || !@chapter.ambiguous_pseuds.blank?
      @chapter.valid? ? (render :_choose_coauthor) : (render :new)
    elsif params[:preview_button] || params[:cancel_coauthor_button]
      @preview_mode = true
      if @chapter.posted?
        flash[:notice] = ts("This is a preview of what this chapter will look like after your changes have been applied. You should probably read the whole thing to check for problems before posting.")
      else
        draft_flash_message(@work)
      end
      render :preview
    elsif params[:cancel_button]
      # Not quite working yet - should send the user back to wherever they were before they hit edit
      redirect_back_or_default('/')
    elsif params[:edit_button]
      flash[:notice] = nil
      render :edit
    else
      @work.minor_version = @work.minor_version + 1
      @chapter.posted = true if params[:post_button] || params[:post_without_preview_button]
      posted_changed = @chapter.posted_changed?
      @work.set_revised_at_by_chapter(@chapter)
      if @chapter.save && @work.save
        flash[:notice] = ts("Chapter was successfully #{posted_changed ? 'posted' : 'updated'}.")
        redirect_to [@work, @chapter]
      else
        render :edit
      end
    end
  end

  def update_positions
    if params[:chapters]
      @work = Work.find(params[:work_id])
      @work.reorder(params[:chapters])
      flash[:notice] = ts("Chapter order has been successfully updated.")
    elsif params[:chapter]
      params[:chapter].each_with_index do |id, position|
        Chapter.update(id, :position => position + 1)
        (@chapters ||= []) << Chapter.find(id)
      end
    end
    respond_to do |format|
      format.html { redirect_to(@work) and return }
      format.js { render :nothing => true }
    end
  end

  # GET /chapters/1/preview
  def preview
    @preview_mode = true
  end

  # POST /chapters/1/post
  def post
    if params[:cancel_button]
      redirect_to @work
    elsif params[:edit_button]
      redirect_to [:edit, @work, @chapter]
    else
      @chapter.posted = true
      @work.set_revised_at_by_chapter(@chapter)
      if @chapter.save && @work.save
        post_chapter
        redirect_to(@work)
      else
        render :preview
      end
    end
  end

  # DELETE /work/:work_id/chapters/1
  # DELETE /work/:work_id/chapters/1.xml
  def destroy
    @chapter = @work.chapters.find(params[:id])
    if @chapter.is_only_chapter?
      flash[:error] = ts("You can't delete the only chapter in your story. If you want to delete the story, choose 'Delete work'.")
      redirect_to(edit_work_url(@work))
    else
      was_draft = !@chapter.posted?
      if @chapter.destroy
        @work.minor_version = @work.minor_version + 1
        @work.set_revised_at
        @work.save
        flash[:notice] = ts("The chapter #{was_draft ? 'draft ' : ''}was successfully deleted.")
      else
        flash[:error] = ts("Something went wrong. Please try again.")
      end
      redirect_to :controller => 'works', :action => 'show', :id => @work
    end
  end

  private

  def load_pseuds
    @allpseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds + (@chapter.authors ||= []) + (@chapter.pseuds ||= [])).uniq
    @pseuds = current_user.pseuds
    @coauthors = @allpseuds.select{ |p| p.user.id != current_user.id}
    to_select = @chapter.authors.blank? ? @chapter.pseuds.blank? ? @work.pseuds : @chapter.pseuds : @chapter.authors
    @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }
  end

  # fetch work these chapters belong to from db
  def load_work
    @work = params[:work_id] ? Work.find(params[:work_id]) : Chapter.find(params[:id]).work
    @check_ownership_of = @work
    @check_visibility_of = @work
  end

  # Sets values for @chapter, @coauthor_results, @pseuds, and @selected_pseuds
  def set_instance_variables
    # stuff new bylines into author attributes to be parsed by the chapter model
    if params[:chapter] && params[:pseud] && params[:pseud][:byline] && params[:chapter][:author_attributes]
      params[:chapter][:author_attributes][:byline] = params[:pseud][:byline]
      params[:pseud][:byline] = ""
    end

    # stuff co-authors into author attributes too so we won't lose them
    if params[:chapter] && params[:chapter][:author_attributes] && params[:chapter][:author_attributes][:coauthors]
      params[:chapter][:author_attributes][:ids].concat(params[:chapter][:author_attributes][:coauthors]).uniq!
    end

    if params[:id] # edit, update, preview, post
      @chapter = @work.chapters.find(params[:id])
      if params[:chapter]  # editing, save our changes
        @chapter.attributes = params[:chapter]
      end
    elsif params[:chapter] # create
      @chapter = @work.chapters.build(params[:chapter])
    else # new
      @chapter = @work.chapters.build(:position => @work.number_of_chapters + 1)
    end

    @allpseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds + (@chapter.authors ||= []) + (@chapter.pseuds ||= [])).uniq
    @pseuds = current_user.pseuds
    @coauthors = @allpseuds.select{ |p| p.user.id != current_user.id}
    to_select = @chapter.authors.blank? ? @chapter.pseuds.blank? ? @work.pseuds : @chapter.pseuds : @chapter.authors
    @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }

  end

  def post_chapter
    if !@work.posted
      @work.update_attribute(:posted, true)
    end
    flash[:notice] = ts('Chapter has been posted!')
  end
end
