class QuestionController <


  # GET /archive_faqs/manage
  def manage
    @archive_faqs_questions = Question.order('position ASC')
  end

  # reorder FAQ Questions
  def update_positions
    if params[:question]
      @archive_faqs_questions = Question.reorder(params[:question])
      setflash; flash[:notice] = ts("Archive FAQ Question order was successfully updated.")
    elsif params[:question]
      params[:question].each_with_index do |id, position|
        ArchiveFaq.update(id, :position => position + 1)
        (@archive_faqs ||= []) << ArchiveFaq.find(id)
      end
    end
    respond_to do |format|
      format.html { redirect_to(archive_faqs_path) }
      format.js { render :nothing => true }
    end
  end
  end