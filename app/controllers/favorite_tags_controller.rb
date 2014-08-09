class FavoriteTagsController < ApplicationController

  skip_before_filter :store_location

  # GET /favorites_tags
  def index
    @favorite_tags = FavoriteTag.all
  end

  # POST /favorite_tags
  def create
    @favorite_tag = FavoriteTag.new(params[:favorite_tag])

    if @favorite_tag.save
      respond_to do |format|
        format.html do
          flash[:notice] = ts('You have successfully favorited the tag %{tag_name}. It will be listed on your homepage.', :tag_name => @favorite_tag.tag_name).html_safe
          redirect_to tag_works_path(:tag_id => @favorite_tag.tag.to_param) and return
        end
        format.js do
          render :create, status: :created
        end
      end
    else
      respond_to do |format|
        format.html do
          flash[:error] = ts('Sorry, we could not favorite the tag %{tag_name}.', :tag_name => @favorite_tag.tag_name).html_safe
          redirect_to tag_works_path(:tag_id => @favorite_tag.tag.to_param) and return
        end
        format.js do
          render json: { errors: @favorite_tag.errors }
        end
      end
    end
  end

  # DELETE /favorite_tags/1
  def destroy
    @favorite_tag = FavoriteTag.find(params[:id])
    @favorite_tag.destroy

    respond_to do |format|
      format.html do
          flash[:notice] = ts('You have successfully unfavorited the tag %{tag_name}. It will no longer be listed on your homepage.', :tag_name => @favorite_tag.tag_name).html_safe
          redirect_to tag_works_path(:tag_id => @favorite_tag.tag.to_param) and return
        end
    end
  end
end
