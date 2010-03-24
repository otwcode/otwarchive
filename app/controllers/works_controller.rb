class WorksController < ApplicationController
  include HtmlFormatter

  # only registered users and NOT admin should be able to create new works
  before_filter :load_collection
  before_filter :users_only, :only => [ :new, :create, :import, :import_multiple, :drafts, :preview, :show_multiple ]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update, :preview, :show_multiple, :edit_multiple ]
  before_filter :load_work, :only => [ :show, :navigate, :edit, :update, :destroy, :preview, :edit_tags, :update_tags ]
  before_filter :check_ownership, :only => [ :edit, :update, :destroy, :preview ]
  before_filter :check_visibility, :only => [ :show, :navigate ]
  before_filter :set_instance_variables, :only => [ :new, :create, :edit, :update, :manage_chapters, :preview, :show, :navigate, :import ]
  before_filter :set_instance_variables_tags, :only => [ :edit_tags, :update_tags, :preview_tags ]
  after_filter :update_or_create_reading, :only => [ :show ]
  after_filter :increment_hit_counter, :only => [:show]

  def load_work
    @work = Work.find(params[:id])
    @check_ownership_of = @work
    @check_visibility_of = @work
  end

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
          @work.save_parents if @work.preview_mode
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

  # Sets values for @work and @tags[category]
  def set_instance_variables_tags
    begin
      if params[:id] # edit_tags, update_tags, preview_tags
        @work ||= Work.find(params[:id])
        if params[:work]  # editing, save our changes
          if params[:preview_button] || params[:cancel_button] || params[:edit_button]
            @work.preview_mode = true
          else
            @work.preview_mode = false
          end 
          @work.attributes = params[:work]
          @work.save_parents if @work.preview_mode
        end
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
    @sort_direction = params[:sort_direction] || 'DESC'
    
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
      if params[:selected_tags].respond_to?(:values)
        params[:selected_tags] = params[:selected_tags].values.flatten
      end
      @selected_tags = params[:selected_tags]
    end

    # if we have a query, we are searching with sphinx
    if params[:query]
      @query = params[:query]
      begin
        @works = Work.search_with_sphinx(params)
        if @works.size >= ArchiveConfig.SEARCH_RESULTS_MAX
          @too_many = true 
        end
        @search = true;
        return
      rescue Riddle::ConnectionError
        flash[:error] = t('errors.search_engine_down', :default => "The search engine seems to be down at the moment, sorry!")
        redirect_to :action => :index and return
      end
    else
      @most_recent_works = (params[:tag_id].blank? && params[:user_id].blank? && params[:language_id].blank? && params[:collection_id].blank?)
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
      # Workaround for the getting-all-English-works problem
      # TODO: better limits
      if @language_id && @language_id == Language.default
        @language_id = nil
        @most_recent_works = true
      end
      
      # Now let's build the query
      @works, @filters, @pseuds = Work.find_with_options(:user => @user, :author => @author, :selected_pseuds => @selected_pseuds,
                                                      :tag => @tag, :selected_tags => @selected_tags,
                                                      :collection => @collection,                                                    
                                                      :language_id => @language_id,
                                                      :sort_column => @sort_column, :sort_direction => @sort_direction,
                                                      :page => params[:page], :per_page => params[:per_page],
                                                      :boolean_type => params[:boolean_type])
                                                        

      # Limit the number of works returned and let users know that it's happening
      if @most_recent_works && @works.total_entries >= ArchiveConfig.SEARCH_RESULTS_MAX
        flash.now[:notice] = "More than #{ArchiveConfig.SEARCH_RESULTS_MAX} works were returned. The first #{ArchiveConfig.SEARCH_RESULTS_MAX} works 
        we found using the current sort and filters are shown."        
      end
    end

    # we now have @works found
    @over_anon_threshold = @works.collect(&:authors_to_sort_on).uniq.count > ArchiveConfig.ANONYMOUS_THRESHOLD_COUNT

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
  	  flash[:error] = t('work_not_found', :default => "Sorry, we couldn't find the work you were looking for.")
      redirect_to works_path and return
    end

    unless params[:view_full_work]
      unless logged_in? && current_user.preference && current_user.preference.view_full_works
        if @work.chapters.posted.count > 1
          if params[:view_adult]
            session[:adult] = true
          end
          redirect_to [@work, @chapters.first] and return
        end
      end
    end

    # Users must explicitly okay viewing of adult content
    if params[:view_adult]
      session[:adult] = true
    elsif @work.adult? && !see_adult?
      render :partial => "adult", :layout => "application"
    end

    @tag_categories_limited = Tag::VISIBLE - ["Warning"]

    @page_title = @work.unrevealed? ? t('works.mystery_title', :default => "Mystery Work") : 
      get_page_title(@work.fandoms.string, @work.anonymous? ?  t('works.anonymous', :default => "Anonymous")  : @work.pseuds.sort.collect(&:byline).join(', '), @work.title)
  end
  
  def increment_hit_counter
    # increment view
    @work.increment_hit_count(request.env['REMOTE_ADDR'])    
  end
  
  def navigate
    @chapters = @work.chapters.posted.in_order.blank? ? @work.chapters.posted : @work.chapters.posted.in_order   
  end

  # GET /works/new
  def new    
    @use_import_form = true if params[:import]
    @work.collection_names = @collection.name if @collection  
    
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
        @work.remove_author(current_user)
        flash[:notice] = t('author_successfully_removed', :default => "You have been removed as an author from the work")
        redirect_to current_user
      end
    end
  end

  # GET /works/1/edit_tags
  def edit_tags
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

  def update_tags
    unless @work.errors.empty?
      render :action => :edit_tags and return
    end

    if params[:preview_button]
      @preview_mode = true

      if @work.has_required_tags? && @work.invalid_tags.blank?
        render :action => "preview_tags"
      else
        if !@work.invalid_tags.blank?
          @work.check_for_invalid_tags
        end
        if @work.fandoms.blank?
          @work.errors.add_to_base("Updating: Please add all required tags. Fandom is missing.")
        elsif !@work.has_required_tags?
          @work.errors.add_to_base("Updating: Please add all required tags.")
        end
        render :action => :edit_tags
      end
    elsif params[:cancel_button]
      cancel_posting_and_redirect
    elsif params[:edit_button]
      render :action => :edit_tags # render :partial => 'work_tags_form', :layout => 'application'
    else
      saved = true

      (@work.has_required_tags? && @work.invalid_tags.blank?) || saved = false
      if saved
        @work.posted = true
        saved = @work.save
        @work.update_minor_version
      end
      if saved
        flash[:notice] = t('successfully_updated', :default => 'Work was successfully updated.')
        redirect_to(@work)
      else
        if !@work.invalid_tags.blank?
          @work.check_for_invalid_tags
        end
        unless @work.has_required_tags?
          if @work.fandoms.blank?
            @work.errors.add(:base, "Updating: Please add all required tags. Fandom is missing.")
          else
            @work.errors.add(:base, "Updating: Required tags are missing.")
          end
        end
        render :action => :edit_tags
      end
    end
  end


  # GET /works/1/preview
  def preview
    @preview_mode = true
  end
  
  def preview_tags
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
    @urls = params[:urls].split
    unless @urls.length > 0
      flash.now[:error] = t('enter_an_url', :default => "Did you want to enter a URL?")      
      params[:import] = true
      render :action => :new and return
    end
    
    # is this an archivist importing? 
    if params[:importing_for_others] && !current_user.archivist
      flash.now[:error] = t('import.only_archivist', :default => "You may not import stories by other users unless you are an approved archivist.")
      render :action => :new and return
    end

    # make sure we're not importing too many at once
    if params[:import_multiple] == "works" && (!current_user.archivist && @urls.length > ArchiveConfig.IMPORT_MAX_WORKS || @urls.length > ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST)
      flash.now[:error] = t('too_many_works', :default => "You cannot import more than {{max}} works at a time.", :max => current_user.archivist ? ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST : ArchiveConfig.IMPORT_MAX_WORKS)
      render :action => :new and return
    elsif params[:import_multiple] == "chapters" && @urls.length > ArchiveConfig.IMPORT_MAX_CHAPTERS
      flash.now[:error] = t('too_many_chapters', :default => "You cannot import more than {{max}} chapters at a time.", :max => ArchiveConfig.IMPORT_MAX_CHAPTERS)
      render :action => :new and return
    end

    # otherwise let's build the options
    if params[:pseuds_to_apply]
      @pseuds_to_apply = Pseud.find_by_name(params[:pseuds_to_apply])
    end
    options = {:pseuds => @pseuds_to_apply, 
      :post_without_preview => params[:post_without_preview],
      :importing_for_others => params[:importing_for_others],
      :restricted => params[:restricted],
      :override_tags => params[:override_tags],
      :fandom => params[:fandom],
      :character => params[:character],
      :rating => params[:rating],
      :pairing => params[:pairing],
      :category => params[:category],
      :freeform => params[:freeform]      
    }
    
    # now let's do the import
    @works = []
    @failed_urls = []
    @errors = []
    if params[:import_multiple] == "works"
      results = storyparser.import_from_urls(@urls, options)
      @works = results[0]
      @failed_urls = results[1]
      @errors = results[2]
    else # a single work with multiple chapters
      begin
        #debugger
        @work = storyparser.download_and_parse_chapters_into_story(@urls, options)
        if @work.save
          @works << @work
        else
          @failed_urls << @urls.first
          @errors << t('import.could_not_save', :default => "We couldn't save that chaptered work. Anything we managed to import is below.")
          redirect_to :action => :new and return
        end
      rescue Timeout::Error
        flash[:error] = t('timed_out', :default => "Sorry, but we timed out trying to get that URL. If the site seems to be down, you can try again later.")
        redirect_to :action => :new and return
      rescue Exception => exception
        flash[:error] = t('upload_failed', :default => "We couldn't successfully import that story, sorry: {{message}}", :message => exception.message)
        redirect_to :action => :new and return
      end
    end
    
    # if we are importing for others, we need to send invitations
    if params[:importing_for_others]
      @external_authors = @works.collect(&:external_authors).flatten.uniq
      if !@external_authors.empty?
        @external_authors.each do |external_author|
          external_author.find_or_invite(current_user)
        end
        flash[:notice] = t('import.for_others', :default => "We have notified the author(s) you imported stories for. You can also add them as co-authors manually.")
      end
    end
    
    # collect the errors
    if !@failed_urls.empty?
      flash[:error] = "<h3>Failed Imports</h3>\n<dl>"
      0.upto(@failed_urls.length) do |index| 
        flash[:error] += "<dt>#{@failed_urls[index]}</dt>\n"
        flash[:error] += "<dd>#{@errors[index]}</dd>"
      end
      flash[:error] += "</dl>"
    else
      flash[:notice] = t('successfully_uploaded', :default => "Importing completed successfully! (But please check the results over carefully!)") 
    end
    
    if @urls.length == 1 || params[:import_multiple] == "chapters"
      # importing a single work, let the user preview or view it
      @use_import_form = false
      
      @work = @works.first
      @chapter = @work.chapters.first if @work
      if @work.nil? || !@work.valid?
        redirect_to :action => :new and return
      elsif @work.posted
        redirect_to work_path(@work) and return
      else
        redirect_to preview_work_path(@work) and return
      end
    end
  end

  def post_draft
    @user = current_user
    @work = Work.find(params[:id])
    unless @user.is_author_of?(@work)
      flash[:error] = t('post_draft.not_your_work', :default => "You can only post your own works.")
      redirect_to current_user
    end
    
    if @work.posted
      flash[:error] = t('post_draft.already_posted', :default => "That work is already posted. Do you want to edit it instead?")
      redirect_to edit_user_work_path(@user, @work)
    end
    
    @work.posted = true
    @work.update_minor_version    
    unless @work.valid? && @work.save
      flash[:error] = t('post_draft.problem', :default => "There were problems posting your work.")
      redirect_to edit_user_work_path(@user, @work)
    end
    
    flash[:notice] = t('post_draft.success', :default => "Your work was successfully posted.")
    redirect_to @work
  end

  
  
  # WORK ON MULTIPLE WORKS
  
  def show_multiple
    @user = current_user
    if params[:pseud_id]
      @author = @user.pseuds.find_by_name(params[:pseud_id])
      @works = @author.works
    else
      @works = @user.works
    end
    if params[:work_ids]
      @works = @works & Work.find(params[:work_ids])
    end
  end
  
  def edit_multiple
    @user = current_user
    @works = Work.find(params[:work_ids]) & @user.works
    
  end
  
  def update_multiple
    @user = current_user
    @works = Work.find(params[:work_ids]) & @user.works
    @errors = []
    @works.each do |work|
      # actual stuff will happen here shortly
      unless work.update_attributes!(params[:work].reject {|key,value| value.blank?})
        @errors << t('update_multiple.problem', :default => "The work {{title}} could not be edited: {{error}}", :title => work.title, :error => work.errors_on.to_s)
      end
    end
    unless @errors.empty?
      flash[:error] = t('update_multiple.error_message', :default => "There were problems editing some works: {{errors}}", :errors => @errors.join(", "))
    end
    redirect_to show_multiple_user_works_path(@user)        
  end

  # def post_multiple
  #   @user = current_user
  #   @works = Work.find(params[:work_ids]) & @user.works
  #   @errors = []
  #   
  #   @works.each do |work|
  #     work.posted = true
  #     work.update_minor_version
  #     unless work.save!
  #       @errors << t('post_multiple.problem', :default => "The work {{title}} could not be posted: {{error}}", :title => work.title, :error => work.errors_on.to_s)
  #     end
  #   end
  #   unless @errors.empty?
  #     flash[:error] = t('post_multiple.error_message', :default => "There were problems posting some works: {{errors}}", :errors => @errors.join(", "))
  #   end
  #   redirect_to show_multiple_user_works_path(@user)
  # end
  # 
  # def destroy_multiple
  #   @user = current_user
  #   @works = Work.find(params[:work_ids]) & @user.works
  #   @errors = []
  #   @works.each do |work|
  #     begin
  #       work.destroy
  #     rescue
  #       @errors << t('destroy_multiple.deletion_failed', :default => "There were problems deleting work {{title}}.", :title => work.title)
  #     end
  #   end
  #   
  #   unless @errors.empty?
  #     flash[:error] = t('destroy_multiple.error_message', :default => "There were problems deleting some works: {{errors}}", :errors => @errors.join(", "))
  #   end
  #   redirect_to show_multiple_user_works_path(@user)
  # end

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
        reading.touch
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
