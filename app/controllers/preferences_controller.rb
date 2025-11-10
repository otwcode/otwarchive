class PreferencesController < ApplicationController
  before_action :load_user
  before_action :check_ownership_or_admin

  # Ensure that the current user is authorized to view and change this information
  def load_user
    @user = User.find_by(login: params[:user_id])
    @check_ownership_of = @user
  end

  def index
    @preference = @user.preference
    authorize @preference if logged_in_as_admin?
    @available_skins = (@user.skins.site_skins + Skin.approved_skins.site_skins).uniq
    @available_locales = Locale.where(email_enabled: true)
  end

  def update
    @preference = @user.preference
    authorize @preference if logged_in_as_admin?
    @available_skins = (@user.skins.site_skins + Skin.approved_skins.site_skins).uniq
    @available_locales = Locale.where(email_enabled: true)

    @user.preference.attributes = preference_params
    
    if params[:preference][:skin_id].present?
      # unset session skin if user changed their skin
      session[:site_skin] = nil
    end

    if @user.preference.save
      flash[:notice] = t(".success")
      redirect_to user_path(@user)
    else
      flash[:error] = t(".error")
      render action: :index
    end
  end

  private

  def preference_params
    params.require(:preference).permit(
      :minimize_search_engines,
      :disable_share_links,
      :adult,
      :view_full_works,
      :hide_warnings,
      :hide_freeform,
      :disable_work_skins,
      :skin_id,
      :time_zone,
      :preferred_locale,
      :work_title_format,
      :comment_emails_off,
      :comment_inbox_off,
      :comment_copy_to_self_off,
      :kudos_emails_off,
      :admin_emails_off,
      :allow_collection_invitation,
      :collection_emails_off,
      :collection_inbox_off,
      :recipient_emails_off,
      :history_enabled,
      :first_login,
      :banner_seen,
      :allow_cocreator,
      :allow_gifts,
      :guest_replies_off
    )
  end
end
