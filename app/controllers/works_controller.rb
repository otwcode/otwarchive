# encoding=utf-8

class WorksController < ApplicationController

  # only registered users and NOT admin should be able to create new works
  before_filter :load_collection
  before_filter :users_only, :except => [ :index, :show, :navigate ]
  before_filter :check_user_status, :except => [ :index, :show, :navigate ]
  before_filter :load_work, :except => [ :new, :create, :index, :show_multiple, :edit_multiple, :update_multiple ]
  before_filter :check_ownership, :except => [ :index, :show, :navigate, :new, :create, :import, :import_multiple ]
  before_filter :check_visibility, :only => [ :show, :navigate ]
  before_filter :set_author_attributes, :only => [ :new, :create, :edit, :update, :manage_chapters, :preview, :show, :navigate ]
  before_filter :set_instance_variables, :only => [ :new, :create, :edit, :update, :manage_chapters, :preview, :show, :navigate, :import ]
  before_filter :set_instance_variables_tags, :only => [ :edit_tags, :update_tags, :preview_tags ]

  cache_sweeper :work_sweeper
  cache_sweeper :collection_sweeper
  cache_sweeper :static_sweeper
  cache_sweeper :feed_sweeper

  def search
    @languages = Language.default_order
    @query = {}
    # to understand this, the code you are looking for is in lib/query.rb
    if params[:query]
      @query = Query.standardize(params[:query])
      begin
        page = params[:page] || 1
        errors, @works = Query.search_with_sphinx(Work, @query, page)
        flash.now[:error] = errors.join(" ") unless errors.blank?
      rescue Riddle::ConnectionError
        flash.now[:error] = ts("The search engine seems to be down at the moment, sorry!")
      end
    end
  end

  # GET /works
  def index
    # what we're getting for the view
    @works = []
    @filters = {}
    @pseuds = []

    # default values for our inputs
    @user = nil
    @tag = nil
    @selected_tags = []
    @selected_pseuds = []
    @sort_column = case params[:sort_column]
      when 'author'
        'authors_to_sort_on'
      when 'title'
        'title_to_sort_on' 
      when 'word_count'
        'word_count'
      when 'hit_count'
        'hit_count'
      when 'created_at'
        'created_at'
      else
        'revised_at'
      end
    @sort_direction = (valid_sort_direction(params[:sort_direction]) ? params[:sort_direction] : 'DESC')
    if !params[:sort_direction].blank? && !valid_sort_direction(params[:sort_direction])
      params[:sort_direction] = 'DESC'
    end
    # numerical ids for now
    unless params[:selected_pseuds].blank?
      begin
        @selected_pseuds = Pseud.find(params[:selected_pseuds]).collect(&:id).uniq
      rescue
        flash[:error] = ts("Sorry, we couldn't find one or more of the authors you selected. Please try again.")
      end
    end

    # if the user is filtering with tags, let's see what they're giving us
    unless params[:selected_tags].blank?
      if params[:selected_tags].respond_to?(:values)
        params[:selected_tags] = params[:selected_tags].values.flatten
      end
      @selected_tags = params[:selected_tags]
    end

    # if we're browsing by a particular tag, just add that
    # tag to the selected_tags list.
    unless params[:tag_id].blank?
      @tag = Tag.find_by_name(params[:tag_id])
      if @tag
        @tag = @tag.merger if @tag.merger
        redirect_to url_for({:controller => :tags, :action => :show, :id => @tag}) and return unless @tag.canonical
        @selected_tags << @tag.id.to_s unless @selected_tags.include?(@tag.id.to_s)
      else
        flash[:error] = ts("Sorry, there's no tag by that name in our system.")
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
        flash[:error] = ts("Sorry, there's no user by that name in our system.")
        redirect_to works_path
        return
      end
    end

    @language = Language.find_by_short(params[:language_id]) if params[:language_id]
    # Workaround for the getting-all-English-works problem
    # TODO: better limits
    if @language && @language == Language.default
      @most_recent_works = true
    end

    # Now let's build the query
    @works, @filters, @pseuds = Work.find_with_options(:user => @user, 
                                                    :author => @author, 
                                                    :selected_pseuds => @selected_pseuds,
                                                    :tag => @tag, 
                                                    :selected_tags => @selected_tags,
                                                    :collection => @collection,
                                                    :language_id => @language,
                                                    :sort_column => @sort_column, 
                                                    :sort_direction => @sort_direction,
                                                    :page => params[:page], 
                                                    :per_page => params[:per_page],
                                                    :boolean_type => params[:boolean_type],
                                                    :complete => params[:complete])


    # Limit the number of works returned and let users know that it's happening
    if @works.total_entries >= ArchiveConfig.SEARCH_RESULTS_MAX
      flash.now[:notice] = "More than #{ArchiveConfig.SEARCH_RESULTS_MAX} works were returned. The first #{ArchiveConfig.SEARCH_RESULTS_MAX} works
      we found using the current sort and filters are shown."
    end

    # we now have @works found
    @over_anon_threshold = @works.collect(&:authors_to_sort_on).uniq.count > ArchiveConfig.ANONYMOUS_THRESHOLD_COUNT

    if @works.empty? && !@selected_tags.empty?
      begin
        # build filters so we can go back
        flash.now[:notice] = ts("We couldn't find any results using all those filters, sorry! You can unselect some and filter again to get more matches.")
        @filters = Work.build_filters_from_tags(Tag.find(@selected_tags))
      rescue
        # do we need more than the regular flash notice?
      end
    end
  end

  def drafts
    unless params[:user_id]
      flash[:error] = ts("Whose drafts did you want to look at?")
      redirect_to :controller => :users, :action => :index
    else
      @user = User.find_by_login(params[:user_id])
      unless current_user == @user
        flash[:error] = ts("You can only see your own drafts, sorry!")
        redirect_to current_user
      else
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
    # Users must explicitly okay viewing of adult content
    if params[:view_adult]
      session[:adult] = true
    elsif @work.adult? && !see_adult?
      render "_adult", :layout => "application" and return
    end

    # Users must explicitly okay viewing of entire work
    if @work.number_of_posted_chapters > 1
      if params[:view_full_work] || (logged_in? && current_user.preference.try(:view_full_works))
        @chapters = @work.chapters_in_order
      else
        flash.keep
        redirect_to [@work, @chapter] and return
      end
    end

    @tag_categories_limited = Tag::VISIBLE - ["Warning"]

    @page_title = @work.unrevealed? ? ts("Mystery Work") :
      get_page_title(@work.fandoms.size > 3 ? ts("Multifandom") : @work.fandoms.string,
        @work.anonymous? ?  ts("Anonymous")  : @work.pseuds.sort.collect(&:byline).join(', '),
        @work.title)
      if @work.unrevealed?
        @tweet_text = ts("Mystery Work")
      else
        @tweet_text = @work.title + " by " +
                      (@work.anonymous? ? ts("Anonymous") : @work.pseuds.map(&:name).join(', ')) + " - " +
                      (@work.fandoms.size > 2 ? ts("Multifandom") : @work.fandoms.string)
        @tweet_text = @tweet_text.truncate(95)
      end
    render :show
    Rails.logger.debug "Work remote addr: #{request.remote_ip}"
    @work.increment_hit_count(request.remote_ip)
    Reading.update_or_create(@work, current_user) if current_user
  end

  def navigate
    @chapters = @work.chapters_in_order(false)
  end

  # GET /works/new
  def new
    @hide_dashboard = true
    load_pseuds
    @series = current_user.series.uniq
    @unposted = current_user.unposted_work
    # for clarity, add the collection and recipient
    if params[:assignment_id] && (@challenge_assignment = ChallengeAssignment.find(params[:assignment_id])) && @challenge_assignment.offering_user == current_user
      @work.challenge_assignments << @challenge_assignment
      @work.collections << @challenge_assignment.collection
      @work.recipients = @challenge_assignment.requesting_pseud.byline
    else
      @work.collection_names = @collection.name if @collection
    end
    if params[:claim_id] && (@challenge_claim = ChallengeClaim.find(params[:claim_id])) && User.find(@challenge_claim.claiming_user_id) == current_user
      @work.challenge_claims << @challenge_claim
      @work.collections << @challenge_claim.collection
    else
      @work.collection_names = @collection.name if @collection
    end
    if params[:import]
      render :new_import and return
    elsif params[:load_unposted]
      @work = @unposted
      render :edit and return
    else
      render :new and return
    end
  end

  # POST /works
  def create
    load_pseuds
    @series = current_user.series.uniq

    if params[:edit_button]
      render :new
    elsif params[:cancel_button]
      flash[:notice] = ts("New work posting canceled.")
      redirect_to current_user
    else # now also treating the cancel_coauthor_button case, bc it should function like a preview, really
      unless params[:preview_button]
        @work.posted = true
        @chapter.posted = true
      end
      valid = (@work.errors.empty? && @work.invalid_pseuds.blank? && @work.ambiguous_pseuds.blank? && @work.has_required_tags?)

      if valid && @work.set_revised_at(@chapter.published_at) && @work.set_challenge_info && @work.save
        #hack for empty chapter authors in cucumber series tests
        @chapter.pseuds = @work.pseuds if @chapter.pseuds.blank?
        if params[:preview_button]
          redirect_to preview_work_path(@work), :notice => ts('Draft was successfully created.')
        else
          redirect_to work_path(@work), :notice => ts('Work was successfully posted.')
        end
      else
        if @work.errors.empty? && (!@work.invalid_pseuds.blank? || !@work.ambiguous_pseuds.blank?)
          render :partial => 'choose_coauthor', :layout => 'application'
        else
          unless @work.has_required_tags?
            if @work.fandoms.blank?
              @work.errors.add(:base, "Please add all required tags. Fandom is missing.")
            else
              @work.errors.add(:base, "Required tags are missing.")
            end
          end
          render :new
        end
      end
    end
  end

  # GET /works/1/edit
  def edit
    @hide_dashboard = true
    @chapters = @work.chapters_in_order(false) if @work.number_of_chapters > 1
    load_pseuds
    @series = current_user.series.uniq
    if params["remove"] == "me"
      pseuds_with_author_removed = @work.pseuds - current_user.pseuds
      if pseuds_with_author_removed.empty?
        redirect_to :controller => 'orphans', :action => 'new', :work_id => @work.id
      else
        @work.remove_author(current_user)
        flash[:notice] = ts("You have been removed as an author from the work")
        redirect_to current_user
      end
    end
  end

  # GET /works/1/edit_tags
  def edit_tags
  end

  # PUT /works/1
  def update
    # Need to get @pseuds and @series values before rendering edit
    load_pseuds
    @series = current_user.series.uniq
    unless @work.errors.empty?
      render :edit and return
    end

    if !@work.invalid_pseuds.blank? || !@work.ambiguous_pseuds.blank?
      @work.valid? ? (render :_choose_coauthor) : (render :new)
    elsif params[:preview_button] || params[:cancel_coauthor_button]
      @preview_mode = true
      if @work.has_required_tags? && @work.invalid_tags.blank?
        @chapter = @work.chapters.first unless @chapter
        render :preview
      else
        if !@work.invalid_tags.blank?
          @work.check_for_invalid_tags
        end
        if @work.fandoms.blank?
          @work.errors.add(:base, "Updating: Please add all required tags. Fandom is missing.")
        elsif !@work.has_required_tags?
          @work.errors.add(:base, "Updating: Please add all required tags.")
        end
        render :edit
      end
    elsif params[:cancel_button]
      cancel_posting_and_redirect
    elsif params[:edit_button]
      render :edit
    else
      saved = @chapter.save
      @work.has_required_tags? || saved = false
      if saved
        # Setting the @work.revised_at datetime if appropriate
        # if @chapter.published_at has been changed or work is being posted
        if params[:post_button] || (defined?(@previous_published_at) && @previous_published_at != @chapter.published_at)
          # if work has only one chapter - so we don't need to take any other chapter dates into account,
          # OR the date is set to today AND the backdating setting has not been changed
          if @work.number_of_chapters == 1 || (@chapter.published_at == Date.today && defined?(@previous_backdate_setting) && @previous_backdate_setting == @work.backdate)
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
        if !@work.challenge_claims.empty?
          @included = 0
          @work.challenge_claims.each do |claim|
            @work.collections.each do |collection|
              if collection == claim.collection
                @included = 1
              end
            end
            if @included == 0
              @work.collections << claim.collection
            end
            @included = 0
          end
        end
        @work.posted = true
        @work.minor_version = @work.minor_version + 1
        @work.set_challenge_info
        saved = @work.save
      end
      if saved
        if params[:post_button]
          flash[:notice] = ts('Work was successfully posted.')
        elsif params[:update_button]
          flash[:notice] = ts('Work was successfully updated.')
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
        render :edit
      end
    end
  end

  def update_tags
    unless @work.errors.empty?
      render :edit_tags and return
    end

    if params[:preview_button]
      @preview_mode = true

      if @work.has_required_tags? && @work.invalid_tags.blank?
        render :preview_tags
      else
        if !@work.invalid_tags.blank?
          @work.check_for_invalid_tags
        end
        if @work.fandoms.blank?
          @work.errors.add(:base, "Updating: Please add all required tags. Fandom is missing.")
        elsif !@work.has_required_tags?
          @work.errors.add(:base, "Updating: Please add all required tags.")
        end
        render :edit_tags
      end
    elsif params[:cancel_button]
      cancel_posting_and_redirect
    elsif params[:edit_button]
      render :edit_tags
    else
      saved = true

      (@work.has_required_tags? && @work.invalid_tags.blank?) || saved = false
      if saved
        @work.posted = true
        @work.minor_version = @work.minor_version + 1
        saved = @work.save
        # @work.update_minor_version
      end
      if saved
        flash[:notice] = ts('Work was successfully updated.')
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
        render :edit_tags
      end
    end
  end


  # GET /works/1/preview
  def preview
    @preview_mode = true
    load_pseuds
  end

  def preview_tags
    @preview_mode = true
  end

  def confirm_delete
  end

  # DELETE /works/1
  def destroy
    @work = Work.find(params[:id])
    begin
      was_draft = !@work.posted?
      title = @work.title
      @work.destroy
      flash[:notice] = ts("Your work %{title} was deleted.", :title => title)
    rescue
      flash[:error] = ts("We couldn't delete that right now, sorry! Please try again later.")
    end
    if was_draft
      redirect_to drafts_user_works_path(current_user)
    else
      redirect_to user_works_path(current_user)
    end
  end

  # POST /works/import
  def import
    # check to make sure we have some urls to work with
    @urls = params[:urls].split
    unless @urls.length > 0
      flash.now[:error] = ts("Did you want to enter a URL?")
      render :new_import and return
    end

    # is this an archivist importing?
    if params[:importing_for_others] && !current_user.archivist
      flash.now[:error] = ts("You may not import stories by other users unless you are an approved archivist.")
      render :new_import and return
    end

    # make sure we're not importing too many at once
    if params[:import_multiple] == "works" && (!current_user.archivist && @urls.length > ArchiveConfig.IMPORT_MAX_WORKS || @urls.length > ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST)
      flash.now[:error] = ts("You cannot import more than %{max} works at a time.", :max => current_user.archivist ? ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST : ArchiveConfig.IMPORT_MAX_WORKS)
      render :new_import and return
    elsif params[:import_multiple] == "chapters" && @urls.length > ArchiveConfig.IMPORT_MAX_CHAPTERS
      flash.now[:error] = ts("You cannot import more than %{max} chapters at a time.", :max => ArchiveConfig.IMPORT_MAX_CHAPTERS)
      render :new_import and return
    end

    # otherwise let's build the options
    if params[:pseuds_to_apply]
      pseuds_to_apply = Pseud.find_by_name(params[:pseuds_to_apply])
    end
    options = {:pseuds => pseuds_to_apply,
      :post_without_preview => params[:post_without_preview],
      :importing_for_others => params[:importing_for_others],
      :restricted => params[:restricted],
      :override_tags => params[:override_tags],
      :fandom => params[:work][:fandom_string],
      :warning => params[:work][:warning_strings],
      :character => params[:work][:character_string],
      :rating => params[:work][:rating_string],
      :relationship => params[:work][:relationship_string],
      :category => params[:work][:category_string],
      :freeform => params[:work][:freeform_string],
      :encoding => params[:encoding]
    }

    # now let's do the import
    if params[:import_multiple] == "works" && @urls.length > 1
      import_multiple(@urls, options)
    else # a single work possibly with multiple chapters
      import_single(@urls, options)
    end

  end

protected

  # import a single work (possibly with multiple chapters)
  def import_single(urls, options)
    # try the import
    storyparser = StoryParser.new
    begin
      if urls.size == 1
        @work = storyparser.download_and_parse_story(urls.first, options)
      else
        @work = storyparser.download_and_parse_chapters_into_story(urls, options)
      end
    rescue Timeout::Error
      flash.now[:error] = ts("Import has timed out. This may be due to connectivity problems with the source site. Please try again in a few minutes, or check Known Issues to see if there are import problems with this site.")
      render :new_import and return
    rescue StoryParser::Error => exception
      flash.now[:error] = ts("We couldn't successfully import that work, sorry: %{message}", :message => exception.message)
      render :new_import and return
    end

    unless @work && @work.save
      flash[:error] = ts("We were only partially able to import this work and couldn't save it. Please review below!")
      @chapter = @work.chapters.first
      load_pseuds
      @series = current_user.series.uniq
      render :new and return
    end

    # Otherwise, we have a saved work, go us
    send_external_invites([@work])
    @chapter = @work.first_chapter if @work
    if @work.posted
      redirect_to work_path(@work) and return
    else
      redirect_to preview_work_path(@work) and return
    end
  end

  # import multiple works
  def import_multiple(urls, options)
    # try a multiple import
    storyparser = StoryParser.new
    @works, failed_urls, errors = storyparser.import_from_urls(urls, options)

    # collect the errors neatly, matching each error to the failed url
    unless failed_urls.empty?
      error_msgs = 0.upto(failed_urls.length).map {|index| "<dt>#{failed_urls[index]}</dt><dd>#{errors[index]}</dd>"}.join("\n")
      flash.now[:error] = "<h3>#{ts('Failed Imports')}</h3><dl>#{error_msgs}</dl>".html_safe
    end

    # if EVERYTHING failed, boo. :( Go back to the import form.
    if @works.empty?
      render :new_import and return
    end

    # if we got here, we have at least some successfully imported works
    flash[:notice] = ts("Importing completed successfully for the following works! (But please check the results over carefully!)")
    send_external_invites(@works)

    # fall through to import template
  end

  # if we are importing for others, we need to send invitations
  def send_external_invites(works)
    if params[:importing_for_others]
      @external_authors = works.collect(&:external_authors).flatten.uniq
      if !@external_authors.empty?
        @external_authors.each do |external_author|
          external_author.find_or_invite(current_user)
        end
        message = " " + ts("We have notified the author(s) you imported stories for. If any were missed, you can also add co-authors manually.")
        flash[:notice] ? flash[:notice] += message : flash[:notice] = message
      end
    end
  end

public


  def post_draft
    @user = current_user
    @work = Work.find(params[:id])
    unless @user.is_author_of?(@work)
      flash[:error] = ts("You can only post your own works.")
      redirect_to current_user and return
    end

    if @work.posted
      flash[:error] = ts("That work is already posted. Do you want to edit it instead?")
      redirect_to edit_user_work_path(@user, @work) and return
    end

    @work.posted = true
    @work.minor_version = @work.minor_version + 1
    # @work.update_minor_version
    unless @work.valid? && @work.save
      flash[:error] = ts("There were problems posting your work.")
      redirect_to edit_user_work_path(@user, @work) and return
    end

    flash[:notice] = ts("Your work was successfully posted.")
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
        @errors << ts("The work %{title} could not be edited: %{error}", :title => work.title, :error => work.errors_on.to_s)
      end
    end
    unless @errors.empty?
      flash[:error] = ts("There were problems editing some works: %{errors}", :errors => @errors.join(", "))
    end
    redirect_to show_multiple_user_works_path(@user)
  end

  # marks a work to read later, or unmarks it if the work is already marked
  def marktoread
    @work = Work.find(params[:id])
    Reading.mark_to_read_later(@work, current_user)
    flash[:notice] = ts("Your history was updated. It may take a short while to show up.")
    redirect_to(request.env["HTTP_REFERER"] || root_path)
  end

  protected

  def load_pseuds
    @allpseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds).uniq
    @pseuds = current_user.pseuds
    @coauthors = @allpseuds.select{ |p| p.user.id != current_user.id}
    to_select = @work.authors.blank? ? @work.pseuds.blank? ? [current_user.default_pseud] : @work.pseuds : @work.authors
    @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }.uniq
  end

  def load_work
    @work = Work.find_by_id(params[:id])
    if @work.nil?
      flash[:error] = ts("Sorry, we couldn't find the work you were looking for.")
      redirect_to root_path and return
    elsif @collection && !@work.collections.include?(@collection)
      redirect_to @work and return
    end
    @check_ownership_of = @work
    @check_visibility_of = @work
  end

  # Sets values for @work, @chapter, @coauthor_results, @pseuds, and @selected_pseuds
  # and @tags[category]
  def set_instance_variables
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
      if params[:load_unposted] && current_user.unposted_work
        @work = current_user.unposted_work
      else
        @work = Work.new
        @work.chapters.build
      end
    end

    @serial_works = @work.serial_works

    @chapter = @work.first_chapter
    # If we're in preview mode, we want to pick up any changes that have been made to the first chapter
    if params[:work] && params[:work][:chapter_attributes]
      @chapter.attributes = params[:work][:chapter_attributes]
    end
  end

  # set the author attributes
  def set_author_attributes
    # if we don't have author_attributes[:ids], which shouldn't be allowed to happen
    # (this can happen if a user with multiple pseuds decides to unselect *all* of them)
    sorry = ts("You haven't selected any pseuds for this work. Please use Remove Me As Author or consider orphaning your work instead if you do not wish to be associated with it anymore.")
    if params[:work] && params[:work][:author_attributes] && !params[:work][:author_attributes][:ids]
      flash.now[:notice] = sorry
      params[:work][:author_attributes][:ids] = [current_user.default_pseud]
    end
    if params[:work] && !params[:work][:author_attributes]
      flash.now[:notice] = sorry
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

  def cancel_posting_and_redirect
    if @work and @work.posted
      flash[:notice] = ts("The work was not updated.")
      redirect_to user_works_path(current_user)
    else
      flash[:notice] = ts("The work was not posted. It will be saved here in your drafts for one week, then cleaned up.")
      redirect_to drafts_user_works_path(current_user)
    end
  end

  # Takes an array of tags and returns a comma-separated list, without the markup
  def tag_list(tags)
    tags = tags.uniq.compact
    if !tags.blank? && tags.respond_to?(:collect)
      last_tag = tags.pop
      tag_list = tags.collect{|tag|  tag.name + ", "}.join
      tag_list += last_tag.name
      tag_list.html_safe
    else
      ""
    end
  end

end
