class Api::V1::BookmarksController < Api::V1::BaseController
  respond_to :json

  def create
    archivist = User.find_by(login: params[:archivist])
    bookmarks = params[:bookmarks]
    bookmarks_responses = []
    @bookmarks = []

    # check for top-level errors (not an archivist, no bookmarks...)
    status, messages = batch_errors(archivist, bookmarks)

    if status == :ok
      # Flag error and successes
      @some_errors = @some_success = false

      # Process the works, updating the flags
      bookmarks.each do |bookmark|
        bookmarks_responses << import_bookmark(archivist, bookmark)
      end

      # set final response code and message depending on the flags
      messages = response_message(messages)
    end

    render status: status, json: { status: status, messages: messages, bookmarks: bookmarks_responses }
  end

  private

  # Set messages based on success and error flags
  def response_message(messages)
    if @some_success && @some_errors
      messages << "At least one bookmark was not created. Please check the individual bookmark results for further information."
    elsif !@some_success && @some_errors
      messages << "None of the bookmarks were created. Please check the individual bookmark results for further information."
    else
      messages << "All bookmarks were successfully created."
    end
    messages
  end

  # Returns a hash
  def import_bookmark(archivist, params)
    bookmark_request = bookmark_request(archivist, params)
    bookmark_status, bookmark_messages = bookmark_errors(archivist, bookmark_request)
    bookmark_url = ""
    original_url = ""
    @some_errors = true
    if bookmark_status == :ok
      begin
        bookmark = Bookmark.new(bookmark_request)
        bookmarkable = bookmark.bookmarkable
        if bookmarkable.save && bookmark.save
          @bookmarks << bookmark
          @some_success = true
          @some_errors = false
          bookmark_status = :created
          bookmark_url = bookmark_url(bookmark)
          bookmark_messages << "Successfully created bookmark for \"" + bookmarkable.title + "\"."
        else
          bookmark_status = :unprocessable_entity
          bookmark_messages << bookmarkable.errors.full_messages + bookmark.errors.full_messages
        end
      rescue Exception => exception
        bookmark_status = :unprocessable_entity
        bookmark_messages << exception.message
      end
      original_url = bookmarkable.url if bookmarkable
    end

    {
      status: bookmark_status,
      archive_url: bookmark_url,
      original_id: params[:id],
      original_url: original_url,
      messages: bookmark_messages.flatten
    }
  end

  # Handling for requests that are incomplete
  def bookmark_errors(archivist, bookmark_request)
    status = :bad_request
    errors = []

    # Perform basic validation which the ExternalWork model doesn't do or returns strange messages for
    # (title is validated correctly in the model and so isn't checked here)
    external_work = bookmark_request[:external]
    url = external_work[:url]
    author = external_work[:author]
    fandom = external_work[:fandom_string]

    if url.nil?
      # Unreachable and AO3 URLs are handled in the ExternalWork model
      errors << "This bookmark does not contain a URL to an external site. Please specify a valid, non-AO3 URL."
    end

    if author.nil? || author == ""
      errors << "This bookmark does not contain an external author name. Please specify an author."
    end

    if fandom.nil? || fandom == ""
      errors << "This bookmark does not contain a fandom. Please specify a fandom."
    end

    archivist_bookmarks = Bookmark.where(pseud_id: archivist.default_pseud.id)

    unless archivist_bookmarks.empty?
      archivist_bookmarks.each do |bookmark|
        if bookmark.bookmarkable_type == "ExternalWork" && ExternalWork.find(bookmark.bookmarkable_id).url == url
          errors << "There is already a bookmark for this archivist and the URL #{url}"
        end
      end
    end

    status = :ok if errors.empty?
    [status, errors]
  end

  # Map Json request to Bookmark request for external work
  def bookmark_request(archivist, params)
    {
      pseud_id: archivist.default_pseud.id,
      external: {
        url: params[:url],
        author: params[:author],
        title: params[:title],
        summary: params[:summary],
        fandom_string: params[:fandom_string],
        rating_string: params[:rating_string],
        category_string: params[:category_string].to_s.split(","), # category is actually an array on bookmarks
        relationship_string: params[:relationship_string],
        character_string: params[:character_string]
      },
      notes: params[:notes],
      tag_string: params[:tag_string],
      collection_names: params[:collection_names],
      private: params[:private].blank? ? false : params[:private],
      rec: params[:recommendation].blank? ? false : params[:recommendation]
    }
  end
end
