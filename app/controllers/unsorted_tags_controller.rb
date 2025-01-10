class UnsortedTagsController < ApplicationController
  include WranglingHelper

  before_action :check_user_status
  before_action :check_permission_to_wrangle

  def index
    authorize :wrangling, :read_access? if logged_in_as_admin?

    @tags = UnsortedTag.page(params[:page])
    @counts = tag_counts_per_category
  end

  def mass_update
    authorize :wrangling if logged_in_as_admin?

    if params[:tags].present?
      params[:tags].delete_if { |_, tag_type| tag_type.blank? }
      tags = UnsortedTag.where(id: params[:tags].keys)
      tags.each do |tag|
        new_type = params[:tags][tag.id.to_s]
        if %w(Fandom Character Relationship Freeform).include?(new_type)
          tag.update_attribute(:type, new_type)
        else
          raise ts("#{new_type} is not a valid tag type")
        end
      end
      flash[:notice] = ts("Tags were successfully sorted.")
    end
    redirect_to unsorted_tags_path(page: params[:page])
  end

end
