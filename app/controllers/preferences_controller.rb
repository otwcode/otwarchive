class PreferencesController < ApplicationController
  before_filter :load_user
  before_filter :check_ownership
  skip_before_filter :store_location

  
  # Ensure that the current user is authorized to view and change this information
  def load_user
    @user = User.find_by_login(params[:user_id])
    @check_ownership_of = @user
  end
  
  def index
    @user = User.find_by_login(params[:user_id])
    @preference = @user.preference || Preference.create(:user_id => @user.id)
    @available_skins = (current_user.skins.site_skins + Skin.approved_skins.site_skins).uniq
  end

  def update
    @user = User.find_by_login(params[:user_id])
    @preference = @user.preference
    @user.preference.attributes = params[:preference]
    @available_skins = (current_user.skins.site_skins + Skin.approved_skins.site_skins).uniq
    
    if @user.preference.save
      flash[:notice] = ts('Your preferences were successfully updated.')
      if @user.preference.skin_id.changed?
        # unset site skin if user changed their skin
        session[:site_skin] = nil
      end
      redirect_back_or_default(user_preferences_path(@user))
    else
      flash[:error] = ts('Sorry, something went wrong. Please try that again.')
      render :action => :index
    end
  end
end
