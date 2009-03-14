class Admin::UserCreationsController < ApplicationController
  
  before_filter :admin_only
  
  # Removes an object from public view
  def hide
    creation_class = params[:creation_type].constantize
    creation = creation_class.find(params[:id])
    creation.hidden_by_admin = (params[:hidden] == "true")
    creation.save(false)
    flash[:notice] = creation.hidden_by_admin? ? 
                        t('notices.admin_creations.item_hidden', :default => 'Item has been hidden.') : 
                        t('notices.admin_creations.item_unhidden', :default => 'Item is no longer hidden.')
   creation_class == Comment ? redirect_to(creation.ultimate_parent) : redirect_to(creation)    
  end
  
  def destroy
    creation_class = params[:creation_type].constantize
    creation = creation_class.find(params[:id])
    creation.destroy
    flash[:notice] = t('notices.admin_creations.item_deleted', :default => 'Item was successfully deleted.')
   redirect_to works_path
  end
  
end