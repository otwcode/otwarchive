class UnsortedTagsController < ApplicationController

  before_filter :check_user_status
	before_filter :check_permission_to_wrangle

  def index
    @tags = UnsortedTag.paginate(:page => params[:page])
  end
  
  def mass_update
    unless params[:tags].blank?
      params[:tags].delete_if {|tag_id, tag_type| tag_type.blank? }
      tags = UnsortedTag.find(params[:tags].keys)
      tags.each do |tag|
        new_type = params[:tags][tag.id.to_s]
        if %w(Fandom Character Relationship Freeform).include?(new_type)
          tag.update_attribute(:type, new_type)
        else
          raise "#{new_type} is not a valid tag type"
        end
      end
      flash[:notice] = ts("Tags were successfully sorted.")
    end
    redirect_to unsorted_tags_path
  end
  	
end