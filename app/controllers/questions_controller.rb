class QuestionsController < ApplicationController

  before_filter :load_archive_faq, :except => [:index, :update_positions]

  # GET /archive_faq/:archive_faq_id/questions/manage
  def manage
    @questions = @archive_faq.questions.order('position')
  end

  # fetch work these chapters belong to from db
  def load_archive_faq
    @archive_faq = ArchiveFaq.find_by_slug(params[:archive_faq_id])
    unless @archive_faq.present?
      flash[:error] = ts("Sorry, we couldn't find the ArchiveFaq you were looking for.")
      redirect_to root_path and return
    end
  end

  # Update the position number of Questions within a FAQ
  def update_positions
    if params[:questions]
      @archive_faq = ArchiveFaq.find_by_slug(params[:archive_faq_id])
      @archive_faq.reorder(params[:questions])
      flash[:notice] = ts("Question order has been successfully updated.")
    elsif params[:question]
      params[:question].each_with_index do |id, position|
        Question.update(id, :position => position + 1)
        (@questions ||= []) << Question.find(id)
      end
      flash[:notice] = ts("Question order has been successfully updated.2")
    end
    respond_to do |format|
      format.html { redirect_to(@archive_faq) and return }
      format.js { render :nothing => true }
    end
  end
end