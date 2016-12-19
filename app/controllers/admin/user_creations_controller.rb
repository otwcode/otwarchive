class Admin::UserCreationsController < ApplicationController
  
  before_filter :admin_only
  
  # Removes an object from public view
  def hide
    raise "Redshirt: Attempted to constantize invalid class initialize hide #{params[:creation_type]}" unless %w(ExternalWork Bookmark Work).include?(params[:creation_type])
    creation_class = params[:creation_type].constantize
    creation = creation_class.find(params[:id])
    creation.hidden_by_admin = (params[:hidden] == "true")
    creation.save(:validate => false)
    action = creation.hidden_by_admin? ? "hide" : "unhide"
    AdminActivity.log_action(current_admin, creation, action: action)
    flash[:notice] = creation.hidden_by_admin? ? 
                        ts('Item has been hidden.') :
                        ts('Item is no longer hidden.')
    if creation_class == Comment
      redirect_to(creation.ultimate_parent) 
    elsif creation_class == ExternalWork || creation_class == Bookmark
      redirect_to(request.env["HTTP_REFERER"] || root_path)
    else
      unless action  == "unhide"
        # Email users so they're aware of Abuse action
        orphan_account = User.orphan_account
        users = creation.pseuds.map(&:user).uniq
        users.each do |user|
          unless user == orphan_account
            UserMailer.admin_hidden_work_notification(creation.id, user.id).deliver
          end
        end
       end
      redirect_to(creation)
    end
  end

  def destroy
    raise "Redshirt: Attempted to constantize invalid class initialize destroy #{params[:creation_type]}" unless %w(ExternalWork Bookmark Work).include?(params[:creation_type])
    creation_class = params[:creation_type].constantize
    creation = creation_class.find(params[:id])
    AdminActivity.log_action(current_admin, creation, action: 'destroy', summary: creation.inspect)
    creation.destroy
    flash[:notice] = ts('Item was successfully deleted.')
    if creation_class == Comment 
      redirect_to(creation.ultimate_parent) 
    elsif creation_class == ExternalWork
      redirect_to bookmarks_path
    else
     redirect_to works_path
    end
  end
  
end
