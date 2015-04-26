class FeedbacksController < ApplicationController
  skip_before_filter :store_location

  def new
    @feedback = Feedback.new
    if logged_in_as_admin?
      @feedback.email = current_admin.email
    elsif is_registered_user?
      @feedback.email = current_user.email
    end
  end

  def create
    @feedback = Feedback.new(params[:feedback])
    if @feedback.save
      @feedback.email_and_send
      flash[:notice] = t("successfully_sent",
        default: "Your message was sent to the archive team - thank you!")
      redirect_back_or_default(root_path)
    else
      flash[:error] = t("failure_send",
        default: "Sorry, your message could not be saved - please try again!")
      render action: "new"
    end
  end

end
