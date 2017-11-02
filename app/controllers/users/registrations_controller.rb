class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  def new
    super do |resource|
      if params[:invitation_token]
        @invitation = Invitation.find_by(token: params[:invitation_token])
        resource.invitation_token = @invitation.token
        resource.email = @invitation.invitee_email
      end

      @hide_dashboard = true
    end
  end

  def create
    @hide_dashboard = true
    if params[:cancel_create_account]
      redirect_to root_path
    else
      super
    end
  end

  private

  def configure_permitted_parameters
    params[:user] = params[:user_registration]
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [
        :password_confirmation, :email, :age_over_13, :terms_of_service
      ]
    )
  end

end
