class Admin::UserCreationsController < ApplicationController
  
  before_filter :admin_only
  
  # Removes an object from public view
  def hide
    creation_class = params[:creation_type].constantize
    creation = creation_class.find(params[:id])
    creation.hidden_by_admin = (params[:hidden] == "true")
    creation.save(:validate => false)
    action = creation.hidden_by_admin? ? "hide" : "unhide"
    AdminActivity.log_action(current_admin, creation, action: action)
    setflash; flash[:notice] = creation.hidden_by_admin? ? 
                        t('item_hidden', :default => 'Item has been hidden.') : 
                        t('item_unhidden', :default => 'Item is no longer hidden.')
    if creation_class == Comment 
      redirect_to(creation.ultimate_parent) 
    elsif creation_class == ExternalWork
      redirect_to(request.env["HTTP_REFERER"] || root_path)
    else
     redirect_to(creation)
    end
  end
  
  def destroy
    creation_class = params[:creation_type].constantize
    creation = creation_class.find(params[:id])
    AdminActivity.log_action(current_admin, creation, action: 'destroy', summary: creation.inspect)
    creation.destroy
    setflash; flash[:notice] = t('item_deleted', :default => 'Item was successfully deleted.')
    if creation_class == Comment 
      redirect_to(creation.ultimate_parent) 
    elsif creation_class == ExternalWork
      redirect_to bookmarks_path
    else
     redirect_to works_path
    end
  end
  
end