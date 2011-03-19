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
      
      # actual content, do the efficient method unless we need the full query
      
      if @sort_column == "fandom"
        query = "SELECT prompts.*, GROUP_CONCAT(tags.name) FROM prompts INNER JOIN set_taggings ON prompts.tag_set_id = set_taggings.tag_set_id 
        INNER JOIN tags ON tags.id = set_taggings.tag_id 
        WHERE prompts.type = 'Request' AND tags.type = 'fandom' AND prompts.collection_id = 602 GROUP BY prompts.id ORDER BY GROUP_CONCAT(tags.name) " + @sort_direction
        @requests = Prompt.find_by_sql query
      else
        @requests = @collection.prompts.where("type = 'Request'").order(@order)
      end
      
      @requests = @requests.paginate(:page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)
    else
      @requests = @collection.prompts.where("type = 'Request'").
                                  joins(:challenge_signup => :pseud).
                                  order("pseuds.name ASC").
                                  paginate(:page => params[:page])
    end
  end

end
