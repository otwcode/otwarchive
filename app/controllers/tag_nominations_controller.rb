class TagNominationsController < ApplicationController
  
  # This gets called from the edit-in-place code for the tag set nominations review page
  def update
    @tag_nomination = TagNomination.find(params[:id])
    respond_to do |format|
      if @tag_nomination && @tag_nomination.owned_tag_set.user_is_moderator?(current_user) && @tag_nomination.update_attributes(params[:tag_nomination])
        format.json {head :ok}
      else
        format.json { render json: [ts("That didn't work.")], status: :unprocessable_entity}
      end
    end    
  end
  
end