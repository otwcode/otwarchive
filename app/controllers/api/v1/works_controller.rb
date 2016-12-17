class Api::V1::WorksController < Api::V1::BaseController
  respond_to :json

  # Return the URLs of a batch of individual works. Limits the number of URLs to
  # IMPORT_MAX_CHAPTERS so it doesn't get tied up in checking URLs for too long.
  # Params:
  # +original_urls+:: an array of original URLs to find on the Archive
  def batch_urls
    original_urls = params[:original_urls]
    status = :bad_request
    results = []
    if original_urls.nil? || original_urls.blank? || original_urls.size == 0
      results << { error: "Please provide a list of URLs to find." }
    elsif original_urls.size >= ArchiveConfig.IMPORT_MAX_CHAPTERS
      results << { error: "Please provide no more than #{ ArchiveConfig.IMPORT_MAX_CHAPTERS } URLs to find." }
    else
      status = :ok
      results = process_batch_url(original_urls)
    end
    render status: status, json: results
  end

  # Imports multiple works with their meta from external URLs
  # Params:
  # +params+:: a JSON object containing the following:
  # - archivist: username of an existing archivist
  # - post_without_preview: false = import as drafts, true = import and post
  # - send_claim_emails: false = don't send emails (for testing), true = send emails
  # - array of works to import
  def create
    archivist = User.find_by_login(params[:archivist])
    external_works = params[:items] || params[:works]
    works_responses = []
    @works = []

    # check for top-level errors (not an archivist, no works...)
    status, messages = batch_errors(archivist, external_works)

    if status == :ok
      # Flag error and successes
      @some_errors = @some_success = false

      # Process the works, updating the flags
      external_works.each do |external_work|
        works_responses << import_work(archivist, external_work.merge(params))
      end

      # Send claim notification emails if required
      if params[:send_claim_emails] && !@works.empty?
        send_external_invites(@works, archivist)
      end

      # set final response code and message depending on the flags
      messages = response_message(messages)
    end
    render status: status, json: { messages: messages, works: works_responses }
  end

  private

  # Set messages based on success and error flags
  def response_message(messages)
    if @some_success && @some_errors
      messages << "At least one work was not imported. Please check the works array for further information."
    elsif !@some_success && @some_errors
      messages << "None of the works were imported. Please check the works array for further information."
    else
      messages << "All works were successfully imported."
    end
    messages
  end

  # Use the story parser to import works from the chapter URLs,
  # and set success or error flag depending on the outcome
  # Returns a hash
  def import_work(archivist, external_work)
    work_status, work_messages = work_errors(external_work)
    work_url = ""
    original_url = ""
    if work_status == :ok
      urls = external_work[:chapter_urls]
      original_url = urls.first
      storyparser = StoryParser.new
      options = options(archivist, external_work)
      begin
        work = storyparser.download_and_parse_chapters_into_story(urls, options)
        work.save
        @works << work
        @some_success = true
        work_status = :created
        work_url = work_url(work)
        work_messages << "Successfully created work \"" + work.title + "\"."
      rescue => exception
        @some_errors = true
        work_status = :unprocessable_entity
        work_messages << exception.message
      end
    end

    {
      status: work_status,
      url: work_url,
      original_id: external_work[:id],
      original_url: original_url,
      messages: work_messages
    }
  end

  # Work-level error handling for requests that are incomplete or too large
  def work_errors(work)
    status = :bad_request
    errors = []
    urls = work[:chapter_urls]
    if urls.nil? || urls.empty?
      errors << "This work doesn't contain chapter_urls. Works can only be imported from publicly-accessible URLs."
    elsif urls.length >= ArchiveConfig.IMPORT_MAX_CHAPTERS
      errors << "This work contains too many chapter URLs. A maximum of #{ArchiveConfig.IMPORT_MAX_CHAPTERS} " \
                "chapters can be imported per work."
    end
    status = :ok if errors.empty?
    [status, errors]
  end

  # send invitations to external authors for a given set of works
  def send_external_invites(works, archivist)
    external_authors = works.map(&:external_authors).flatten.uniq
    unless external_authors.empty?
      external_authors.each do |external_author|
        external_author.find_or_invite(archivist)
      end
    end
  end

  # Check if existing URL exists
  def process_batch_url(original_urls)
    results = []
    original_urls.each do |original|
      original_id = ""
      if original.class == String
        original_url = original
      else
        original_id = original[:id]
        original_url = original[:url]
      end
      work_result = work_url_from_external(original_id, original_url)
      if work_result[:work].nil?
        results << { status: :not_found,
                     original_id: original_id,
                     original_url: original_url,
                     error: work_result[:error] }
      else
        work = work_result[:work]
        results << { status: :ok,
                     original_id: original_id,
                     original_url: original_url,
                     work_url: work_url(work),
                     created: work.created_at }
      end
    end
    results
  end

  def work_url_from_external(original_id, original_url)
    work = nil
    error = ""
    if original_url.blank?
      error = "Please provide the original URL for the work."
    else
      work = Work.where(imported_from_url: original_url).first
      unless work
        error = "No work has been imported from \"" + original_url + "\"."
      end
    end
    {
      original_id: original_id,
      original_url: original_url,
      work: work,
      error: error
    }
  end

  # Create options map for StoryParser
  def options(archivist, work_params)
    {
      archivist: archivist,
      import_multiple: "chapters",
      importing_for_others: true,
      do_not_set_current_author: true,
      post_without_preview: work_params[:post_without_preview].blank? ? true : work_params[:post_without_preview],
      restricted: work_params[:restricted],
      override_tags: work_params[:override_tags].nil? ? true : work_params[:override_tags],
      detect_tags: work_params[:detect_tags].nil? ? true : work_params[:detect_tags],
      collection_names: work_params[:collection_names],
      title: work_params[:title],
      fandom: work_params[:fandoms],
      warning: work_params[:warnings],
      character: work_params[:characters],
      rating: work_params[:rating],
      relationship: work_params[:relationships],
      category: work_params[:categories],
      freeform: work_params[:additional_tags],
      summary: work_params[:summary],
      notes: work_params[:notes],
      encoding: work_params[:encoding],
      external_author_name: work_params[:external_author_name],
      external_author_email: work_params[:external_author_email],
      external_coauthor_name: work_params[:external_coauthor_name],
      external_coauthor_email: work_params[:external_coauthor_email]
    }
  end
end
