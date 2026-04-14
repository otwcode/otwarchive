class Admin::UserCreationsController < Admin::BaseController
  before_action :get_creation, only: [:hide, :set_spam, :destroy]
  before_action :can_be_marked_as_spam, only: [:set_spam]

  def get_creation
    raise "Redshirt: Attempted to constantize invalid class initialize #{params[:creation_type]}" unless %w(Bookmark ExternalWork Series Work).include?(params[:creation_type])
    @creation_class = params[:creation_type].constantize
    @creation = @creation_class.find(params[:id])
  end
  
  def can_be_marked_as_spam
    unless @creation_class && @creation_class == Work
      flash[:error] = ts("You can only mark works as spam currently.")
      redirect_to polymorphic_path(@creation) and return
    end
  end
  
  # Removes an object from public view
  def hide
    authorize @creation
    @creation.hidden_by_admin = (params[:hidden] == "true")
    @creation.save(validate: false)
    action = @creation.hidden_by_admin? ? "hide" : "unhide"
    AdminActivity.log_action(current_admin, @creation, action: action)
    flash[:notice] = @creation.hidden_by_admin? ?
                        ts("Item has been hidden.") :
                        ts("Item is no longer hidden.")
    if @creation_class == ExternalWork || @creation_class == Bookmark
      redirect_back_or_to root_path
    else
      redirect_to polymorphic_path(@creation)
    end
  end  
  
  def set_spam
    authorize @creation
    action = "mark as " + (params[:spam] == "true" ? "spam" : "not spam")
    AdminActivity.log_action(current_admin, @creation, action: action, summary: @creation.inspect)    
    if params[:spam] == "true"
      unless @creation.hidden_by_admin
        @creation.notify_of_hiding_for_spam if @creation_class == Work
        @creation.hidden_by_admin = true
      end
      @creation.mark_as_spam!
      flash[:notice] = ts("Work was marked as spam and hidden.")
    else
      @creation.mark_as_ham!
      @creation.update_attribute(:hidden_by_admin, false)
      flash[:notice] = ts("Work was marked not spam and unhidden.")
    end
    redirect_to polymorphic_path(@creation)
  end

  def destroy
    authorize @creation
    AdminActivity.log_action(current_admin, @creation, action: "destroy", summary: @creation.inspect)
    @creation.destroy
    flash[:notice] = ts("Item was successfully deleted.")
    if @creation_class == Bookmark || @creation_class == ExternalWork
      redirect_to bookmarks_path
    else
      redirect_to works_path
    end
  end

  def confirm_remove_pseud
    @work = authorize Work.find(params[:id])

    @orphan_pseuds = @work.orphan_pseuds
    return unless @orphan_pseuds.empty?

    flash[:error] = t(".must_have_orphan_pseuds")
    redirect_to work_path(@work) and return
  end

  def remove_pseud
    @work = authorize Work.find(params[:id])

    pseuds = params[:pseuds]
    orphan_account = User.orphan_account
    if pseuds.blank?
      pseuds = @work.orphan_pseuds
      if pseuds.length > 1
        flash[:error] = t(".must_select_pseud")
        redirect_to work_path(@work) and return
      end
    else
      pseuds = Pseud.find(pseuds).select { |p| p.user_id == orphan_account.id }
    end

    orphan_pseud = orphan_account.default_pseud
    pseuds.each do |pseud|
      pseud.change_ownership(@work, orphan_pseud)
    end
    unless pseuds.empty?
      AdminActivity.log_action(current_admin, @work, action: "remove orphan_account pseuds")
      flash[:notice] = t(".success", pseuds: pseuds.map(&:byline).to_sentence, count: pseuds.length)
    end
    redirect_to work_path(@work)
  end
end
