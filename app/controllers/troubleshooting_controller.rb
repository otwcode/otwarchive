class TroubleshootingController < ApplicationController
  before_action :check_permission_to_wrangle
  before_action :load_item

  def show
  end

  def update
    actions = params[:actions].map(&:to_s).reject(&:blank?)

    disallowed = actions - @allowed_actions

    if disallowed.any?
      flash[:error] = 
        ts("The following actions aren't allowed: %{actions}.",
           actions: disallowed.to_sentence)
      redirect_to troubleshooting_path
      return
    end

    flash[:notice] = []
    flash[:error] = []

    (@allowed_actions & actions).each do |action|
      send(action)
    end

    # Make sure that we don't show blank errors.
    flash[:notice] = nil if flash[:notice].blank?
    flash[:error] = nil if flash[:error].blank?

    redirect_to item_path
  end

  def allowed_actions
    if @item.is_a?(Tag) && logged_in_as_admin?
      %w[fix_counts fix_associations update_tag_filters reindex_tag]
    elsif @item.is_a?(Tag)
      %w[fix_counts fix_associations]
    elsif @item.is_a?(Work)
      %w[update_work_filters reindex_work]
    end
  end

  protected

  helper_method :item_path, :troubleshooting_path

  def item_path
    if @item.is_a?(Tag)
      tag_path(@item)
    else
      polymorphic_path(@item)
    end
  end

  def troubleshooting_path
    if @item.is_a?(Tag)
      tag_troubleshooting_path(@item)
    else
      polymorphic_path([@item, :troubleshooting])
    end
  end

  def load_item
    if params[:tag_id]
      @item = Tag.find_by_name(params[:tag_id])

      if @item.nil?
        raise ActiveRecord::RecordNotFound,
          ts("Could not find tag with name '%{name}'", name: string)
      end
    elsif params[:work_id]
      @item = Work.find(params[:work_id])
    else
      raise "Unknown item type!"
    end

    @allowed_actions = allowed_actions
  end

  def reindex_work
    @item.enqueue_to_index
    flash[:notice] << ts("Work sent to be reindexed.")
  end

  def reindex_tag
    if logged_in_as_admin?
      @item.async(:reindex_all, true)
      flash[:notice] << ts("Tag reindex job added to queue.")
    else
      flash[:error] << ts("Only admins are allowed to reindex tags.")
    end
  end

  def update_tag_filters
    if logged_in_as_admin?
      @item.async(:update_filters_for_taggables)

      @item.synonyms.find_each do |syn|
        syn.async(:update_filters_for_taggables)
      end

      flash[:notice] << ts("Tagged items enqueued for filter updates.")
    else
      flash[:error] << ts("Only admins are allowed to reindex tags.")
    end
  end

  def update_work_filters
    @item.update_filters
    flash[:notice] << ts("Work filters updated.")
  end

  def fix_counts
    @item.filter_count.update_counts
    @item.taggings_count = @item.taggings.count
    flash[:notice] << ts("Tag counts updated.")
  end

  def fix_associations
    @item.async(:fix_associations)
    flash[:notice] << ts("Tag association job enqueued.")
  end
end
