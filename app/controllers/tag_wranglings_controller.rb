class TagWranglingsController < ApplicationController

  before_filter :check_user_status
  before_filter :login_required
  def authorized?
    logged_in_as_admin? || permit?("tag_wrangler")
  end

  def index
  end

  def fandom_to_media
    @medias = Media.canonical
    @fandoms = Fandom.canonical.no_media
    if @fandoms.blank?
      flash[:warning] = "No fandoms left to assign"
      redirect_to tag_wranglings_path and return
    end
  end

  def character_to_fandom
    @fandoms = Fandom.canonical
    @characters = Character.canonical.no_fandom
    if @characters.blank?
      flash[:warning] = "No characters left to assign"
      redirect_to tag_wranglings_path and return
    end
  end

  def pairing_to_fandom
    @fandoms = Fandom.canonical
    @pairings = Pairing.canonical.no_fandom
    if @pairings.blank?
      flash[:warning] = "No pairings left to assign"
      redirect_to tag_wranglings_path and return
    end
  end

  def character_to_pairing
    @pairings = Pairing.canonical.no_characters
    @characters = Character.canonical
    if @pairings.blank?
      flash[:warning] = "No pairings left which need assignment"
      redirect_to tag_wranglings_path and return
    end
  end

  def create
    commit = params[:commit]
    if commit == "Assign to Media"
      if params[:media][:media_id].blank? || params[:tags].blank?
        flash[:error] = "Please select some fandoms and a media"
      else
        media = Media.find_by_id(params[:media][:media_id])
        tags = params[:tags].collect {|t| Tag.find_by_name(t)}
        tags.each do |tag|
          tag.update_attribute(:media_id, media.id)
          tag.update_attribute(:canonical, true) if params[:canonical]
        end
      end
      redirect_to fandom_to_media_tag_wranglings_path
    elsif commit == "Assign to Fandom"
      if params[:fandom][:fandom_id].blank? || params[:tags].blank?
        flash[:error] = "Please select some tags and a fandom"
      else
        fandom = Fandom.find_by_id(params[:fandom][:fandom_id])
        tags = params[:tags].collect {|t| Tag.find_by_name(t)}
        tags.each do |tag|
          tag.update_attribute(:fandom_id, fandom.id)
          tag.update_attribute(:canonical, true) if params[:canonical]
        end
      end
      redirect_to :back
    elsif commit == "Assign to Pairing"
      if params[:pairing][:pairing_id].blank? || params[:tags].blank?
        flash[:error] = "Please select some fandoms and a media"
      else
        pairing = Pairing.find_by_id(params[:pairing][:pairing_id])
        tags = params[:tags].collect {|t| Tag.find_by_name(t)}
        tags.each do |tag|
          tag.update_attribute(:canonical, true) if params[:canonical]
          tag.add_pairing(pairing.id)
        end
      end
      redirect_to character_to_pairing_tag_wranglings_path
    elsif commit == "Refresh"
      @category = params[:id].constantize
      if !logged_in_as_admin? && !Tag::USER_DEFINED.include?(@category.name)
        flash[:error] = "Please log in as admin"
        redirect_to tag_wranglings_path and return
      end
      setup_edit_vars
      render :action => "edit"
    elsif commit == "Show Fandom"
      setup_show_vars
      render :action => "show"
    elsif commit == "Update all tags"
      setup_edit_vars
      if params[:canonical]
        old_canonical = @tags.select(&:canonical).map(&:id)
        new_canonical = params[:canonical].map(&:to_i)
        (old_canonical-new_canonical).each do |id|
          Tag.find_by_id(id).wrangle_not_canonical
        end
        (new_canonical-old_canonical).each do |id|
          Tag.find_by_id(id).wrangle_canonical
        end
      end
      if params[:merger]
        params[:merger].each do |key, value|
          unless value.blank?
            Tag.find_by_id(key).wrangle_merger(Tag.find_by_id(value))
          end
        end
      end
      if !params[:add_to_fandom].blank?
        if @fandom.is_a?(Fandom)
          params[:add_to_fandom].each do |id|
            Tag.find_by_id(id).update_attribute(:fandom_id, @fandom.id)
          end
        else
          flash[:error] = "Please choose a fandom"
        end
      end
      if !params[:remove_from_fandom].blank?
        params[:remove_from_fandom].each do |id|
          Tag.find_by_id(id).update_attribute(:fandom_id, nil)
        end
      end
      setup_edit_vars
      render :action => "edit"
    else
      flash[:error] = "Please choose something"
      redirect_to tag_wranglings_path
    end
  end

  def edit
    @category = params[:id].constantize
    if !logged_in_as_admin? && !Tag::USER_DEFINED.include?(@category.name)
      flash[:error] = "Please log in as admin"
      redirect_to tag_wranglings_path and return
    end
    setup_edit_vars
  end

  def show
    setup_show_vars
  end

protected
  def setup_edit_vars
    @category = params[:id].constantize
    @fandoms = Fandom.canonical if (Tag::USER_DEFINED - ['Fandom']).include?(@category.name)
    if params[:fandom] && !params[:fandom][:fandom_id].blank?
      @fandom = Fandom.find_by_id(params[:fandom][:fandom_id])
      @tags = @category.unwrangled.by_fandom(@fandom).by_name
    else
      @tags = @category.unwrangled.no_fandom.by_name
    end
  end

  def setup_show_vars
    @category = params[:id].constantize
    @fandoms = Fandom.canonical if (Tag::USER_DEFINED - ['Fandom']).include?(@category.name)
    if params[:fandom] && !params[:fandom][:fandom_id].blank?
      @fandom = Fandom.find_by_id(params[:fandom][:fandom_id])
      @tags = @category.by_fandom(@fandom).by_name
    else
      @tags = @category.no_fandom.by_name
    end
  end
end
