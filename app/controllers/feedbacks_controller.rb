class FeedbacksController < ApplicationController
  skip_before_filter :store_location
  before_filter :load_support_languages

  def new
    @feedback = Feedback.new
    if logged_in_as_admin?
      @feedback.email = current_admin.email
    elsif is_registered_user?
      @feedback.email = current_user.email
      @feedback.username = current_user.login
    end
  end

  def create
    @feedback = Feedback.new(feedback_params)
    language_name = Language.find_by_id(@feedback.language).name
    @feedback.language = language_name
    if @feedback.save
      @feedback.email_and_send
      flash[:notice] = t("successfully_sent",
        default: "Your message was sent to the Archive team - thank you!")
      redirect_back_or_default(root_path)
    else
      flash[:error] = t("failure_send",
        default: "Sorry, your message could not be saved - please try again!")
      render action: "new"
    end
  end

  def load_support_languages
    @support_languages = Language.where(support_available: true).order(:name)
  end

  private

  def feedback_params
    params.require(:feedback).permit(
      :comment, :email, :summary, :user_agent,
      :ip_address, :username, :language
    )
  end

end
