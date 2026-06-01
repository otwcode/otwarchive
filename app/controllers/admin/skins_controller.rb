class Admin::SkinsController < Admin::BaseController

  def index
    authorize Skin
    @unapproved_skins = Skin.unapproved_skins.sort_by_recent
  end

  def index_rejected
    authorize Skin
    @rejected_skins = Skin.rejected_skins.sort_by_recent
  end

  def index_approved
    authorize Skin
    @approved_skins = Skin.approved_skins.usable.sort_by_recent
  end

  def update
    authorize Skin, :index?

    flash[:notice] = []
    modified_skin_titles = []
    %w(official rejected cached featured in_chooser).each do |action|
      skins_to_set = params["make_#{action}"] ? Skin.where(id: params["make_#{action}"].map {|id| id.to_i}) : []
      skins_to_unset = params["make_un#{action}"] ? Skin.where(id: params["make_un#{action}"].map {|id| id.to_i}) : []
      skins_to_set.each do |skin|
        # Silently fail if the user doesn't have permission to update:
        next unless policy(skin).update?

        case action
        when "official"
          skin.update_attribute(:official, true)
        when "rejected"
          skin.update_attribute(:rejected, true)
        when "cached"
          next unless skin.official? && !skin.is_a?(WorkSkin)
          skin.cache!
        when "featured"
          next unless skin.official? && !skin.is_a?(WorkSkin)
          skin.cache! unless skin.cached?
          skin.update_attribute(:featured, true)
        when "in_chooser"
          next unless skin.official? && !skin.is_a?(WorkSkin)
          skin.cache! unless skin.cached?
          skin.update_attribute(:in_chooser, true)
        end
        skin.update_attribute(:admin_note, params[:skin_admin_note]["#{skin.id}"]) if params[:skin_admin_note] && params[:skin_admin_note]["#{skin.id}"]
        modified_skin_titles << skin.title
      end

      skins_to_unset.each do |skin|
        # Silently fail if the user doesn't have permission to update:
        next unless policy(skin).update?

        case action
        when "official"
          skin.clear_cache! # no cache for unofficial skins
          skin.update_attribute(:official, false)
          skin.remove_me_from_preferences
        when "rejected"
          skin.update_attribute(:rejected, false)
        when "cached"
          next unless skin.official? && !skin.is_a?(WorkSkin)
          skin.clear_cache! if skin.cached?
        when "featured"
          next unless skin.official? && !skin.is_a?(WorkSkin)
          skin.update_attribute(:featured, false)
        when "in_chooser"
          next unless skin.official? && !skin.is_a?(WorkSkin)
          skin.update_attribute(:in_chooser, false)
        end
        modified_skin_titles << skin.title
      end
    end

    flash[:notice] << ts("The following skins were updated: %{titles}", titles: modified_skin_titles.join(', '))

    redirect_to admin_skins_path
  end

end
