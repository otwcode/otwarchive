class WorksController < ApplicationController
  include HtmlFormatter

  cache_sweeper :work_sweeper, :only => [:create, :update, :destroy]

  # only registered users and NOT admin should be able to create new works
  before_filter :users_only, :only => [ :new, :create, :import, :import_multiple, :drafts, :preview, :show_multiple ]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update, :preview, :show_multiple, :edit_multiple]
  before_filter :load_work, :only => [ :show, :navigate, :edit, :update, :destroy, :preview ]
  before_filter :check_ownership, :only => [ :edit, :update, :destroy, :preview ]
  before_filter :check_visibility, :only => [ :show, :navigate ]
  before_filter :set_instance_variables, :only => [ :new, :create, :edit, :update, :manage_chapters, :preview, :show, :navigate, :import ]
  before_filter :update_or_create_reading, :only => [ :show ]
#  before_filter :clean_emdashes, :only => [:update, :create]

  def load_work
    @work = Work.find(params[:id])
    @check_ownership_of = @work
    @check_visibility_of = @work
  end
  
  #clean up em dashes for things in the text box.
#  def clean_emdashes
#    params[:work][:chapter_attributes][:content].gsub!(/\xE2\x80"/, '&mdash;')
#  end
  
  # Sets values for @work, @chapter, @coauthor_results, @pseuds, and @selected_pseuds
  # and @tags[category]
  def set_instance_variables

    # if we don't have author_attributes[:ids], which shouldn't be allowed to happen
    # (this can happen if a user with multiple pseuds decides to unselect *all* of them)
    sorry = "Sorry, you cannot remove yourself entirely as an author of the work!<br />
             <br />Please use Remove Me As Author or consider orphaning your work instead if you do not wish to be associated with it anymore."
    if params[:work] && params[:work][:author_attributes] && !params[:work][:author_attributes][:ids]
      flash.now[:notice] = t('needs_author', :default => sorry)
      params[:work][:author_attributes][:ids] = [current_user.default_pseud]
    end
    if params[:work] && !params[:work][:author_attributes]
      flash.now[:notice] = t('needs_author', :default => sorry)
      params[:work][:author_attributes] = {:ids => [current_user.default_pseud]}
    end

    # stuff new bylines into author attributes to be parsed by the work model
    if params[:work] && params[:pseud] && params[:pseud][:byline] && params[:pseud][:byline] != ""
      params[:work][:author_attributes][:byline] = params[:pseud][:byline]
      params[:pseud][:byline] = ""
    end

    # stuff co-authors into author attributes too so we won't lose them
    if params[:work] && params[:work][:author_attributes] && params[:work][:author_attributes][:coauthors]
      params[:work][:author_attributes][:ids].concat(params[:work][:author_attributes][:coauthors]).uniq!
    end

    begin
      if params[:id] # edit, update, preview, manage_chapters
        @work ||= Work.find(params[:id])
        @previous_published_at = @work.first_chapter.published_at
        @previous_backdate_setting = @work.backdate
        if params[:work]  # editing, save our changes
          if params[:preview_button] || params[:cancel_button]
            @work.preview_mode = true
          else
            @work.preview_mode = false
          end 
          @work.attributes = params[:work]
        end
      elsif params[:work] # create
         @work = Work.new(params[:work])
      else # new
        current_user.cleanup_unposted_works
        if params[:load_unposted] && current_user.unposted_work
          @work = current_user.unposted_work
        else
          @work = Work.new
          @work.chapters.build
        end
      end

      @serial_works = @work.serial_works

      @chapters = @work.chapters.in_order.blank? ? @work.chapters : @work.chapters.in_order
      @chapter = @chapters.first
      # If we're in preview mode, we want to pick up any changes that have been made to the first chapter
      if params[:work] && params[:work][:chapter_attributes]
        @chapter.attributes = params[:work][:chapter_attributes]
        # If we're previewing a multichapter work, we want the preview version of the first chapter,
        # so we need to add it back to @chapters
        @chapters[0] = @chapter
      end

      unless current_user == :false
        load_pseuds
        @series = current_user.series.uniq
      end
    rescue
    end
  end

  # GET /works
  def index
    # what we're getting for the view
    @works = []
    @filters = {}
    @pseuds = []

    # default values for our inputs
    @query = nil
    @user = nil
    @tag = nil
    @selected_tags = []
    @selected_pseuds = []
    @sort_column = params[:sort_column] || 'date'
    @sort_direction = params["sort_direction_for_#{@sort_column}".to_sym] || 'DESC'
    
    # numerical ids for now
    unless params[:selected_pseuds].blank?
      begin
        @selected_pseuds = Pseud.find(params[:selected_pseuds]).collect(&:id).uniq
      rescue
        flash[:error] = t('pseuds_not_found', :default => "Sorry, we couldn't find one or more of the authors you selected. Please try again.")
      end
    end

    # if the user is filtering with tags, let's see what they're giving us
    unless params[:selected_tags].blank?
      params[:selected_tags] = params[:selected_tags].values.flatten
      @selected_tags = params[:selected_tags]
    end

    # if we have a query, we are searching with sphinx, which will
    # paginate for us automatically
    if params[:query]
      @query = params[:query]
      begin
        @works = Work.search_with_sphinx(params)
        @works_to_filter = Work.search_with_sphinx(params, filterable=true)
      rescue ThinkingSphinx::ConnectionError
        flash[:error] = t('errors.search_engine_down', :default => "The search engine seems to be down at the moment, sorry!")
        redirect_to :action => :index and return
      end

      unless @works.empty?
        @filters = Work.build_filters(@works_to_filter)
      end
    else
      @most_recent_works = (params[:tag_id].blank? && params[:user_id].blank?)
      # we're browsing instead
      # if we're browsing by a particular tag, just add that
      # tag to the selected_tags list.
      unless params[:tag_id].blank?
        @tag = Tag.find_by_name(params[:tag_id])
        if @tag
          @tag = @tag.merger if @tag.merger
          redirect_to url_for({:controller => :tags, :action => :show, :id => @tag}) and return unless @tag.canonical
          @selected_tags << @tag.id.to_s unless @selected_tags.include?(@tag.id.to_s)
        else
          flash[:error] = t('tag_not_found', :default => "Sorry, there's no tag by that name in our system.")
          redirect_to works_path
          return
        end
      end

      # if we're browsing by a particular user get works by that user
      unless params[:user_id].blank?
        @user = User.find_by_login(params[:user_id])
        if @user
          unless params[:pseud_id].blank?
            @author = @user.pseuds.find_by_name(params[:pseud_id])
            if @author
              @selected_pseuds << @author.id unless @selected_pseuds.include?(@author.id)
            end
          end
        else
          flash[:error] = t('user_not_found', :default => "Sorry, there's no user by that name in our system.")
          redirect_to works_path
          return
        end
      end

      @language_id = params[:language_id] ? Language.find_by_short(params[:language_id]) : nil

      # Now let's build the query
      @works, @filters, @pseuds = Work.find_with_options(:user => @user, :author => @author, :selected_pseuds => @selected_pseuds,
                                                    :tag => @tag, :selected_tags => @selected_tags,                                                                                   
                                                    :language_id => @language_id,
                                                    :sort_column => @sort_column, :sort_direction => @sort_direction,
                                                    :page => params[:page], :per_page => params[:per_page])
    end

    # we now have @works found

    if @works.empty? && !@selected_tags.empty?
      begin
        # build filters so we can go back
        flash.now[:notice] = t('results_not_found', :default => "We couldn't find any results using all those filters, sorry! You can unselect some and filter again to get more matches.")
        @filters = Work.build_filters_from_tags(Tag.find(@selected_tags))
      rescue
        # do we need more than the regular flash notice?
      end
    end
  end

  def drafts
    unless params[:user_id]
      flash[:error] = t('whose_drafts', :default => "Whose drafts did you want to look at?")
      redirect_to :controller => :users, :action => :index
    else
      @user = User.find_by_login(params[:user_id])
      unless current_user == @user
        flash[:error] = t('not_your_drafts', :default => "You can only see your own drafts, sorry!")
        redirect_to current_user
      else
        current_user.cleanup_unposted_works
        if params[:pseud_id]
          @author = @user.pseuds.find_by_name(params[:pseud_id])
          @works = @author.unposted_works.paginate(:page => params[:page])
        else
          @works = @user.unposted_works.paginate(:page => params[:page])
        end
      end
    end
  end

  # GET /works/1
  # GET /works/1.xml
  def show
    unless @work
  	  flash[:error] = t('work_not_found', :default => "Sorry, we couldn't find the story you were looking for.")
      redirect_to works_path and return
    end
    # Users must explicitly okay viewing of adult content
    if params[:view_adult]
      session[:adult] = true
    elsif @work.adult? && !see_adult?
      render :partial => "adult", :layout => "application"
    end

    @tag_categories_limited = Tag::VISIBLE - ["Warning"]

    @page_title = ""
    if logged_in? && !current_user.preference.work_title_format.blank?
      @page_title = current_user.preference.work_title_format
      @page_title.gsub!(/FANDOM/, @work.fandoms.string)
      @page_title.gsub!(/AUTHOR/, @work.pseuds.sort.collect(&:byline).join(', '))
      @page_title.gsub!(/TITLE/, @work.title)
    else
      @page_title = @work.title + " - " + @work.pseuds.sort.collect(&:byline).join(', ') + " - " + @work.fandom_string
    end
    @page_title += " [#{ArchiveConfig.APP_NAME}]"
  end
  
  def navigate
    @chapters = @work.chapters.posted.in_order.blank? ? @work.chapters.posted : @work.chapters.posted.in_order   
  end

  # GET /works/new
  def new
    if params[:import]
      @use_import_form = true
    end
    
    respond_to do |format|
      format.html 
      format.js 
    end
  end

  # POST /works
  def create
    load_pseuds
    @series = current_user.series.uniq

    if !@work.invalid_pseuds.blank? || !@work.ambiguous_pseuds.blank?
      @work.valid? ? (render :partial => 'choose_coauthor', :layout => 'application') : (render :action => :new)
    elsif params[:edit_button]
      render :action => :new
    elsif params[:cancel_button]
      flash[:notice] = t('posting_canceled', :default => "New work posting canceled.")
      redirect_to current_user
    else # now also treating the cancel_coauthor_button case, bc it should function like a preview, really
      saved = @work.save
      unless saved && @work.has_required_tags? && @work.set_revised_at(@chapter.published_at)
        unless @work.has_required_tags?
          if @work.fandoms.blank?
            @work.errors.add(:base, "Creating: Please add all required tags. Fandom is missing.")
          else
            @work.errors.add(:base, "Creating: Required tags are missing.")
          end
        end
        render :action => :new
      else
        flash[:notice] = t('draft_created', :default => 'Draft was successfully created.')
        redirect_to preview_work_path(@work)
      end
    end
  end

  # GET /works/1/edit
  def edit
    if params["remove"] == "me"
      pseuds_with_author_removed = @work.pseuds - current_user.pseuds
      if pseuds_with_author_removed.empty?
        redirect_to :controller => 'orphans', :action => 'new', :work_id => @work.id
      else
        @work.pseuds = pseuds_with_author_removed
        @work.save
        @work.chapters.each do |c|
          c.pseuds = (c.pseuds - current_user.pseuds).uniq
          if c.pseuds.empty?
            c.pseuds = @work.pseuds
          end
          c.save
        end
        flash[:notice] = t('pseuds_not_found', :default => "You have been removed as an author from the work")
        redirect_to current_user
      end
    end
  end

  # PUT /works/1
  def update
    unless @work.errors.empty?
      render :action => :edit and return
    end

    # Need to update @pseuds and @selected_pseuds values so we don't lose new co-authors if the form needs to be rendered again
    load_pseuds
    @series = current_user.series.uniq

    if !@work.invalid_pseuds.blank? || !@work.ambiguous_pseuds.blank?
      @work.valid? ? (render :partial => 'choose_coauthor', :layout => 'application') : (render :action => :new)
    elsif params[:preview_button] || params[:cancel_coauthor_button]
      @preview_mode = true

      #flash[:notice] = "DEBUG: in UPDATE preview:  " + "all: " + @allpseuds.flatten.collect {|ap| ap.id}.inspect + " selected: " + @selected_pseuds.inspect + " co-authors: " + @coauthors.flatten.collect {|ap| ap.id}.inspect + " pseuds: " + @pseuds.flatten.collect {|ap| ap.id}.inspect + "  @work.authors: " + @work.authors.collect {|au| au.id}.inspect + "  @work.pseuds: " + @work.pseuds.collect {|ps| ps.id}.inspect

      if @work.has_required_tags? && @work.invalid_tags.blank?
        render :action => "preview"
      else
        if !@work.invalid_tags.blank?
          @work.check_for_invalid_tags
        end
        if @work.fandoms.blank?
          @work.errors.add_to_base("Updating: Please add all required tags. Fandom is missing.")
        elsif !@work.has_required_tags?
          @work.errors.add_to_base("Updating: Please add all required tags.")
        end
        render :action => :edit
      end
    elsif params[:cancel_button]
      cancel_posting_and_redirect
    elsif params[:edit_button]
      render :partial => 'work_form', :layout => 'application'
    else
      saved = true

      @chapter.save || saved = false
      @work.has_required_tags? || saved = false
      if saved
        # Setting the @work.revised_at datetime if appropriate
        # if @chapter.published_at has been changed or work is being posted
        if params[:post_button] || (defined?(@previous_published_at) && @previous_published_at != @chapter.published_at)
          # if work has only one chapter - so we don't need to take any other chapter dates into account, 
          # OR the date is set to today AND the backdating setting has not been changed
          if @work.chapters.size == 1 || (@chapter.published_at == Date.today && defined?(@previous_backdate_setting) && @previous_backdate_setting == @work.backdate)
            @work.set_revised_at(@chapter.published_at)
          # work has more than one chapter and the published_at date for this chapter is not today
          # so we can't tell if there is a later date than this one elsewhere, and need to grab all
          # OR the date is today but the backdate setting has changed
          else
            # if backdate has been changed to positive
            if defined?(@previous_backdate_setting) && @previous_backdate_setting == false && @work.backdate
              @work.set_revised_at(@chapter.published_at) # set revised_at to the date on this form
            # if backdate has been changed to negative 
            # OR there is no change in the backdate setting but the date isn't today
            else 
              @work.set_revised_at
            end
          end
        # elsif the date hasn't been changed, but the backdate setting has  
        elsif defined?(@previous_backdate_setting) && @previous_backdate_setting != @work.backdate
          if @previous_backdate_setting == false && @work.backdate  # if backdate has been changed to positive
            @work.set_revised_at(@chapter.published_at) # set revised_at to the date on this form
          else # if backdate has been changed to negative, grab most recent chapter date
            @work.set_revised_at
          end
        end
        @work.posted = true

        #bleep = "BEFORE SAVE: author attr: " + params[:work][:author_attributes][:ids].collect {|a| a}.inspect + "  @work.authors: " + @work.authors.collect {|au| au.id}.inspect + "  @work.pseuds: " + @work.pseuds.collect {|ps| ps.id}.inspect

        saved = @work.save
        @work.update_minor_version
      end
      if saved
        if params[:post_button]
          flash[:notice] = t('successfully_posted', :default => 'Work was successfully posted.')
       elsif params[:update_button]
          flash[:notice] = t('successfully_updated', :default => 'Work was successfully updated.')
       end

        #bleep += "  AFTER SAVE: author attr: " + params[:work][:author_attributes][:ids].collect {|a| a}.inspect + "  @work.authors: " + @work.authors.collect {|au| au.id}.inspect + "  @work.pseuds: " + @work.pseuds.collect {|ps| ps.id}.inspect
        #flash[:notice] = "DEBUG: in UPDATE save:  " + bleep

        redirect_to(@work)
      else
        unless @chapter.valid?
          @chapter.errors.each {|err| @work.errors.add(:base, err)}
        end
        unless @work.has_required_tags?
          if @work.fandoms.blank?
            @work.errors.add(:base, "Updating: Please add all required tags. Fandom is missing.")
          else
            @work.errors.add(:base, "Updating: Required tags are missing.")
          end
        end
        render :action => :edit
      end
    end
  end

  # GET /works/1/preview
  def preview
    @preview_mode = true
  end

  # DELETE /works/1
  def destroy
    @work = Work.find(params[:id])
    begin
      @work.destroy
    rescue
      flash[:error] = t('deletion_failed', :default => "We couldn't delete that right now, sorry! Please try again later.")
   end
    redirect_to(user_works_url(current_user))
  end

  # POST /works/import
  def import
    @use_import_form = true
    storyparser = StoryParser.new

    # check to make sure we have some urls to work with
    unless (urls = params[:urls]) && !urls.blank?
      flash.now[:error] = t('enter_an_url', :default => "Did you want to enter a URL?")      
      render :action => :new and return
    end
    
    @urls = urls.split
    if params[:import_multiple] == "works" && @urls.length > 1
      if @urls.length > ArchiveConfig.IMPORT_MAX_WORKS
        flash.now[:error] = t('too_many_works', :default => "You cannot import more than {{max}} works at a time.", :max => ArchiveConfig.IMPORT_MAX_WORKS)
        render :action => :new and return
      end
      # otherwise let's go for it
      results = storyparser.import_from_urls(@urls, :pseuds => [current_user.default_pseud], :post_automatically => true)
      
      @works = results[0]
      @failed_urls = results[1]
      redirect_to :action => :show_multiple, :user_id => current_user.login, :work_ids => @works.collect(&:id) and return
    end
    
    if @urls.length > ArchiveConfig.IMPORT_MAX_CHAPTERS
      flash.now[:error] = t('too_many_chapters', :default => "You cannot import more than {{max}} chapters at a time.", :max => ArchiveConfig.IMPORT_MAX_CHAPTERS)
      render :action => :new and return
    end
    
    url = @urls.first    
    # check to make sure no one has already imported the work
    @work = Work.find_by_imported_from_url(url)
    if @work      
      if @work.users.include?(current_user)
        flash.now[:error] = t('already_uploaded_by_you', :default => "You have already uploaded a work from that url. If you really want to replace it, first delete the previous draft.")
        @work = Work.new
        render :action => :new and return
      else
        flash.now[:error] = t('already_uploaded_by_other', :default => "Another user has already uploaded a work from that url: {{work_link}}.", :work_link => link_to(@work.title, work_path(@work)))
        render :action => :new and return
      end
    end
    
    # try to download and get the work
    begin
      if @urls.length > 1
        @work = storyparser.download_and_parse_chapters_into_story(@urls)
      else
        @work = storyparser.download_and_parse_story(url)
      end
    rescue Timeout::Error
      flash.now[:error] = t('timed_out', :default => "Sorry, but we timed out trying to get that URL. If the site seems to be down, you can try again later.")
      render :action => :new and return
    rescue
      flash.now[:error] = t('upload_failed', :default => "Sorry, but we couldn't get a story at that URL. You can still copy-and-paste the contents into our standard form, though!")
      render :action => :new and return
    end

    # at this point we have at least a partial work for the user to play with
    @use_import_form = false
    begin 
      @work.pseuds << current_user.default_pseud unless @work.pseuds.include?(current_user.default_pseud)
      chapters_saved = 0
      @work.chapters.each do |uploaded_chapter|
        uploaded_chapter.pseuds << current_user.default_pseud unless uploaded_chapter.pseuds.include?(current_user.default_pseud)
        chapters_saved += uploaded_chapter.save ? 1 : 0
      end
      
      if @work.save && chapters_saved == @work.chapters.length
        flash[:notice] = t('successfully_uploaded', :default => "Work successfully uploaded!<br />
          (But please check the results over carefully before posting!)")
        redirect_to preview_work_path(@work) and return
      else
        render :action => :new and return
      end
    rescue
      flash.now[:error] = t('partially_downloaded', :default => "We managed to partially download the work, but there are problems
        preventing us from saving it as a draft. Please look over the results very carefully!")
      @chapter = @work.chapters.first
      render :action => :new and return
    end
  end
  
  def show_multiple
    unless params[:user_id]
      flash[:error] = t('whose_works', :default => "Whose works did you want to look at?")
      redirect_to :controller => :users, :action => :index
    else
      @user = User.find_by_login(params[:user_id])
      unless current_user == @user
        flash[:error] = t('not_your_works', :default => "You can only review your own works, sorry!")
        redirect_to current_user
      else
        if params[:pseud_id]
          @author = @user.pseuds.find_by_name(params[:pseud_id])
          @works = @author.works
        else
          @works = @user.works
        end
      end
    end
    if params[:work_ids]
      @works = @works & Work.find(params[:work_ids])
    end
  end
  
  def edit_multiple
    unless params[:user_id]
      flash[:error] = t('whose_works', :default => "Whose works did you want to look at?")
      redirect_to :controller => :users, :action => :index
    else
      @user = User.find_by_login(params[:user_id])
      unless current_user == @user
        flash[:error] = t('not_your_works', :default => "You can only review your own works, sorry!")
        redirect_to current_user
      end
    end
    
    @works = Work.find(params[:work_ids]) & @user.works
  end
  
  def update_multiple
    unless params[:user_id]
      flash[:error] = t('whose_works', :default => "Whose works did you want to look at?")
      redirect_to :controller => :users, :action => :index
    else
      @user = User.find_by_login(params[:user_id])
      unless current_user == @user
        flash[:error] = t('not_your_works', :default => "You can only review your own works, sorry!")
        redirect_to current_user
      end
    end

    @works = Work.find(params[:work_ids]) & @user.works
    @works.each do |work|
      # actual stuff will happen here shortly
      work.update_attributes!(params[:work].reject {|key,value| value.blank?})
    end

    redirect_to show_multiple_user_works_path(@user)
  end

  

  protected

  def load_pseuds
    @allpseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds).uniq
    @pseuds = current_user.pseuds
    @coauthors = @allpseuds.select{ |p| p.user.id != current_user.id}
    to_select = @work.authors.blank? ? @work.pseuds.blank? ? [current_user.default_pseud] : @work.pseuds : @work.authors
    @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }.uniq
  end

  # create a reading object when showing a work, but only if the user has reading
  # history enabled and is not the author of the work
  def update_or_create_reading
    return unless @work
    if logged_in? && current_user.preference.history_enabled
      unless current_user.is_author_of?(@work)
        reading = Reading.find_or_initialize_by_work_id_and_user_id(@work.id, current_user.id)
        reading.major_version_read, reading.minor_version_read = @work.major_version, @work.minor_version
        reading.save
      end
    end
    true
  end

  def cancel_posting_and_redirect
    if @work and @work.posted
      flash[:notice] = t('not_updated', :default => "<p>The work was not updated.</p>")
      redirect_to user_works_path(current_user)
    else
      flash[:notice] = t('not_posted', :default => "<p>This work was not posted.</p>
      <p>It will be saved here in your drafts for one week, then cleaned up.</p>")
      begin
        current_user.cleanup_unposted_works
      rescue ThinkingSphinx::ConnectionError
      end
      redirect_to drafts_user_works_path(current_user)
    end
  end

end
