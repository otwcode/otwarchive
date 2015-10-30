class Api::V1::BookmarksController < Api::V1::BaseController
  respond_to :json

  def create
    archivist = User.find_by_login(params[:archivist])
    external_bookmarks = params[:bookmarks]
    bookmarks_responses = []
    @bookmarks = []

    # check for top-level errors (not an archivist, no works...)
    status, messages = batch_errors(archivist, external_bookmarks)

    if status == :ok
      # Flag error and successes
      @some_errors = @some_success = false

      # Process the works, updating the flags
      external_bookmarks.each do |external_bookmark|
        bookmarks_responses << import_bookmark(archivist, external_bookmark.merge({ pseud_id: archivist.default_pseud.id }))
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
      messages << "At least one bookmark was not created. Please check the bookmark array for further information."
    elsif !@some_success && @some_errors
      messages << "None of the bookmarks were created. Please check the bookmark array for further information."
    else
      messages << "All bookmarks were successfully created."
    end
    messages
  end

  # Returns a hash
  def import_bookmark(archivist, external_bookmark)
    bookmark_status, bookmark_messages = bookmark_errors(external_bookmark)
    bookmark_url = ""
    original_url = ""
    if bookmark_status == :ok
      bookmark = Bookmark.new(external_bookmark)
      bookmarkable = bookmark.bookmarkable
      if bookmarkable.save && bookmark.save
        @bookmarks << bookmark
        @some_success = true
        bookmark_status = :created
        bookmark_url = bookmark_url(bookmark)
        bookmarkable = bookmark.bookmarkable
        original_url = bookmarkable.url
        bookmark_messages << "Successfully created bookmark for \"" + bookmarkable.title + "\"."
      else
        @some_errors = true
        bookmark_status = :unprocessable_entity
        bookmark_messages << bookmarkable.errors.full_messages + bookmark.errors.full_messages
      end
    end

    {
      status: bookmark_status,
      url: bookmark_url,
      original_url: original_url,
      messages: bookmark_messages
    }
  end

  # Work-level error handling for requests that are incomplete or too large
  def bookmark_errors(work)
    status = :bad_request
    errors = []
    # TODO: specific error handling for bookmarks
    status = :ok if errors.empty?
    [status, errors]
  end
end
