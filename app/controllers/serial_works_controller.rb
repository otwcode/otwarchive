class SerialWorksController < ApplicationController
  
  before_filter :author_only
  
  def author_only
    @serial_work = SerialWork.find(params[:id])
    unless logged_in? && !(current_user.pseuds & @serial_work.work.pseuds).empty?
      flash[:error] = t('errors.no_permission_to_edit', :default => "Sorry, but you don't have permission to make edits.")
      redirect_to(works_url) 
    end  
  end

  # DELETE /related_works/1
  # DELETE /related_works/1.xml
  def destroy
    @serial_work.destroy
    redirect_to :back
  end
end
