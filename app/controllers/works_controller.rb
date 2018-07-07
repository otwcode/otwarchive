# encoding=utf-8

class WorksController < ApplicationController
  # only registered users and NOT admin should be able to create new works
  before_action :load_collection
  before_action :load_owner, only: [:index]
  before_action :users_only, except: [:index, :show, :navigate, :search, :collected, :edit_tags, :update_tags, :reindex]
  before_action :check_user_status, except: [:index, :show, :navigate, :search, :collected, :reindex]
  before_action :load_work, except: [:new, :create, :import, :index, :show_multiple, :edit_multiple, :update_multiple, :delete_multiple, :search, :drafts, :collected]
  # this only works to check ownership of a SINGLE item and only if load_work has happened beforehand
  before_action :check_ownership, except: [:index, :show, :navigate, :new, :create, :import, :show_multiple, :edit_multiple, :edit_tags, :update_tags, :update_multiple, :delete_multiple, :search, :mark_for_later, :mark_as_read, :drafts, :collected, :reindex]
  # admins should have the ability to edit tags (:edit_tags, :update_tags) as per our ToS
  before_action :check_ownership_or_admin, only: [:edit_tags, :update_tags]
  before_action :log_admin_activity, only: [:update_tags]
  before_action :check_visibility, only: [:show, :navigate]
  # NOTE: new and create need set_author_attributes or coauthor assignment will break!
  before_action :set_author_attributes, only: [:new, :create, :edit, :update, :manage_chapters, :preview, :show, :navigate]
  before_action :set_instance_variables, only: [:new, :create, :edit, :update, :manage_chapters, :preview, :show, :navigate, :import]
  before_action :set_instance_variables_tags, only: [:edit_tags, :update_tags, :preview_tags]

  cache_sweeper :collection_sweeper
  cache_sweeper :feed_sweeper

  # we want to extract the countable params from work_search and move them into their fields
  def clean_work_search_params
    QueryCleaner.new(work_search_params || {}).clean
  end

  def search
    @languages = Language.default_order
    options = params[:work_search].present? ? clean_work_search_params : {}
    options[:page] = params[:page] if params[:page].present?
    options[:show_restricted] = current_user.present? || logged_in_as_admin?
    # ES UPGRADE TRANSITION #
    # Remove conditional and call to WorkSearch
    if use_new_search?
      @search = WorkSearchForm.new(options)
    else
      @search = WorkSearch.new(options)
    end
    @page_subtitle = ts("Search Works")

    if params[:work_search].present? && params[:edit_search].blank?
      if @search.query.present?
        @page_subtitle = ts("Works Matching '%{query}'", query: @search.query)
      end

      @works = @search.search_results
      flash_max_search_results_notice(@works)
      render 'search_results'
    end
  end

  # GET /works
  def index
    base_options = {
      page: params[:page] || 1,
      show_restricted: current_user.present? || logged_in_as_admin?
    }

    options = params[:work_search].present? ? clean_work_search_params : {}

    if params[:fandom_id] || (@collection.present? && @tag.present?)
      if params[:fandom_id].present?
        @fandom = Fandom.find_by(id: params[:fandom_id])
      end

      tag = @fandom || @tag
      options[:filter_ids] ||= []
      options[:filter_ids] << tag.id
    end

    if params[:include_work_search].present?
      params[:include_work_search].keys.each do |key|
        options[key] ||= []
        options[key] << params[:include_work_search][key]
        options[key].flatten!
      end
    end

    if params[:exclude_work_search].present?
      params[:exclude_work_search].keys.each do |key|
        options[:excluded_tag_ids] ||= []
        options[:excluded_tag_ids] << params[:exclude_work_search][key]
        options[:excluded_tag_ids].flatten!
      end
    end

    options.merge!(base_options)
    @page_subtitle = index_page_title

    if logged_in? && @tag
      @favorite_tag = @current_user.favorite_tags
                                   .where(tag_id: @tag.id).first ||
                      FavoriteTag
                      .new(tag_id: @tag.id, user_id: @current_user.id)
    end

    if @owner.present?
      if @admin_settings.disable_filtering?
        @works = Work.includes(:tags, :external_creatorships, :series, :language, collections: [:collection_items], pseuds: [:user]).list_without_filters(@owner, options)
      else
        # ES UPGRADE TRANSITION #
        # Remove conditional and call to WorkSearch
        if use_new_search?
          @search = WorkSearchForm.new(options.merge(faceted: true, works_parent: @owner))
        else
          @search = WorkSearch.new(options.merge(faceted: true, works_parent: @owner))
        end
        # If we're using caching we'll try to get the results from cache
        # Note: we only cache some first initial number of pages since those are biggest bang for
        # the buck -- users don't often go past them
        if use_caching? && params[:work_search].blank? && params[:fandom_id].blank? &&
           (params[:page].blank? || params[:page].to_i <= ArchiveConfig.PAGES_TO_CACHE)
          # the subtag is for eg collections/COLL/tags/TAG
          subtag = @tag.present? && @tag != @owner ? @tag : nil
          user = logged_in? || logged_in_as_admin? ? 'logged_in' : 'logged_out'
          @works = Rails.cache.fetch("#{@owner.works_index_cache_key(subtag)}_#{user}_page#{params[:page]}_#{use_new_search?}", expires_in: 20.minutes) do
            results = @search.search_results
            # calling this here to avoid frozen object errors
            results.items
            results.facets
            results
          end
        else
          @works = @search.search_results
        end

        flash_max_search_results_notice(@works)

        @facets = @works.facets
        if @search.options[:excluded_tag_ids].present?
          tags = Tag.where(id: @search.options[:excluded_tag_ids])
          tags.each do |tag|
            @facets[tag.class.to_s.downcase] ||= []
            @facets[tag.class.to_s.downcase] << QueryFacet.new(tag.id, tag.name, 0)
          end
        end
      end
    elsif use_caching?
      @works = Rails.cache.fetch('works/index/latest/v1', expires_in: 10.minutes) do
        Work.latest.includes(:tags, :external_creatorships, :series, :language, collections: [:collection_items], pseuds: [:user]).to_a
      end
    else
      @works = Work.latest.includes(:tags, :external_creatorships, :series, :language, collections: [:collection_items], pseuds: [:user]).to_a
    end
  end

  def collected
    options = params[:work_search].present? ? clean_work_search_params : {}
    options[:page] = params[:page] || 1
    options[:show_restricted] = current_user.present? || logged_in_as_admin?

    @user = User.find_by(login: params[:user_id])

    return unless @user.present?

    if @admin_settings.disable_filtering?
      @works = Work.collected_without_filters(@user, options)
    else
      # ES UPGRADE TRANSITION #
      # Remove conditional and call to WorkSearch
      if use_new_search?
        @search = WorkSearchForm.new(options.merge(works_parent: @user, collected: true))
      else
        @search = WorkSearch.new(options.merge(works_parent: @user, collected: true))
      end
      @works = @search.search_results
      flash_max_search_results_notice(@works)
      @facets = @works.facets
    end

    @page_subtitle = ts('%{username} - Collected Works', username: @user.login)
  end

  def drafts
    unless params[:user_id]
      flash[:error] = ts('Whose drafts did you want to look at?')
      redirect_to controller: :users, action: :index
      return
    end

    @user = User.find_by(login: params[:user_id])

    unless current_user == @user
      flash[:error] = ts('You can only see your own drafts, sorry!')
      redirect_to current_user
      return
    end

    if params[:pseud_id]
      @pseud = @user.pseuds.find_by(name: params[:pseud_id])
      @works = @pseud.unposted_works.paginate(page: params[:page])
    else
      @works = @user.unposted_works.paginate(page: params[:page])
    end
  end

  # GET /works/1
  # GET /works/1.xml
  def show
    @tag_groups = @work.tag_groups
    if @work.unrevealed?
      @page_title = ts("Mystery Work")
    else
      page_creator = if @work.anonymous?
                       ts("Anonymous")
                     else
                       @work.pseuds.map(&:byline).sort.join(", ")
                     end
      fandoms = @tag_groups["Fandom"]
      page_title_inner = if fandoms.size > 3
                           ts("Multifandom")
                         else
                           fandoms.empty? ? ts("No fandom specified") : fandoms[0].name
                         end
      @page_title = get_page_title(page_title_inner, page_creator, @work.title)
    end

    # Users must explicitly okay viewing of adult content
    if params[:view_adult]
      session[:adult] = true
    elsif @work.adult? && !see_adult?
      render('_adult', layout: 'application') && return
    end

    # Users must explicitly okay viewing of entire work
    if @work.chaptered?
      if @work.number_of_posted_chapters > 1 && params[:view_full_work] || (logged_in? && current_user.preference.try(:view_full_works))
        @chapters = @work.chapters_in_order
      else
        flash.keep
        redirect_to([@work, @chapter]) && return
      end
    end

    @tag_categories_limited = Tag::VISIBLE - ['Warning']
    @kudos = @work.kudos.with_pseud.includes(pseud: :user).order('created_at DESC')

    if current_user.respond_to?(:subscriptions)
      @subscription = current_user.subscriptions.where(subscribable_id: @work.id,
                                                       subscribable_type: 'Work').first ||
                      current_user.subscriptions.build(subscribable: @work)
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
    @series = current_user.series.distinct
    @unposted = current_user.unposted_work

    @work.ip_address = request.remote_ip
    # for clarity, add the collection and recipient
    if params[:assignment_id] && (@challenge_assignment = ChallengeAssignment.find(params[:assignment_id])) && @challenge_assignment.offering_user == current_user
      @work.challenge_assignments << @challenge_assignment
      @work.collections << @challenge_assignment.collection
      @work.recipients = @challenge_assignment.requesting_pseud.byline
    elsif @collection
      @work.collection_names = @collection.name
    end

    if params[:claim_id] && (@challenge_claim = ChallengeClaim.find(params[:claim_id])) && User.find(@challenge_claim.claiming_user_id) == current_user
      @work.challenge_claims << @challenge_claim
      @work.collections << @challenge_claim.collection
    elsif @collection
      @work.collection_names = @collection.name
    end

    if params[:import]
      @page_subtitle = ts('import')
      render(:new_import) && return
    elsif params[:load_unposted]
      @work = @unposted
      render(:edit) && return
    else
      render(:new) && return
    end
  end

  # POST /works
  def create
    set_edit_form_fields

    @work.ip_address = request.remote_ip
    # If Edit or Cancel is pressed, bail out and display relevant form
    if params[:edit_button]
      render :new && return
    elsif params[:cancel_button]
      flash[:notice] = ts('New work posting canceled.')
      redirect_to current_user and return
    else
      # now also treating the cancel_coauthor_button case, bc it should function like a preview, really
      set_work_tag_error_messages

      if @work.errors.empty?
        if @work.invalid_pseuds.present? || @work.ambiguous_pseuds.present?
          render :_choose_coauthor and return
        else
          @work.posted = @chapter.posted = true if params[:post_button]
          @work.set_revised_at_by_chapter(@chapter)

          if @work.set_challenge_info && @work.save
            # HACK: for empty chapter authors in cucumber series tests
            @chapter.pseuds = @work.pseuds if @chapter.pseuds.blank?

            if params[:preview_button] || params[:cancel_coauthor_button]
              flash[:notice] = ts("Draft was successfully created. It will be <strong>automatically deleted</strong> on %{deletion_date}", deletion_date: view_context.time_in_zone(@work.created_at + 1.month)).html_safe
              in_moderated_collection
              redirect_to preview_work_path(@work)
            else
              # We check here to see if we are attempting to post to moderated collection
              flash[:notice] = ts("Work was successfully posted. It should appear in work listings within the next few minutes.")
              in_moderated_collection
              redirect_to work_path(@work)
            end
          else
            render :new
          end
        end
      else
        render :new
      end
    end
  end

  def set_work_tag_error_messages
    unless @work.has_required_tags?
      error_message = 'Please add all required tags.'
      error_message << ' Fandom is missing.' if @work.fandoms.blank?

      error_message << ' Warning is missing.' if @work.warnings.blank?

      @work.errors.add(:base, error_message)
    end
  end

  def set_edit_form_fields
    load_pseuds
    @work.reset_published_at(@chapter)
    @series = current_user.series.distinct
    @collection = Collection.find_by(name: params[:work][:collection_names])
  end

  # GET /works/1/edit
  def edit
    @hide_dashboard = true
    @chapters = @work.chapters_in_order(false) if @work.number_of_chapters > 1
    load_pseuds
    @series = current_user.series.distinct

    return unless params['remove'] == 'me'

    pseuds_with_author_removed = @work.pseuds - current_user.pseuds

    if pseuds_with_author_removed.empty?
      redirect_to controller: 'orphans', action: 'new', work_id: @work.id
    else
      @work.remove_author(current_user)
      flash[:notice] = ts('You have been removed as an author from the work')
      redirect_to current_user
    end
  end

  # GET /works/1/edit_tags
  def edit_tags
  end

  # PUT /works/1
  def update
    set_edit_form_fields

    @work.ip_address = request.remote_ip
    # If Edit or Cancel is pressed, bail out and display relevant form
    if params[:edit_button]
      render :edit
    elsif params[:cancel_button]
      cancel_posting_and_redirect
    else
      # Otherwise, check that the work is valid, contains no errors etc
      set_work_tag_error_messages

      if @work.errors.empty?
        if @work.invalid_pseuds.present? || @work.ambiguous_pseuds.present?
          @work.valid? ? (render :_choose_coauthor) : (render :new)
          return
        elsif params[:preview_button] || params[:cancel_coauthor_button]
          # If this is a preview, display the preview
          preview_mode(:edit) do
            unless @work.posted?
              flash[:notice] = ts("Your changes have not been saved. Please post your work or save without posting if you want to keep them.")
            end

            in_moderated_collection
            @chapter = @work.chapters.first unless @chapter
            render :preview
          end
        else
          @work.posted = @chapter.posted = true if params[:post_button]
          @work.set_revised_at_by_chapter(@chapter)
          posted_changed = @work.posted_changed?

          unless @work.challenge_claims.empty?
            @included = 0
            @work.challenge_claims.each do |claim|
              @work.collections.each do |collection|
                @included = 1 if collection == claim.collection
              end

              @work.collections << claim.collection if @included.zero?

              @included = 0
            end
          end

          @work.minor_version = @work.minor_version + 1
          @work.set_challenge_info

          if @chapter.save && @work.save
            flash[:notice] = ts("Work was successfully #{posted_changed ? "posted" : "updated"}.")
            if posted_changed
              flash[:notice] << ts(" It should appear in work listings within the next few minutes.")
            end
            in_moderated_collection
            redirect_to(@work)
          else
            unless @chapter.valid?
              @chapter.errors.each { |err| @work.errors.add(:base, err) }
            end
            render :edit
          end
        end
      else
        render :edit
      end
    end
  end

  def update_tags
    # If Edit or Cancel is pressed, bail out and display relevant form
    if params[:edit_button]
      render :edit_tags
    elsif params[:cancel_button]
      cancel_posting_and_redirect
    else
      # Otherwise, check that the work is valid, contains no errors etc
      set_work_tag_error_messages

      if @work.errors.empty?
        if params[:preview_button]
          preview_mode(:edit_tags) do
            render :preview_tags
          end
        elsif params[:save_button]
          Work.expire_work_tag_groups_id(@work.id)
          flash[:notice] = ts('Tags were successfully updated.')
          redirect_to(@work)
        else
          if @work.has_required_tags? && @work.invalid_tags.blank?
            @work.posted = true
            @work.minor_version = @work.minor_version + 1
            @work.save
            flash[:notice] = ts('Work was successfully updated.')
            redirect_to(@work) and return
          else
            render :edit_tags
          end
        end
      else
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
      flash[:notice] = ts('Your work %{title} was deleted.', title: title)
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

    if @urls.empty?
      flash.now[:error] = ts('Did you want to enter a URL?')
      render(:new_import) && return
    end

    importing_for_others = params[:importing_for_others] != "false" && params[:importing_for_others]

    # is external author information entered when import for others is not checked?
    if (params[:external_author_name].present? || params[:external_author_email].present?) && !importing_for_others
      flash.now[:error] = ts('You have entered an external author name or e-mail address but did not select "Import for others." Please select the "Import for others" option or remove the external author information to continue.')
      render(:new_import) && return
    end

    # is this an archivist importing?
    if importing_for_others && !current_user.archivist
      flash.now[:error] = ts('You may not import stories by other users unless you are an approved archivist.')
      render(:new_import) && return
    end

    # make sure we're not importing too many at once
    if params[:import_multiple] == 'works' && (!current_user.archivist && @urls.length > ArchiveConfig.IMPORT_MAX_WORKS || @urls.length > ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST)
      flash.now[:error] = ts('You cannot import more than %{max} works at a time.', max: current_user.archivist ? ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST : ArchiveConfig.IMPORT_MAX_WORKS)
      render(:new_import) && return
    elsif params[:import_multiple] == 'chapters' && @urls.length > ArchiveConfig.IMPORT_MAX_CHAPTERS
      flash.now[:error] = ts('You cannot import more than %{max} chapters at a time.', max: ArchiveConfig.IMPORT_MAX_CHAPTERS)
      render(:new_import) && return
    end

    options = build_options(params)

    # now let's do the import
    if params[:import_multiple] == 'works' && @urls.length > 1
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
      @work = if urls.size == 1
                storyparser.download_and_parse_story(urls.first, options)
              else
                storyparser.download_and_parse_chapters_into_story(urls, options)
              end
    rescue Timeout::Error
      flash.now[:error] = ts('Import has timed out. This may be due to connectivity problems with the source site. Please try again in a few minutes, or check Known Issues to see if there are import problems with this site.')
      render(:new_import) && return
    rescue StoryParser::Error => exception
      flash.now[:error] = ts("We couldn't successfully import that work, sorry: %{message}", message: exception.message)
      render(:new_import) && return
    end

    unless @work && @work.save
      flash.now[:error] = ts("We were only partially able to import this work and couldn't save it. Please review below!")
      @chapter = @work.chapters.first
      load_pseuds
      @series = current_user.series.distinct
      render(:new) && return
    end

    # Otherwise, we have a saved work, go us
    send_external_invites([@work])
    @chapter = @work.first_chapter if @work
    if @work.posted
      redirect_to(work_path(@work)) && return
    else
      redirect_to(preview_work_path(@work)) && return
    end
  end

  # import multiple works
  def import_multiple(urls, options)
    # try a multiple import
    storyparser = StoryParser.new
    @works, failed_urls, errors = storyparser.import_from_urls(urls, options)

    # collect the errors neatly, matching each error to the failed url
    unless failed_urls.empty?
      error_msgs = 0.upto(failed_urls.length).map { |index| "<dt>#{failed_urls[index]}</dt><dd>#{errors[index]}</dd>" }.join("\n")
      flash.now[:error] = "<h3>#{ts('Failed Imports')}</h3><dl>#{error_msgs}</dl>".html_safe
    end

    # if EVERYTHING failed, boo. :( Go back to the import form.
    render(:new_import) && return if @works.empty?

    # if we got here, we have at least some successfully imported works
    flash[:notice] = ts('Importing completed successfully for the following works! (But please check the results over carefully!)')
    send_external_invites(@works)

    # fall through to import template
  end

  # if we are importing for others, we need to send invitations
  def send_external_invites(works)
    return unless params[:importing_for_others]

    @external_authors = works.collect(&:external_authors).flatten.uniq
    unless @external_authors.empty?
      @external_authors.each do |external_author|
        external_author.find_or_invite(current_user)
      end
      message = ' ' + ts('We have notified the author(s) you imported works for. If any were missed, you can also add co-authors manually.')
      flash[:notice] ? flash[:notice] += message : flash[:notice] = message
    end
  end

  # check to see if the work is being added / has been added to a moderated collection, then let user know that
  def in_moderated_collection
    moderated_collections = []
    @work.collections.each do |collection|
      next unless !collection.nil? && collection.moderated? && !collection.user_is_posting_participant?(current_user)
      next unless @work.collection_items.present?
      @work.collection_items.each do |collection_item|
        next unless collection_item.collection == collection
        if collection_item.user_approval_status == 1 && collection_item.collection_approval_status.zero?
          moderated_collections << collection
        end
      end
    end
    if moderated_collections.present?
      flash[:notice] ||= ''
      flash[:notice] += ts(" You have submitted your work to #{moderated_collections.size > 1 ? 'moderated collections (%{all_collections}). It will not become a part of those collections' : "the moderated collection '%{all_collections}'. It will not become a part of the collection"} until it has been approved by a moderator.", all_collections: moderated_collections.map(&:title).join(', '))
    end
  end

  public

  def post_draft
    @user = current_user
    @work = Work.find(params[:id])

    unless @user.is_author_of?(@work)
      flash[:error] = ts('You can only post your own works.')
      redirect_to(current_user) && return
    end

    if @work.posted
      flash[:error] = ts('That work is already posted. Do you want to edit it instead?')
      redirect_to(edit_user_work_path(@user, @work)) && return
    end

    @work.posted = true
    @work.minor_version = @work.minor_version + 1
    # @work.update_minor_version

    unless @work.valid? && @work.save
      flash[:error] = ts('There were problems posting your work.')
      redirect_to(edit_user_work_path(@user, @work)) && return
    end

    if !@collection.nil? && @collection.moderated?
      redirect_to work_path(@work), notice: ts('Work was submitted to a moderated collection. It will show up in the collection once approved.')
    else
      flash[:notice] = ts('Your work was successfully posted.')
      redirect_to @work
    end
  end

  # WORK ON MULTIPLE WORKS

  def show_multiple
    @user = current_user

    if params[:pseud_id]
      @works = Work.joins(:pseuds).where(pseud_id: params[:pseud_id])
    else
      @works = Work.joins(pseuds: :user).where('users.id = ?', @user.id)
    end

    @works = @works.where(id: params[:work_ids]) if params[:work_ids]

    @works_by_fandom = @works.joins(:taggings)
                             .joins("inner join tags on taggings.tagger_id = tags.id AND tags.type = 'Fandom'")
                             .select('distinct tags.name as fandom, works.id, works.title, works.posted').group_by(&:fandom)
  end

  def edit_multiple
    if params[:commit] == 'Orphan'
      redirect_to(new_orphan_path(work_ids: params[:work_ids])) && return
    end

    @user = current_user
    @works = Work.select('distinct works.*').joins(pseuds: :user).where('users.id = ?', @user.id).where(id: params[:work_ids])

    render('confirm_delete_multiple') && return if params[:commit] == 'Delete'
  end

  def confirm_delete_multiple
    @user = current_user
    @works = Work.select('distinct works.*').joins(pseuds: :user).where('users.id = ?', @user.id).where(id: params[:work_ids])
  end

  def delete_multiple
    @user = current_user
    @works = Work.joins(pseuds: :user).where('users.id = ?', @user.id).where(id: params[:work_ids]).readonly(false)
    titles = @works.collect(&:title)

    @works.each(&:destroy)

    flash[:notice] = ts('Your works %{titles} were deleted.', titles: titles.join(', '))
    redirect_to show_multiple_user_works_path(@user)
  end

  def update_multiple
    @user = current_user
    @works = Work.joins(pseuds: :user).where('users.id = ?', @user.id).where(id: params[:work_ids]).readonly(false)
    @errors = []
    # to avoid overwriting, we entirely trash any blank fields and also any unchecked checkboxes
    updated_work_params = work_params.reject { |_key, value| value.blank? || value == '0' }

    # manually allow switching of anon/moderated comments
    if updated_work_params[:anon_commenting_disabled] == 'allow_anon'
      updated_work_params[:anon_commenting_disabled] = '0'
    end
    if updated_work_params[:moderated_commenting_enabled] == 'not_moderated'
      updated_work_params[:moderated_commenting_enabled] = '0'
    end

    @works.each do |work|
      # now we can just update each work independently, woo!
      unless work.update_attributes(updated_work_params)
        @errors << ts('The work %{title} could not be edited: %{error}', title: work.title, error: work.errors_on.to_s)
      end
    end

    if @errors.empty?
      flash[:notice] = ts('Your edits were put through! Please check over the works to make sure everything is right.')
      redirect_to show_multiple_user_works_path(@user, work_ids: @works.collect(&:id))
    else
      flash[:error] = ts('There were problems editing some works: %{errors}', errors: @errors.join(', '))
      redirect_to edit_multiple_user_works_path(@user)
    end
  end

  # Reindex the work.
  def reindex
    if logged_in_as_admin? || permit?('tag_wrangler')
      RedisSearchIndexQueue.queue_works([params[:id]], priority: :high)
      flash[:notice] = ts('Work queued to be reindexed')
    else
      flash[:error] = ts("Sorry, you don't have permission to perform this action.")
    end
    redirect_to(request.env['HTTP_REFERER'] || root_path)
  end

  # marks a work to read later
  def mark_for_later
    @work = Work.find(params[:id])
    Reading.mark_to_read_later(@work, current_user, true)
    read_later_path = user_readings_path(current_user, show: 'to-read')
    if @work.marked_for_later?(current_user)
      flash[:notice] = ts("This work was added to your #{view_context.link_to('Marked for Later list', read_later_path)}.").html_safe
    end
    redirect_to(request.env['HTTP_REFERER'] || root_path)
  end

  def mark_as_read
    @work = Work.find(params[:id])
    Reading.mark_to_read_later(@work, current_user, false)
    read_later_path = user_readings_path(current_user, show: 'to-read')
    unless @work.marked_for_later?(current_user)
      flash[:notice] = ts("This work was removed from your #{view_context.link_to('Marked for Later list', read_later_path)}.").html_safe
    end
    redirect_to(request.env['HTTP_REFERER'] || root_path)
  end

  protected

  def load_owner
    if params[:user_id].present?
      @user = User.find_by(login: params[:user_id])
      if params[:pseud_id].present?
        @pseud = @user.pseuds.find_by(name: params[:pseud_id])
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
            redirect_to(collection_tag_works_path(@collection, @tag.merger)) && return
          else
            redirect_to(tag_works_path(@tag.merger)) && return
          end
        else
          redirect_to(tag_path(@tag)) && return
        end
      end
    end
    @owner = @pseud || @user || @collection || @tag
  end

  def load_pseuds
    @allpseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds).uniq
    @pseuds = current_user.pseuds
    @coauthors = @allpseuds.select { |p| p.user.id != current_user.id }
    to_select = @work.authors.blank? ? @work.pseuds.blank? ? [current_user.default_pseud] : @work.pseuds : @work.authors
    @selected_pseuds = to_select.collect { |pseud| pseud.id.to_i }.uniq
  end

  def load_work
    @work = Work.find_by(id: params[:id])
    unless @work
      raise ActiveRecord::RecordNotFound, "Couldn't find work with id '#{params[:id]}'"
    end
    if @collection && !@work.collections.include?(@collection)
      redirect_to(@work) && return
    end

    @check_ownership_of = @work
    @check_visibility_of = @work
  end

  # Sets values for @work, @chapter, @coauthor_results, @pseuds, and @selected_pseuds
  # and @tags[category]
  def set_instance_variables
    if params[:id] # edit, update, preview, manage_chapters
      set_instance_variables_id
    elsif params[:work] # create
      set_instance_variables_work
    else # new
      set_instance_variables_default
    end

    @serial_works = @work.serial_works

    @chapter = @work.first_chapter

    # If we're in preview mode, we want to pick up any changes that have been made to the first chapter
    if params[:work] && work_params[:chapter_attributes]
      @chapter.attributes = work_params[:chapter_attributes]
    end
  end

  # edit, update, preview, manage_chapters
  def set_instance_variables_id
    @work ||= Work.find(params[:id])
    if params[:work] # editing, save our changes
      @work.preview_mode = if params[:preview_button] || params[:cancel_button]
                             true
                           else
                             false
                           end

      @work.attributes = work_params
      @work.save_parents if @work.preview_mode
    end
  end

  # create
  def set_instance_variables_work
    @work = Work.new(work_params)
  end

  # new
  def set_instance_variables_default
    if params[:load_unposted] && current_user.unposted_work
      @work = current_user.unposted_work
    else
      @work = Work.new
      @work.chapters.build
    end
  end

  # set the author attributes
  def set_author_attributes
    # params[:work] is required for every if statement below, so it is hoisted to
    # the top to avoid repeating ourselves.
    return unless params[:work]

    # if we don't have author_attributes[:ids], which shouldn't be allowed to happen
    # (this can happen if a user with multiple pseuds decides to unselect *all* of them)
    sorry = ts("You haven't selected any pseuds for this work. Please use Remove Me As Author or consider orphaning your work instead if you do not wish to be associated with it anymore.")

    if !params[:work][:author_attributes] || !params[:work][:author_attributes][:ids]
      flash.now[:notice] = sorry
      params[:work][:author_attributes] ||= {}
      params[:work][:author_attributes][:ids] = [current_user.default_pseud.id]
    end

    # stuff new bylines into author attributes to be parsed by the work model
    if params[:pseud] && params[:pseud][:byline] && params[:pseud][:byline] != ''
      params[:work][:author_attributes][:byline] = params[:pseud][:byline]
      params[:pseud][:byline] = ''
    end

    # stuff co-authors into author attributes too so we won't lose them
    if params[:work][:author_attributes] && params[:work][:author_attributes][:coauthors]
      params[:work][:author_attributes][:ids].concat(params[:work][:author_attributes][:coauthors]).uniq!
    end

    # make sure at least one of the pseuds is actually owned by this user
    user_ids = Pseud.where(id: params[:work][:author_attributes][:ids]).pluck(:user_id).uniq
    unless user_ids.include?(current_user.id)
      flash.now[:error] = ts("You're not allowed to use that pseud.")
      render :new and return
    end
  end

  # Sets values for @work and @tags[category]
  def set_instance_variables_tags
    return unless params[:id] # edit_tags, update_tags, preview_tags

    @work ||= Work.find(params[:id])
    if params[:work] # editing, save our changes
      if params[:preview_button] || params[:cancel_button] || params[:edit_button]
        @work.preview_mode = true
      else
        @work.preview_mode = false
      end

      @work.attributes = work_params
      @work.save_parents if @work.preview_mode
    end
  rescue
  end

  def cancel_posting_and_redirect
    if @work && @work.posted
      flash[:notice] = ts('The work was not updated.')
      redirect_to user_works_path(current_user)
    else
      flash[:notice] = ts('The work was not posted. It will be saved here in your drafts for one month, then deleted from the Archive.')
      redirect_to drafts_user_works_path(current_user)
    end
  end

  # Takes an array of tags and returns a comma-separated list, without the markup
  def tag_list(tags)
    tags = tags.distinct.compact
    if !tags.blank? && tags.respond_to?(:collect)
      last_tag = tags.pop
      tag_list = tags.collect { |tag| tag.name + ', ' }.join
      tag_list += last_tag.name
      tag_list.html_safe
    else
      ''
    end
  end

  def index_page_title
    if @owner.present?
      owner_name =
        case @owner.class.to_s
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
      'Latest Works'
    end
  end

  def log_admin_activity
    if logged_in_as_admin?
      options = { action: params[:action] }

      if params[:action] == 'update_tags'
        summary = "Old tags: #{@work.tags.pluck(:name).join(', ')}"
      end

      AdminActivity.log_action(current_admin, @work, action: params[:action], summary: summary)
    end
  end

  private

  # NOTE: The reason for the gross condition=(...) thing is because I don't know
  #       what potential values `saved` has as used elsewhere (which is what is
  #       passed as `condition`) and thus the usual approach of condition=nil
  #       followed by a ||= cannot be reliably used. -@duckinator
  def preview_mode(page_name, condition = (@work.has_required_tags? && @work.invalid_tags.blank?))
    @preview_mode = true

    if condition
      yield
    else
      @work.check_for_invalid_tags unless @work.invalid_tags.blank?

      if @work.fandoms.blank?
        @work.errors.add(:base, 'Updating: Please add all required tags. Fandom is missing.')
      elsif !@work.has_required_tags?
        @work.errors.add(:base, 'Updating: Please add all required tags.')
      end

      render page_name
    end
  end

  def build_options(params)
    pseuds_to_apply =
      (Pseud.find_by(name: params[:pseuds_to_apply]) if params[:pseuds_to_apply])

    {
      pseuds: pseuds_to_apply,
      post_without_preview: params[:post_without_preview],
      importing_for_others: params[:importing_for_others],
      restricted: params[:restricted],
      override_tags: params[:override_tags],
      detect_tags: params[:detect_tags] == "true",
      fandom: params[:work][:fandom_string],
      warning: params[:work][:warning_strings],
      character: params[:work][:character_string],
      rating: params[:work][:rating_string],
      relationship: params[:work][:relationship_string],
      category: params[:work][:category_string],
      freeform: params[:work][:freeform_string],
      notes: params[:notes],
      encoding: params[:encoding],
      external_author_name: params[:external_author_name],
      external_author_email: params[:external_author_email],
      external_coauthor_name: params[:external_coauthor_name],
      external_coauthor_email: params[:external_coauthor_email],
      language_id: params[:language_id]
    }
  end

  def work_params
    params.require(:work).permit(
      :rating_string, :fandom_string, :relationship_string, :character_string,
      :warning_string, :category_string, :expected_number_of_chapters, :revised_at,
      :freeform_string, :summary, :notes, :endnotes, :collection_names, :recipients, :wip_length,
      :backdate, :language_id, :work_skin_id, :restricted, :anon_commenting_disabled,
      :moderated_commenting_enabled, :title, :pseuds_to_add, :collections_to_add,
      :unrestricted,
      pseuds_to_remove: [],
      challenge_assignment_ids: [],
      challenge_claim_ids: [],
      category_string: [],
      warning_strings: [],
      author_attributes: [:byline, ids: [], coauthors: [], ambiguous_pseuds: []],
      series_attributes: [:id, :title],
      parent_attributes: [:url, :title, :author, :language_id, :translation],
      chapter_attributes: [
        :title, :"published_at(3i)", :"published_at(2i)", :"published_at(1i)",
        :published_at, :content
      ]
    )
  end

  def work_search_params
    params.require(:work_search).permit(
      :query,
      :title,
      :creators,
      :revised_at,
      :complete,
      :single_chapter,
      :word_count,
      :language_id,
      :fandom_names,
      :rating_ids,
      :character_names,
      :relationship_names,
      :freeform_names,
      :hits,
      :kudos_count,
      :comments_count,
      :bookmarks_count,
      :sort_column,
      :sort_direction,
      :other_tag_names,
      :excluded_tag_names,
      :crossover,
      :date_from,
      :date_to,
      :words_from,
      :words_to,

      warning_ids: [],
      category_ids: [],
      rating_ids: [],
      fandom_ids: [],
      character_ids: [],
      relationship_ids: [],
      freeform_ids: [],

      collection_ids: []
    )
  end

end
