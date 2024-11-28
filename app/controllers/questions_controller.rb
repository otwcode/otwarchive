class QuestionsController < ApplicationController
  before_action :load_archive_faq, except: :update_positions

  # GET /archive_faq/:archive_faq_id/questions/manage
  def manage
    authorize :archive_faq, :full_access?
    @questions = @archive_faq.questions.order("position")
  end

  # fetch archive_faq these questions belong to from db
  def load_archive_faq
    @archive_faq = ArchiveFaq.find_by(slug: params[:archive_faq_id])
    unless @archive_faq.present?
      flash[:error] = t("questions.not_found")
      redirect_to root_path and return
    end
  end

  # Update the position number of questions within a archive_faq
  def update_positions
    authorize :archive_faq, :full_access?
    if params[:questions]
      @archive_faq = ArchiveFaq.find_by(slug: params[:archive_faq_id])
      @archive_faq.reorder_list(params[:questions])
      flash[:notice] = t(".success")
    elsif params[:question]
      params[:question].each_with_index do |id, position|
        Question.update(id, position: position + 1)
        (@questions ||= []) << Question.find(id)
      end
      flash[:notice] = t(".success")
    end
    respond_to do |format|
      format.html { redirect_to(@archive_faq) and return }
      format.js { render nothing: true }
    end
  end
end
