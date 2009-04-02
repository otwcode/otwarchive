class RelatedWorksController < ApplicationController
  
  before_filter :parent_author_only, :only => [ :show, :update ]
  before_filter :child_author_only, :only => :destroy
  
  def parent_author_only
    if params[:parent_id]
      @related_work = RelatedWork.find(:first, :conditions => {:parent_id => params[:parent_id], :work_id => params[:work_id]})
    else
      @related_work = RelatedWork.find(params[:id])
    end
    unless logged_in? && !(current_user.pseuds & @related_work.parent.pseuds).empty? 
      flash[:error] = t('errors.no_permission_to_edit', :default => "Sorry, but you don't have permission to make edits.")
      redirect_to(works_url)
    end  
  end
  
  def child_author_only
    if params[:parent_id]
      @related_work = RelatedWork.find(:first, :conditions => {:parent_id => params[:parent_id], :work_id => params[:work_id]})
    else
      @related_work = RelatedWork.find(params[:id])
    end
    unless logged_in? && !(current_user.pseuds & @related_work.work.pseuds).empty?
      flash[:error] = t('errors.no_permission_to_edit', :default => "Sorry, but you don't have permission to make edits.")
      redirect_to(works_url)
    end  
  end

  def index
    unless logged_in?
      flash[:error] = t('errors.no_permission_to_edit', :default => "Sorry, but you don't have permission to make edits.")
      redirect_to(works_url)
    end
    my_works = current_user.works.collect(&:id)
    @related_works = my_works.collect{|mw| RelatedWork.find(:all, :conditions => {:parent_id => mw})}.flatten.uniq
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
      notice = @related_work.reciprocal? ?  t('link_approved', :default => "Link was successfully approved") : 
                                            t('link_removed', :default => "Link was successfully removed")
      flash[:notice] = notice
      redirect_to(@related_work.parent) 
    else
      flash[:error] = t('failed_update', :default => 'Sorry, something went wrong. Please try again.')
      redirect_to(@related_work)
    end
  end

  # DELETE /related_works/1
  # DELETE /related_works/1.xml
  def destroy
    @related_work.destroy
    redirect_to :back
  end
end
