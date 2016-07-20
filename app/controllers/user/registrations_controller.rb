class User
  # Handle user devise registration
  class RegistrationsController < Devise::RegistrationsController
    before_filter :configure_sign_up_params, only: [:create]
    before_filter :hide_dashboard,
                  :can_create_account?,
                  only: [:new, :create]
    # before_filter :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    def new
      @hide_dashboard = true

      super do |user|
        @invitation = Invitation.find_by_token(params[:invitation_token])

        if @invitation
          user.invitation_token = @invitation.token
          user.email = @invitation.invitee_email
        end
      end
    end

    # POST /resource
    def create
      @hide_dashboard = true

      super do |user|
        if user.persisted? && Rails.env.development?
          flash.now[:notice] = ts(
            "During testing you can activate via <a href='%{url}'>your activation url</a>.",
            url: confirmation_url(user, confirmation_token: user.confirmation_token)
          ).html_safe
        end
      end
    end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.for(:user) do |u|
        u.permit(:age_over_13, :terms_of_service, :invitation_token)
      end
    end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.for(:account_update) << :attribute
    # end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(_resource)
    #   user_register_confirm_path
    # end

    # Hide user dashboard on new user registration
    def hide_dashboard
      @hide_dashboard = true
    end

    # Check if the user can create a new account
    def can_create_account?
      if admin_signed_in? || user_signed_in?
        flash[:error] = ts('You are already logged in!')
        redirect_to root_path
        return false
      end

      unless @admin_settings.account_creation_enabled?
        flash[:error] = ts('Account creation is suspended at the moment. Please check back with us later.')
        redirect_to root_path
        return false
      end

      return true unless @admin_settings.creation_requires_invite?

      valid_invitation?(params[:invitation_token])
    end

    # Check if the user has a valid invitation token
    def valid_invitation?(token)
      return no_invitation_warning if token.blank?

      invitation = Invitation.find_by_token(token)

      if !invitation
        flash[:error] = ts("There was an error with your invitation token, please contact support")
        redirect_to new_feedback_report_path
      elsif invitation.redeemed_at && invitation.invitee
        flash[:error] = ts("This invitation has already been used to create an account, sorry!")
        redirect_to root_path
      end
    end

    # Define redirect and message warning based on Admin settings
    def no_invitation_warning
      if @admin_settings.invite_from_queue_enabled?
        flash[:error] = ts("To create an account, you'll need an invitation. One option is to add your name to the automatic queue below.")
        redirect_to invite_requests_path
        return false
      end

      flash[:error] = ts('Account creation currently requires an invitation. We are unable to give out additional invitations at present, but existing invitations can still be used to create an account.')
      redirect_to root_path
    end
  end
end
