class RelatedWorksController < ApplicationController
  
  before_filter :parent_author_only, :only => [ :show, :update ]
  before_filter :child_author_only, :only => :destroy
  
  def parent_author_only
    @related_work = RelatedWork.find(params[:id])
    (logged_in? && !(current_user.pseuds & @related_work.parent.pseuds).empty?) || [ redirect_to(works_url), flash[:error] = 'Sorry, but you don\'t have permission to make edits.' ]  
  end
  
  def child_author_only
    @related_work = RelatedWork.find(params[:id])
    (logged_in? && !(current_user.pseuds & @related_work.work.pseuds).empty?) || [ redirect_to(works_url), flash[:error] = 'Sorry, but you don\'t have permission to make edits.' ]  
  end

  # GET /related_works/1
  # GET /related_works/1.xml
  def show
  end

  # PUT /related_works/1
  # PUT /related_works/1.xml
  def update
    if @related_work.update_attributes(params[:related_work])
      flash[:notice] = 'Link was successfully approved.'
      redirect_to(@related_work.parent) 
    else
      flash[:notice] = 'Please try again.'
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
