class TagWranglingsController < ApplicationController

  before_filter :check_user_status
  before_filter :login_required
  def authorized?
    logged_in_as_admin? || permit?("tag_wrangler")
  end

  def index
  end

  def create
    commit = params[:commit]
    if commit == "Assign"
      if params[:parent][:parent_id].blank? || params[:tags].blank?
        flash[:error] = "Please select some tags and a parent"
      else
        tags = params[:tags].collect {|t| Tag.find_by_name(t)}
        tags.each do |tag|
          tag.add_parent(params[:parent][:parent_id])
        end
      end
      redirect_to :back
    elsif commit == "Wrangle"
      @category = params[:id]
      if !logged_in_as_admin? && !Tag::USER_DEFINED.include?(@category)
        flash[:error] = "Please log in as admin"
        redirect_to tag_wranglings_path and return
      end
      setup_edit_vars
      render :action => "edit"
    elsif commit == "Update all tags"
      @category = params[:id]
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
      if params[:banned]
        if !logged_in_as_admin?
          flash[:error] = "Please log in as admin"
          redirect_to tag_wranglings_path and return
        else
          to_ban = params[:banned].map(&:to_i)
          to_ban.each do |id|
            Tag.find_by_id(id).update_attribute(:type, "Banned")
          end
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
      @category = params[:id]
      setup_edit_vars
      render :action => "edit"
    else
      flash[:error] = "Please choose something"
      redirect_to tag_wranglings_path
    end
  end

  def assign
    @category = params[:id]
    if @category == "Fandom"
      @possible_parents = Media.canonical.by_name
    elsif Tag::USER_DEFINED.include?(@category)
      @possible_parents = Fandom.canonical.by_name
    else
      flash[:error] = "Sorry, you can't mass assign that"
      redirect_to tag_wranglings_path
    end
  end

  def edit
    @category = params[:id]
    if !logged_in_as_admin? && !Tag::USER_DEFINED.include?(@category)
      flash[:error] = "Please log in as admin"
      redirect_to tag_wranglings_path and return
    end
    setup_edit_vars
  end

protected

  def setup_edit_vars
    if @category == "Fandom"
      @medias = Media.canonical.by_name
      if params[:media] && !params[:media][:media_id].blank?
        @media = Media.find_by_id(params[:media][:media_id])
        @tags = @category.constantize.by_media(@media).by_name
        if @tags.blank?
          flash[:error] = "No tags found"
        end
      end
    elsif @category == "Ambiguity"
      @ambiguity = true
      @tags = @category.constantize.by_name
    elsif Tag::USER_DEFINED.include? @category
      @fandoms = Fandom.canonical.by_name
      if params[:fandom] && !params[:fandom][:fandom_id].blank?
        @fandom = Fandom.find_by_id(params[:fandom][:fandom_id])
        @tags = @category.constantize.by_fandom(@fandom).by_name
        if @tags.blank?
          flash[:error] = "No tags found"
        end
      end
    else
      @tags = @category.constantize.by_name
    end
  end
end
