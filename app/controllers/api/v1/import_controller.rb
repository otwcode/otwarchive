class Api::V1::ImportController < Api::V1::BaseController
  respond_to :json

  # Imports multiple works with their meta from external URLs
  # Params:
  # +params+:: a JSON object containing the following:
  # - archivist: username of an existing archivist
  # - post_without_preview: false = import as drafts, true = import and post
  # - send_claim_emails: false = don't send emails (for testing), true = send emails
  # - array of works to import
  def create
    archivist = User.find_by_login(params[:archivist])
    external_works = params[:works]
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
      status, messages = response_code(messages)
    end
    render status: status, json: { status: status, messages: messages, works: works_responses }
  end

  private

  # Set HTTP responses based on success and error flags
  def response_code(messages)
    if @some_success && @some_errors
      status = :multi_status
      messages << "At least one work was not imported. Please check the works array for further information."
    elsif !@some_success && @some_errors
      status = :unprocessable_entity
      messages << "None of the works were imported. Please check the works array for further information."
    else
      status = :created
      messages << "All works were successfully imported."
    end
    [status, messages]
  end

  # Use the story parser to import works from the chapter URLs,
  # and set success or error flag depending on the outcome
  # Returns a hash
  def import_work(archivist, external_work)
    work_status, work_messages = work_errors(external_work)
    work_url = ""
    original_url = []
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
      original_url: original_url,
      messages: work_messages
    }
  end

  # Top-level error handling: returns a 403 forbidden if a valid archivist isn't supplied and a 400
  # if no works are supplied. If there is neither a valid archivist nor valid works, a 400 is returned
  # ith both errors as a message
  def batch_errors(archivist, external_works)
    status = :bad_request
    errors = []

    unless archivist && archivist.is_archivist?
      status = :forbidden
      errors << "The 'archivist' field must specify the name of an Archive user with archivist privileges."
    end

    if external_works.nil? || external_works.empty?
      errors << "No work URLs were provided."
    elsif external_works.size >= ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST
      errors << "This request contains too many works. A maximum of #{ ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST }" +
                "works can be imported in one go by an archivist."
    end
    status = :ok if errors.empty?
    [status, errors]
  end

  # Work-level error handling for requests that are incomplete or too large
  def work_errors(work)
    status = :bad_request
    errors = []
    urls = work[:chapter_urls]
    if urls.nil?
      errors << "This work doesn't contain chapter_urls. Works can only be imported from publicly-accessible URLs."
    elsif urls.length >= ArchiveConfig.IMPORT_MAX_CHAPTERS
      errors << "This work contains too many chapter URLs. A maximum of #{ ArchiveConfig.IMPORT_MAX_CHAPTERS }" +
                "chapters can be imported per work."
    end
    status = :ok if errors.empty?
    [status, errors]
  end

  # send invitations to external authors for a given set of works
  def send_external_invites(works, archivist)
    external_authors = works.collect(&:external_authors).flatten.uniq
    unless external_authors.empty?
      external_authors.each do |external_author|
        external_author.find_or_invite(archivist)
      end
    end
  end

  def options(archivist, params)
    {
      archivist: archivist,
      import_multiple: "chapters",
      importing_for_others: true,
      do_not_set_current_author: true,
      post_without_preview: params[:post_without_preview].blank? ? true : params[:post_without_preview],
      restricted: params[:restricted],
      override_tags: params[:override_tags],
      collection_names: params[:collection_names],
      fandom: params[:fandoms],
      warning: params[:warnings],
      character: params[:characters],
      rating: params[:rating],
      relationship: params[:relationships],
      category: params[:categories],
      freeform: params[:additional_tags],
      summary: params[:summary],
      encoding: params[:encoding],
      external_author_name: params[:external_author_name],
      external_author_email: params[:external_author_email],
      external_coauthor_name: params[:external_coauthor_name],
      external_coauthor_email: params[:external_coauthor_email]
    }
  end
end
