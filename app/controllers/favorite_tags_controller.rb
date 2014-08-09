class FavoriteTagsController < ApplicationController
  # POST /favorite_tags
  def create
    @favorite_tag = FavoriteTag.new(params[:favorite_tag])

    respond_to do |format|
      if @favorite_tag.save
        format.html {
          flash[:notice] = ts('You have successfully favorited the tag %{tag_name}. It will be listed on your homepage.', :tag_name => @favorite_tag.tag_name).html_safe
          redirect_to tag_works_path(:tag_id => @favorite_tag.tag.to_param)
        }
      else
        format.html { render action: "new" }
      end
    end
  end

  # DELETE /favorite_tags/1
  def destroy
    @favorite_tag = FavoriteTag.find(params[:id])
    @favorite_tag.destroy

    respond_to do |format|
      format.html {
          flash[:notice] = ts('You have successfully unfavorited the tag %{tag_name}. It will no longer be listed on your homepage.', :tag_name => @favorite_tag.tag_name).html_safe
          redirect_to tag_works_path(:tag_id => @favorite_tag.tag.to_param)
        }
    end
  end
end
