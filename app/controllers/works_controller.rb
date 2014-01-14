# encoding=utf-8

class WorksController < ApplicationController

  # only registered users and NOT admin should be able to create new works
  before_filter :load_collection
  before_filter :load_owner, :only => [ :index ]
  before_filter :users_only, :except => [ :index, :show, :navigate, :search, :collected, :edit_tags, :update_tags ]
  before_filter :check_user_status, :except => [ :index, :show, :navigate, :search, :collected ]
  before_filter :load_work, :except => [ :new, :create, :import, :index, :show_multiple, :edit_multiple, :update_multiple, :delete_multiple, :search, :drafts, :collected ]
  # this only works to check ownership of a SINGLE item and only if load_work has happened beforehand
  before_filter :check_ownership, :except => [ :index, :show, :navigate, :new, :create, :import, :show_multiple, :edit_multiple, :edit_tags, :update_tags, :update_multiple, :delete_multiple, :search, :marktoread, :drafts, :collected ]
  # admins should have the ability to edit tags (:edit_tags, :update_tags) as per our ToS
  before_filter :check_ownership_or_admin, :only => [ :edit_tags, :update_tags ]
  before_filter :log_admin_activity, :only => [ :update_tags ]
  before_filter :check_visibility, :only => [ :show, :navigate ]
  # NOTE: new and create need set_author_attributes or coauthor assignment will break!
  before_filter :set_author_attributes, :only => [ :new, :create, :edit, :update, :manage_chapters, :preview, :show, :navigate ]
  before_filter :set_instance_variables, :only => [ :new, :create, :edit, :update, :manage_chapters, :preview, :show, :navigate, :import ]
  before_filter :set_instance_variables_tags, :only => [ :edit_tags, :update_tags, :preview_tags ]

  before_filter :clean_work_search_params, :only => [ :search, :index, :collected ]

  cache_sweeper :collection_sweeper
  cache_sweeper :static_sweeper
  cache_sweeper :feed_sweeper

  # we want to extract the countable params from work_search and move them into their fields
  def clean_work_search_params
    if params[:work_search].present? && params[:work_search][:query].present?
      # swap in gt/lt for ease of matching; swap them back out for safety at the end
      params[:work_search][:query].gsub!('&gt;', '>')
      params[:work_search][:query].gsub!('&lt;', '<')

      # extract countable params
      %w(word kudo comment bookmark hit).each do |term|
        if params[:work_search][:query].gsub!(/#{term}s?\s*(?:\_?count)?\s*:?\s*((?:<|>|=|:)\s*\d+(?:\-\d+)?)/i, '')
          # pluralize, add _count, convert to symbol
          term = term.pluralize unless term == "word"
          term = term + "_count" unless term == "hits"
          term = term.to_sym

          value = $1.gsub(/^(\:|\=)/, '') # get rid of : and =
          # don't overwrite if submitting from advanced search?
          params[:work_search][term] = value unless params[:work_search][term].present?
        end
      end

      # get sort-by
      if params[:work_search][:query].gsub!(/sort(?:ed)?\s*(?:by)?\s*:?\s*(<|>|=|:)\s*(\w+)\s*(ascending|descending)?/i, '')
        sortdir = $3 || $1
        sortby = $2.gsub(/\s*_?count/, '').singularize # turn word_count or word count or words into just "word" eg

        WorkSearch::SORT_OPTIONS.each do |opt, value|
          # stop at the first one we find
          if opt.match(/#{sortby}/i)
            params[:work_search][:sort_column] = value
            break
          end
        end

        if sortdir == ">" || sortdir == "ascending"
          params[:work_search][:sort_direction] = "asc"
        elsif sortdir == "<" || sortdir == "descending"
          params[:work_search][:sort_direction] = "desc"
        end
      end

      # put categories into quotes
      qr = Regexp.new('(?:"|\')?')
      %w(m/m f/f f/m m/f).each do |cat|
        cr = Regexp.new("#{qr}#{cat}#{qr}")
        params[:work_search][:query].gsub!(cr, "\"#{cat}\"")
      end

      # swap out gt/lt
      params[:work_search][:query].gsub!('>', '&gt;')
      params[:work_search][:query].gsub!('<', '&lt;')

      # get rid of empty queries
      params[:work_search][:query] = nil if params[:work_search][:query].match(/^\s*$/)
    end
  end

  def search
    @languages = Language.default_order
    options = params[:work_search] || {}
    options.merge!(page: params[:page]) if params[:page].present?
    options[:show_restricted] = current_user.present? || logged_in_as_admin?
    @search = WorkSearch.new(options)
    @page_subtitle = ts("Search Works")
    if params[:work_search].present? && params[:edit_search].blank?
      if @search.query.present?
        @page_subtitle = ts("Works Matching '%{query}'", query: @search.query)
      end
      @works = @search.search_results
      render 'search_results'
    end
  end

  # GET /works
  def index
    if params[:work_search].present?
      options = params[:work_search].dup
    else
      options = {}
    end
    if params[:fandom_id] || (@collection.present? && @tag.present?)
      if params[:fandom_id].present?
        @fandom = Fandom.find_by_id(params[:fandom_id])
      end
      tag = @fandom || @tag
      options[:filter_ids] ||= []
      options[:filter_ids] << tag.id
    end
    options.merge!(page: params[:page])
    options[:show_restricted] = current_user.present? || logged_in_as_admin?
    @page_subtitle = index_page_title

    if @owner.present?
      if @admin_settings.disable_filtering?
        @works = Work.list_without_filters(@owner, options)
      else
        @search = WorkSearch.new(options.merge(faceted: true, works_parent: @owner))

        # If we're using caching we'll try to get the results from cache
        # Note: we only cache some first initial number of pages since those are biggest bang for
        # the buck -- users don't often go past them
        if use_caching? && params[:work_search].blank? && params[:fandom_id].blank? &&
          (params[:page].blank? || params[:page].to_i <= ArchiveConfig.PAGES_TO_CACHE)
          # the subtag is for eg collections/COLL/tags/TAG
          subtag = (@tag.present? && @tag != @owner) ? @tag : nil
          user = current_user.present? ? "logged_in" : "logged_out"
          @works = Rails.cache.fetch("#{@owner.works_index_cache_key(subtag)}_#{user}_page#{params[:page]}") do
            results = @search.search_results
            # calling this here to avoid frozen object errors
            results.items
            results.facets
            results
          end
        else
          @works = @search.search_results
        end
        @facets = @works.facets
      end
    elsif use_caching?
      @works = Rails.cache.fetch("works/index/latest/v1", :expires_in => 10.minutes) do
        Work.latest.to_a
      end
    else
      @works = Work.latest.to_a
    end
  end

  def collected
    if params[:work_search].present?
      options = params[:work_search].dup
    else
      options = {}
    end
    options.merge!(page: params[:page])
    options[:show_restricted] = current_user.present? || logged_in_as_admin?

    @user = User.find_by_login(params[:user_id])
    if @user.present?
      if @admin_settings.disable_filtering?
        @works = Work.collected_without_filters(@user, options)
      else
        @search = WorkSearch.new(options.merge(works_parent: @user, collected: true))
        @works = @search.search_results
        @facets = @works.facets
      end
      @page_subtitle = ts("%{username} - Collected Works", username: @user.login)
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
          @pseud = @user.pseuds.find_by_name(params[:pseud_id])
          @works = @pseud.unposted_works.paginate(:page => params[:page])
        else
          @works = @user.unposted_works.paginate(:page => params[:page])
        end
      end
    end
  end

  # GET /works/1
  # GET /works/1.xml
  def show
    @page_title = @work.unrevealed? ? ts("Mystery Work") :
      get_page_title(@work.fandoms.size > 3 ? ts("Multifandom") : @work.fandoms.string,
        @work.anonymous? ?  ts("Anonymous")  : @work.pseuds.sort.collect(&:byline).join(', '),
        @work.title)
    
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
    @kudos = @work.kudos.with_pseud.includes(:pseud => :user).order("created_at DESC")

    if current_user.respond_to?(:subscriptions)
      @subscription = current_user.subscriptions.where(:subscribable_id => @work.id,
                                                       :subscribable_type => 'Work').first ||
                      current_user.subscriptions.build(:subscribable => @work)
    end

    render :show
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
      @page_subtitle = ts("import")
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
    @work.reset_published_at(@chapter)
    @series = current_user.series.uniq
    @collection = Collection.find_by_name(params[:work][:collection_names])
    if params[:edit_button]
      render :new
    elsif params[:cancel_button]
      flash[:notice] = ts("New work posting canceled.")
      redirect_to current_user
    else # now also treating the cancel_coauthor_button case, bc it should function like a preview, really
      unless params[:preview_button] || params[:cancel_coauthor_button]
        @work.posted = true
        @chapter.posted = true
      end
      
      @work.set_revised_at_by_chapter(@chapter)
      valid = (@work.errors.empty? && @work.invalid_pseuds.blank? && @work.ambiguous_pseuds.blank? && @work.has_required_tags?)

      if valid && @work.set_challenge_info && @work.save
        #hack for empty chapter authors in cucumber series tests
        @chapter.pseuds = @work.pseuds if @chapter.pseuds.blank?
        if params[:preview_button] || params[:cancel_coauthor_button]
          flash[:notice] = ts('Draft was successfully created.')
          in_moderated_collection
          redirect_to preview_work_path(@work)
        else
          # We check here to see if we are attempting to post to moderated collection
          flash[:notice]= ts("Work was successfully posted.")
          in_moderated_collection
          redirect_to work_path(@work)
        end
      else
        if @work.errors.empty? && (!@work.invalid_pseuds.blank? || !@work.ambiguous_pseuds.blank?)
          render :_choose_coauthor
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
    @work.reset_published_at(@chapter)
    @series = current_user.series.uniq
    @collection = Collection.find_by_name(params[:work][:collection_names])
    unless @work.errors.empty?
      render :edit and return
    end

    if !@work.invalid_pseuds.blank? || !@work.ambiguous_pseuds.blank?
      @work.valid? ? (render :_choose_coauthor) : (render :new)
    elsif params[:preview_button] || params[:cancel_coauthor_button]
      @preview_mode = true
      if @work.has_required_tags? && @work.invalid_tags.blank?
        flash[:notice] = ts('Draft was successfully created.')
        in_moderated_collection
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
      @work.posted = @chapter.posted = true if params[:post_button]
      posted_changed = @work.posted_changed?
      @work.set_revised_at_by_chapter(@chapter)
      saved = @chapter.save
      @work.has_required_tags? || saved = false
      if saved
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
        @work.minor_version = @work.minor_version + 1
        @work.set_challenge_info
        saved = @work.save
      end
      if saved
        flash[:notice] = ts("Work was successfully #{posted_changed ? 'posted' : 'updated'}.")
        in_moderated_collection
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
    elsif params[:save_button]
        flash[:notice] = ts('Tags were successfully updated.')
      redirect_to(@work)
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
    options = {
      :pseuds => pseuds_to_apply,
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
      :encoding => params[:encoding],
      :external_author_name => params[:external_author_name],
      :external_author_email => params[:external_author_email],
      :external_coauthor_name => params[:external_coauthor_name],
      :external_coauthor_email => params[:external_coauthor_email]
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
      flash.now[:error] = ts("We were only partially able to import this work and couldn't save it. Please review below!")
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

  # check to see if the work is being added / has been added to a moderated collection, then let user know that
  def in_moderated_collection
    if !@collection.nil? && @collection.moderated?
      if (!Work.in_collection(@collection).include?(@work)) && (!@collection.user_is_posting_participant?(current_user))
        flash[:notice] ||= ""
        flash[:notice] += ts(" Your work will only show up in the moderated collection you have submitted it to once it is approved by a moderator.")
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
    if !@collection.nil? && @collection.moderated?
      redirect_to work_path(@work), :notice => ts('Work was submitted to a moderated collection. It will show up in the collection once approved.')
    else
      flash[:notice] = ts("Your work was successfully posted.")
      redirect_to @work
    end
  end

  # WORK ON MULTIPLE WORKS

  def show_multiple
    @user = current_user
    if params[:pseud_id]
      @works = Work.joins(:pseuds).where(:pseud_id => params[:pseud_id])
    else
      @works = Work.joins(:pseuds => :user).where("users.id = ?", @user.id)
    end
    if params[:work_ids]
      @works = @works.where(:id => params[:work_ids])
    end
    @works_by_fandom = @works.joins(:taggings).
      joins("inner join tags on taggings.tagger_id = tags.id AND tags.type = 'Fandom'").
      select("distinct tags.name as fandom, works.id as id, works.title as title").group_by(&:fandom)
  end

  def edit_multiple
    if params[:commit] == "Orphan"
      redirect_to new_orphan_path(:work_ids => params[:work_ids]) and return
    end
    @user = current_user
    @works = Work.select("distinct works.*").joins(:pseuds => :user).where("users.id = ?", @user.id).where(:id => params[:work_ids])
    if params[:commit] == "Delete"
      render "confirm_delete_multiple" and return
    end
  end

  def confirm_delete_multiple
    @user = current_user
    @works = Work.select("distinct works.*").joins(:pseuds => :user).where("users.id = ?", @user.id).where(:id => params[:work_ids])
  end

  def delete_multiple
    @user = current_user
    @works = Work.joins(:pseuds => :user).where("users.id = ?", @user.id).where(:id => params[:work_ids]).readonly(false)
    titles = @works.collect(&:title)
    Rails.logger.info "!&!&!&!&&! GOT HERE #{titles}"
    @works.each do |work|
      work.destroy
    end
    flash[:notice] = ts("Your works %{titles} were deleted.", :titles => titles.join(", "))
    redirect_to show_multiple_user_works_path(@user)
  end

  def update_multiple
    @user = current_user
    @works = Work.joins(:pseuds => :user).where("users.id = ?", @user.id).where(:id => params[:work_ids]).readonly(false)
    @errors = []
    # to avoid overwriting, we entirely trash any blank fields and also any unchecked checkboxes
    work_params = params[:work].reject {|key,value| value.blank? || value == "0"}
    @works.each do |work|
      # now we can just update each work independently, woo!
      unless work.update_attributes(work_params)
        @errors << ts("The work %{title} could not be edited: %{error}", :title => work.title, :error => work.errors_on.to_s)
      end
    end
    unless @errors.empty?
      flash[:error] = ts("There were problems editing some works: %{errors}", :errors => @errors.join(", "))
      redirect_to edit_multiple_user_works_path(@user)
    else
      flash[:notice] = ts("Your edits were put through! Please check over the works to make sure everything is right.")
      redirect_to show_multiple_user_works_path(@user, :work_ids => @works.collect(&:id))
    end
  end

  # marks a work to read later, or unmarks it if the work is already marked
  def marktoread
    @work = Work.find(params[:id])
    Reading.mark_to_read_later(@work, current_user)
    read_later_path = user_readings_path(current_user, :show => 'to-read')
    flash[:notice] = ts("This work was marked for later. You can find it in your #{view_context.link_to('history', read_later_path)}. (The work may take a short while to show up there.)").html_safe
    redirect_to(request.env["HTTP_REFERER"] || root_path)
  end

  protected

  def load_owner
    if params[:user_id].present?
      @user = User.find_by_login(params[:user_id])
      if params[:pseud_id].present?
        @pseud = @user.pseuds.find_by_name(params[:pseud_id])
      end
    end
    if params[:tag_id]
      @tag = Tag.find_by_name(params[:tag_id])
      unless @tag && @tag.is_a?(Tag)
        raise ActiveRecord::RecordNotFound, "Couldn't find tag named '#{params[:tag_id]}'"
      end
      unless @tag.canonical?
        if @tag.merger.present?
          if @collection.present?
            redirect_to collection_tag_works_path(@collection, @tag.merger) and return
          else
            redirect_to tag_works_path(@tag.merger) and return
          end
        else
          redirect_to tag_path(@tag) and return
        end
      end
    end
    @owner = @pseud || @user || @collection || @tag
  end

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
      flash[:notice] = ts("The work was not posted. It will be saved here in your drafts for one month, then deleted from the Archive.")
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

  def index_page_title
    if @owner.present?
      owner_name = case @owner.class.to_s
                   when 'Pseud'
                     @owner.name
                   when 'User'
                     @owner.login
                   when 'Collection'
                     @owner.title
                   else
                     @owner.try(:name)
                   end
      "#{owner_name} - Works".html_safe
    else
      "Latest Works"
    end
  end

  def log_admin_activity
    if logged_in_as_admin?
      options = { action: params[:action] }
      if params[:action] == 'update_tags'
        summary = "Old tags: #{@work.tags.value_of(:name).join(", ")}"
      end
      AdminActivity.log_action(current_admin, @work, action: params[:action], summary: summary)
    end
  end

end
