class Api::V1::BookmarksController < Api::V1::BaseController
  respond_to :json

  def create
    archivist = User.find_by_login(params[:archivist])
    external_works = params[:bookmarks]
    bookmarks_responses = []
    @bookmarks = []

    # check for top-level errors (not an archivist, no works...)
    status, messages = batch_errors(archivist, external_works)

    render status: status, json: { status: status, messages: messages, bookmarks: "works_responses" }
  end
end
