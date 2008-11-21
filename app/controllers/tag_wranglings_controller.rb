class TagWranglingsController < ApplicationController   

  before_filter :check_user_status
  before_filter :login_required
  def authorized?
    logged_in_as_admin? || permit?("tag_wrangler")
  end
  
  def index    
    @unwrangled_fandoms = Fandom.unwrangled.sort
    @media = Media.canonical.sort
    respond_to do |format|
      format.html 
      format.js
    end
  end

  def create
    commit = params[:commit]
    if commit == "Assign to Media"
      fandom_ids = params[:fandom_ids]
      media = Media.find_by_id(params[:media_id])
      if !media || fandom_ids.blank?
        flash[:error] = "Please select some fandoms and a media"
      else
        fandom_ids.each do |id| 
          fandom = Fandom.find_by_id(id)
          fandom.update_attribute(:media_id, media.id)
          fandom.update_attribute(:canonical, true)
          fandom.update_attribute(:wrangled, true)
        end
      end
    else
      flash[:error] = "Please choose something"
    end
    redirect_to tag_wranglings_path
  end
end
