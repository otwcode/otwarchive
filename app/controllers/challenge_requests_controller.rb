class ChallengeRequestsController < ApplicationController

  before_filter :load_collection
  before_filter :check_visibility

  def check_visibility
    unless @collection.challenge.user_allowed_to_see_requests_summary?(current_user)
      flash.now[:notice] = ts("You are not allowed to view requests summary!")
      redirect_to collection_path(@collection) and return
    end
  end

  def index
    @requests = @collection.prompts.where("type = 'Request'").
                                  joins(:challenge_signup => :pseud).
                                  order("pseuds.name ASC").
                                  paginate(:page => params[:page])
  end

end
