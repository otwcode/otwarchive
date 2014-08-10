class FavoriteTagsController < ApplicationController
  
  skip_before_filter :store_location, only: [ :create, :destroy ]
  before_filter :users_only
  before_filter :load_user
  before_filter :check_ownership
  
  respond_to :html, :json
  
  # GET /favorites_tags
  def index
    @favorite_tags = FavoriteTag.all
  end
  
  # POST /favorites_tags
  def create
    @favorite_tag = current_user.favorite_tags.build(params[:favorite_tag])
    @favorite_tag.save!
    success = ts('You have successfully added %{tag_name} to your favorite tags.', tag_name: @favorite_tag.tag_name)
    respond_to do |format|
      format.html { redirect_to tag_works_path(:tag_id => @favorite_tag.tag.to_param), notice: success }
      format.json { render json: { favorite_tag_id: @favorite_tag.id, favorite_tag_success: success }, status: :created }
    end
  end
 
  # DELETE /favorite_tags/1 
  def destroy
    @favorite_tag = FavoriteTag.find(params[:id])
    @favorite_tag.destroy
    success = ts('You have successfully removed %{tag_name} from your favorite tags.', tag_name: @favorite_tag.tag_name)
    respond_to do |format|
      format.html { redirect_to tag_works_path(:tag_id => @favorite_tag.tag.to_param), notice: success }
      format.json { render json: { favorite_tag_success: success }, status: :ok }
    end
  end
  
  private
  
  def load_user
    @user = User.find_by_login(params[:user_id])
    @check_ownership_of = @user
  end
  
end
