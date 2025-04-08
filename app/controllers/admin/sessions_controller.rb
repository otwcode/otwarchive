# Namespaced Admin class
class Admin
  # Handle admin session authentication
  class SessionsController < Devise::SessionsController
    before_action :user_logout_required, except: :destroy
    skip_before_action :store_location, raise: false

    prepend_before_action :authenticate_with_otp_two_factor, 
      if: -> { action_name == 'create' && otp_two_factor_enabled? }
    
    protect_from_forgery with: :exception, prepend: true, except: :destroy

    # GET /admin/logout
    def confirm_logout
      # If the user is already logged out, we just redirect to the front page.
      redirect_to root_path unless admin_signed_in?
    end

    # Two-Factor Authentication
    def authenticate_with_otp_two_factor
      admin = self.resource = find_admin
  
      if admin_params[:otp_attempt].present? && session[:otp_admin_id]
        authenticate_admin_with_otp_two_factor(admin)
      elsif admin&.valid_password?(admin_params[:password])
        prompt_for_otp_two_factor(admin)
      end
    end
  
    private
  
    def valid_otp_attempt?(admin)
      admin.validate_and_consume_otp!(admin_params[:otp_attempt]) ||
        admin.invalidate_otp_backup_code!(admin_params[:otp_attempt])
    end
  
    def prompt_for_otp_two_factor(admin)
      @admin = admin
  
      session[:otp_admin_id] = admin.id

      render "admin/sessions/totp"
    end
  
    def authenticate_admin_with_otp_two_factor(admin)
      if valid_otp_attempt?(admin)
        # Remove any lingering admin data from login
        session.delete(:otp_admin_id)
  
        admin.save!

        flash[:notice] = t("devise.sessions.signed_in")
        sign_in(admin, event: :authentication)
        
        redirect_to admins_path
      else
        flash.now[:alert] = t(".invalid_totp")
        prompt_for_otp_two_factor(admin)
      end
    end
  
    def admin_params
      params.require(:admin).permit(:login, :password, :otp_attempt)
    end
  
    def find_admin
      if session[:otp_admin_id]
        Admin.find(session[:otp_admin_id])
      elsif admin_params[:login]
        Admin.find_by(login: admin_params[:login])
      end
    end
  
    def otp_two_factor_enabled?
      find_admin&.otp_required_for_login
    end
  end
end
