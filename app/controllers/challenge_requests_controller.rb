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
      # sorting
      @sort_column = (valid_sort_column(params[:sort_column],"prompt") ? params[:sort_column] : 'id')
      @sort_direction = (valid_sort_direction(params[:sort_direction]) ? params[:sort_direction] : 'DESC')
      if !params[:sort_direction].blank? && !valid_sort_direction(params[:sort_direction])
        params[:sort_direction] = 'DESC'
      end
      @order = @sort_column + " " + @sort_direction
      # actual content
      @requests = @collection.prompts.where("type = 'Request'")
      @requests = @requests.order(@order).
                                  paginate(:page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)
    else
      @requests = @collection.prompts.where("type = 'Request'").
                                  joins(:challenge_signup => :pseud).
                                  order("pseuds.name ASC").
                                  paginate(:page => params[:page])
    end
  end

end
