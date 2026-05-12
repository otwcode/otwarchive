class RelatedWorksController < ApplicationController

  before_action :load_user, only: [:index]
  before_action :users_only, except: [:index]
  before_action :get_instance_variables, except: [:index]

  def index
    @page_subtitle = t(".page_title", login: @user.login)

    related_works = @user.related_works.visible_on_user_page(@user).visible_works
    parent_work_relationships = @user.parent_work_relationships.visible_on_user_page(@user)
    local_parent_work_relationships = parent_work_relationships.of_visible_local_works
    external_parent_work_relationships = parent_work_relationships.of_visible_external_works

    @translations_of_user = related_works.translations
    @remixes_of_user = related_works.remixes
    @translations_by_user = (local_parent_work_relationships.translations + external_parent_work_relationships.translations).sort
    @remixes_by_user = (local_parent_work_relationships.remixes + external_parent_work_relationships.remixes).sort
  end

  # GET /related_works/1
  # GET /related_works/1.xml
  def show
  end

  def update
    # updates are done by the owner of the parent, to approve or remove links on the parent work.
    unless @user
      if current_user_owns?(@child)
        flash[:error] = ts("Sorry, but you don't have permission to do that. Try removing the link from your own work.")
        redirect_to user_related_works_path(current_user)
      else
        flash[:error] = ts("Sorry, but you don't have permission to do that.")
        redirect_to root_path
      end
      return
    end
    # the assumption here is that any update is a toggle from what was before
    @related_work.reciprocal = !@related_work.reciprocal?
    if @related_work.update_attribute(:reciprocal, @related_work.reciprocal)
      notice = @related_work.reciprocal? ?  ts("Link was successfully approved") :
                                            ts("Link was successfully removed")
      flash[:notice] = notice
      redirect_to(@related_work.parent)
    else
      flash[:error] = ts('Sorry, something went wrong.')
      redirect_to(@related_work)
    end
  end

  def destroy
    # destroys are done by the owner of the child, to remove links to the parent work which also removes the link back if it exists.
    unless current_user_owns?(@child)
      if @user
        flash[:error] = ts("Sorry, but you don't have permission to do that. You can only approve or remove the link from your own work.")
        redirect_to user_related_works_path(current_user)
      else
        flash[:error] = ts("Sorry, but you don't have permission to do that.")
        redirect_to root_path
      end
      return
    end
    @related_work.destroy
    redirect_back_or_to user_related_works_path(current_user)
  end

  private

  def load_user
    @user = User.find_by!(login: params[:user_id])
  end

  def get_instance_variables
    @related_work = RelatedWork.find(params[:id])
    @child = @related_work.work
    if @related_work.parent.is_a? (Work)
      @owners = @related_work.parent.pseuds.map(&:user)
      @user = current_user if @owners.include?(current_user)
    end
  end

end
