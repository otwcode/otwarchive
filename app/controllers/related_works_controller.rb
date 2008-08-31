class RelatedWorksController < ApplicationController
  
  before_filter :parent_author_only, :only => [ :show, :update ]
  before_filter :child_author_only, :only => :destroy
  
  def parent_author_only
    if params[:parent_id]
      @related_work = RelatedWork.find(:first, :conditions => {:parent_id => params[:parent_id], :work_id => params[:work_id]})
    else
      @related_work = RelatedWork.find(params[:id])
    end
    (logged_in? && !(current_user.pseuds & @related_work.parent.pseuds).empty?) || [ redirect_to(works_url), flash[:error] = 'Sorry, but you don\'t have permission to make edits.'.t ]  
  end
  
  def child_author_only
    if params[:parent_id]
      @related_work = RelatedWork.find(:first, :conditions => {:parent_id => params[:parent_id], :work_id => params[:work_id]})
    else
      @related_work = RelatedWork.find(params[:id])
    end
    (logged_in? && !(current_user.pseuds & @related_work.work.pseuds).empty?) || [ redirect_to(works_url), flash[:error] = 'Sorry, but you don\'t have permission to make edits.'.t ]  
  end

  # GET /related_works/1
  # GET /related_works/1.xml
  def show
  end

  # PUT /related_works/1
  # PUT /related_works/1.xml
  def update
    @related_work.reciprocal = !@related_work.reciprocal?
    if @related_work.update_attribute(:reciprocal, @related_work.reciprocal)
      status = @related_work.reciprocal? ? "approved" : "removed"
      flash[:notice] = "Link was successfully #{status}.".t
      redirect_to(@related_work.parent) 
    else
      flash[:notice] = 'Please try again.'.t
      redirect_to(@related_work)
    end
  end

  # DELETE /related_works/1
  # DELETE /related_works/1.xml
  def destroy
    @related_work.destroy
    redirect_to(current_user)
  end
end
