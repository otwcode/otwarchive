class Admin::SpamController < ApplicationController
  before_action :admin_only

  def index
    conditions =  case params[:show]
                  when "reviewed"
                    { reviewed: true, approved: false }
                  when "approved"
                    { approved: true }
                  else
                    { reviewed: false, approved: false }
                  end
    @works = ModeratedWork.where(conditions).order(:created_at).page(params[:page])
  end

  def bulk_update
    if ModeratedWork.bulk_update(spam_params)
      flash[:notice] = "Works were successfully updated"
    else
      flash[:error] = "Sorry, please try again"
    end
    redirect_to admin_spam_index_path
  end

  private

  def spam_params
    params.slice(:spam, :ham)
  end
end
