class FeedbacksController < ApplicationController
  before_filter :load_support_languages

  skip_after_filter :store_location

  def new
    @feedback = Feedback.new
    if admin_signed_in?
      @feedback.email = current_admin.email
    elsif user_signed_in?
      @feedback.email = current_user.email
      @feedback.username = current_user.login
    end
  end

  def create
    @feedback = Feedback.new(params[:feedback])
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

end
