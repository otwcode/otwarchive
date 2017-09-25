class Api::V2::WorksController < Api::V2::BaseController
  respond_to :json

  # POST - search for works based on imported url
  def search
    original_urls = params[:original_urls]
    results = []
    messages = []
    if original_urls.nil? || original_urls.blank? || original_urls.empty?
      status = :empty_request
      messages << "Please provide a list of URLs to find."
    elsif original_urls.size >= ArchiveConfig.IMPORT_MAX_CHAPTERS
      status = :too_many_request
      messages << "Please provide no more than #{ ArchiveConfig.IMPORT_MAX_CHAPTERS } URLs to find."
    else
      status = :ok
      results = find_existing_works(original_urls)
      messages << "Successfully searched all provided urls"
    end
    render_api_response(status, messages, works: results)
  end

  # POST - create a work and invite authors to claim
  def create
    archivist = User.find_by(login: params[:archivist])
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
        works_responses << import_work(archivist, external_work.merge(params.permit!))
      end

      # Send claim notification emails if required
      if params[:send_claim_emails] && !@works.empty?
        status = :emails_sent
        send_external_invites(@works, archivist)
      end

      # set final response code and message depending on the flags
      messages = response_message(messages)
    end
    render_api_response(status, messages, works: works_responses)
  end

  private

  # Set messages based on success and error flags
  def response_message(messages)
    messages << if @some_success && @some_errors
                  "At least one work was not imported. Please check individual work responses for further information."
                elsif !@some_success && @some_errors
                  "None of the works were imported. Please check individual work responses for further information."
                else
                  "All works were successfully imported."
                end
    messages
  end

  # Work-level error handling for requests that are incomplete or too large
  def work_errors(work)
    status = :bad_request
    errors = []
    urls = work[:chapter_urls]
    if urls.nil? || urls.empty?
      status = :empty_request
      errors << "This work doesn't contain chapter_urls. Works can only be imported from publicly-accessible URLs."
    elsif urls.length >= ArchiveConfig.IMPORT_MAX_CHAPTERS
      status = :too_many_requests
      errors << "This work contains too many chapter URLs. A maximum of #{ArchiveConfig.IMPORT_MAX_CHAPTERS} " \
                "chapters can be imported per work."
    end
    status = :ok if errors.empty?
    [status, errors]
  end
  
  # Search for works imported from the provided URLs
  def find_existing_works(original_urls)
    results = []
    original_urls.each do |original|
      original_id = ""
      if original.class == String
        original_url = original
      else
        original_id = original[:id]
        original_url = original[:url]
      end
      work_result = find_work_by_import_url(original_id, original_url)
      if work_result[:work].nil?
        results << { status: :not_found,
                     original_id: original_id,
                     original_url: original_url,
                     messages: [work_result[:error]] }
      else
        work = work_result[:work]
        archive_url = work_url(work)
        message = "Work \"#{work.title}\", created on #{work.created_at.to_date.to_s(:iso_date)} was found at \"#{archive_url}\""
        results << { status: :found,
                     original_id: original_id,
                     original_url: original_url,
                     archive_url: archive_url,
                     created: work.created_at,
                     messages: [message] }
      end
    end
    results
  end

  def find_work_by_import_url(original_id, original_url)
    work = nil
    error = ""
    if original_url.blank?
      error = "Please provide the original URL for the work."
    else
      # We know the url will be identical no need for a call to find_by_url
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
  
  
  # Use the story parser to scrape works from the chapter URLs
  def import_work(archivist, external_work)
    work_status, work_messages = work_errors(external_work)
    work_url = ""
    original_url = ""
    if work_status == :ok
      urls = external_work[:chapter_urls]
      original_url = urls.first
      storyparser = StoryParser.new
      options = story_parser_options(archivist, external_work)
      begin
        response = storyparser.import_chapters_into_story(urls, options)
        work = response[:work]
        work_status = response[:status]

        if work_status == :created
          work.save
          @some_success = true
        elsif work_status == :already_imported
          @some_errors = true
        end
        @works << work
        work_url = work_url(work)
        work_messages << response[:message]
      rescue => exception
        @some_errors = true
        work_status = :unprocessable_entity
        work_messages << exception.message
      end
    end

    {
      status: work_status,
      archive_url: work_url,
      original_id: external_work[:id],
      original_url: original_url,
      messages: work_messages
    }
  end

  # Send invitations to external authors for a given set of works
  def send_external_invites(works, archivist)
    external_authors = works.map(&:external_authors).flatten.uniq
    unless external_authors.empty?
      external_authors.each do |external_author|
        external_author.find_or_invite(archivist)
      end
    end
  end

  # Request and response hashes
  
  # Create options map for StoryParser
  def story_parser_options(archivist, work_params)
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
