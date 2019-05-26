# frozen_string_literal: true

# A controller used to let admins and tag wranglers perform some
# troubleshooting on tags and works.
class TroubleshootingController < ApplicationController
  before_action :check_permission_to_wrangle
  before_action :load_item
  before_action :check_visibility

  # Display options for troubleshooting.
  def show
    @item_type = @item.class.base_class.model_name.human
    @page_subtitle = ts("Troubleshoot %{type}",
                        type: @item_type)
  end

  # Perform the desired troubleshooting actions.
  def update
    actions = params.fetch(:actions, []).map(&:to_s).reject(&:blank?)

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

  protected

  # Calculate the permitted actions based on the item type and whether the
  # current user is an admin. This is used in the show action to figure out
  # which options to display, and in the update action to figure out which
  # actions to perform.
  #
  # In order to work properly, this needs to return a list of strings, and each
  # string needs to be the name of an instance method in this class. To make
  # the list of options display properly (with a name and a description), each
  # of these names also needs a corresponding title and description entry in
  # the i18n scope en.troubleshooting.show.
  def allowed_actions
    if @item.is_a?(Tag) && logged_in_as_admin?
      %w[fix_associations fix_counts fix_meta_tags update_tag_filters reindex_tag]
    elsif @item.is_a?(Tag)
      %w[fix_associations fix_counts fix_meta_tags]
    elsif @item.is_a?(Work)
      %w[update_work_filters reindex_work]
    end
  end

  # Let the views use these two path methods.
  helper_method :item_path, :troubleshooting_path

  # The path to view the item. Ideally we could just do redirect_to @item, but
  # unfortunately we're dealing with tags, which have numerous subclasses.
  def item_path
    if @item.is_a?(Tag)
      tag_path(@item)
    else
      polymorphic_path(@item)
    end
  end

  # The path to view the troubleshooting page for this item. Again, this is
  # necessary because tags have a lot of subclasses and need special handling.
  def troubleshooting_path
    if @item.is_a?(Tag)
      tag_troubleshooting_path(@item)
    else
      polymorphic_path([@item, :troubleshooting])
    end
  end

  # Load the @item based on params. Results in a 404 error if the item in
  # question can't be found, and a 500 error if there's an unknoqn type. Also
  # sets the variable @allowed_actions.
  def load_item
    if params[:tag_id]
      @item = Tag.find_by_name(params[:tag_id])

      if @item.nil?
        raise ActiveRecord::RecordNotFound,
          ts("Could not find tag with name '%{name}'", name: params[:tag_id])
      end
    elsif params[:work_id]
      @item = Work.find(params[:work_id])
    else
      raise "Unknown item type!"
    end

    @check_visibility_of = @item
    @allowed_actions = allowed_actions
  end

  ########################################
  # AVAILABLE ACTIONS
  ########################################

  # An action allowing the user to reindex a work.
  def reindex_work
    @item.enqueue_to_index
    flash[:notice] << ts("Work sent to be reindexed.")
  end

  # An action allowing the user to reindex a tag (and everything related to it).
  def reindex_tag
    @item.async(:reindex_all, true)
    flash[:notice] << ts("Tag reindex job added to queue.")
  end

  # An action allowing the user to try to fix the filters for this tag and all
  # of its synonyms.
  def update_tag_filters
    @item.async(:update_filters_for_taggables)

    @item.synonyms.find_each do |syn|
      syn.async(:update_filters_for_taggables)
    end

    flash[:notice] << ts("Tagged items enqueued for filter updates.")
  end

  # An action allowing the user to try to fix a single work's filters.
  def update_work_filters
    @item.update_filters
    flash[:notice] << ts("Work filters updated.")
  end

  # An action allowing the user to try to fix the filter count and taggings
  # count.
  def fix_counts
    @item.filter_count.update_counts if @item.filter_count
    @item.update(taggings_count: @item.taggings.count)
    flash[:notice] << ts("Tag counts updated.")
  end

  # An action allowing the user to try to fix the inherited meta tags.
  def fix_meta_tags
    MetaTagging.transaction do
      InheritedMetaTagUpdater.new(@item).update
    end

    # Fixing the meta taggings is all well and good, but unless the filters are
    # adjusted too, this will have no immediate effects.
    @item.async(:update_filters_for_filterables)

    flash[:notice] << ts("Inherited meta tags recalculated. This tag has " \
                         "also been enqueued to have its filters fixed.")
  end

  # An action allowing the user to try to delete invalid associations. Needs
  # AO3-2452 to work properly, so it shouldn't be enabled until then.
  def fix_associations
    @item.async(:destroy_invalid_associations)
    flash[:notice] << ts("Tag association job enqueued.")
  end
end
