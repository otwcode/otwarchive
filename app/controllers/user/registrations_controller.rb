class User
  # Handle user devise registration
  class RegistrationsController < Devise::RegistrationsController
    before_filter :configure_sign_up_params, only: :create
    before_filter :hide_dashboard, only: [:new, :create, :destroy]
    before_filter :can_create_account?, only: [:new, :create]

    skip_after_filter :store_location, except: :new

    def new
      super do |user|
        @invitation = Invitation.find_by_token(params[:invitation_token])

        if @invitation
          user.invitation_token = @invitation.token
          user.email = @invitation.invitee_email
        end
      end
    end

    def create
      super do |user|
        if user.persisted? && Rails.env.development?
          flash.now[:notice] = ts(
            "During testing you can activate via <a href='%{url}'>your activation url</a>.",
            url: confirmation_url(user, confirmation_token: user.confirmation_token)
          ).html_safe
        end
      end
    end

    def destroy
      works = @user.works.find(:all, conditions: { posted: true })
      @sole_owned_collections = @user.collections.select do |collection|
        (collection.all_owners - @user.pseuds).empty?
      end

      if works.empty? && @sole_owned_collections.empty?
        @user.wipeout_unposted_works if @user.unposted_works
        @user.destroy

        sign_out(:user)
      elsif params[:coauthor].blank? && params[:sole_author].blank?
        @sole_authored_works = @user.sole_authored_works
        @coauthored_works = @user.coauthored_works

        render 'delete_preview'
        return
      elsif params[:coauthor] || params[:sole_author]
        destroy_author
      end
    end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.for(:user) do |u|
        u.permit(:age_over_13, :terms_of_service, :invitation_token)
      end
    end

    # Hide user dashboard on user creation or destroy
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

    # Destroy user after checking what to do with it's works
    def destroy_author
      @sole_authored_works = @user.sole_authored_works
      @coauthored_works = @user.coauthored_works

      if params[:cancel_button]
        flash[:notice] = ts('Account deletion canceled.')
        redirect_to user_profile_path(@user)
        return
      end

      if %w(keep_pseud orphan_pseud).include? params[:coauthor]
        pseuds = @user.pseuds
        works = @coauthored_works

        # We change the pseud to the default orphan pseud if use_default is true
        use_default = params[:use_default] == 'true' ||
                      params[:coauthor] == 'orphan_pseud'

        Creatorship.orphan(pseuds, works, use_default)
      elsif params[:coauthor] == 'remove'
        # Removes user as an author from co-authored works
        @coauthored_works.each do |w|
          w.pseuds = w.pseuds - @user.pseuds
          w.save
          w.chapters.each do |c|
            c.pseuds = c.pseuds - @user.pseuds
            c.pseuds = w.pseuds if c.pseuds.empty?
            c.save
          end
        end
      end

      if %w(keep_pseud orphan_pseud).include? params[:sole_author]
        # We change the pseud to default orphan pseud if use_default is true.
        use_default = params[:use_default] == 'true' ||
                      params[:sole_author] == 'orphan_pseud'

        Creatorship.orphan(@user.pseuds, @sole_authored_works, use_default)
        Collection.orphan(@user.pseuds, @sole_owned_collections, use_default)
      elsif params[:sole_author] == 'delete'
        # Deletes works where user is sole author
        @sole_authored_works.each(&:destroy)

        # Deletes collections where user is sole author
        @sole_owned_collections.each(&:destroy)
      end

      works = @user.works.find(:all, conditions: { posted: true })

      if works.blank?
        @user.wipeout_unposted_works if @user.unposted_works
        @user.destroy

        sign_out(:user)
      else
        flash[:error] = ts('Sorry, something went wrong! Please try again.')
        redirect_to(@user)
        return
      end
    end
  end
end
