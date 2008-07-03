class TaggingsController < ApplicationController
  # DELETE /taggings/1
  # DELETE /taggings/1.xml
  def destroy
    @tagging = Tagging.find(params[:id])
    @tag_relationship = @tagging.tag_relationship
    @tagging.destroy

    respond_to do |format|
      format.html { redirect_to @tag_relationship }
      format.xml  { head :ok }
    end
  end
end
