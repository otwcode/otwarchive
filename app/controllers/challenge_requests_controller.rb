class ChallengeRequestsController < ApplicationController

  before_filter :load_collection
  before_filter :check_visibility

  def check_visibility
    unless @collection.challenge_type == "PromptMeme" || (@collection.challenge_type == "GiftExchange" && @collection.challenge.user_allowed_to_see_requests_summary?(current_user))
      flash.now[:notice] = ts("You are not allowed to view requests summary!")
      redirect_to collection_path(@collection) and return
    end
  end

  def index
    if @collection.challenge_type == "PromptMeme"
      @requests = @collection.prompts.where("type = 'Request'").
                                  joins(:challenge_signup => :pseud).
                                  order("pseuds.name ASC").
                                  paginate(:page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)
    else
      @requests = @collection.prompts.where("type = 'Request'").
                                  joins(:challenge_signup => :pseud).
                                  order("pseuds.name ASC").
                                  paginate(:page => params[:page])
    end
  end

end
