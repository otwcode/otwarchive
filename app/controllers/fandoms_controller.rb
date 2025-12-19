class FandomsController < ApplicationController
  before_action :load_collection

  def index
    if @collection
      @media = Media.canonical.by_name.where.not(name: [ArchiveConfig.MEDIA_UNCATEGORIZED_NAME, ArchiveConfig.MEDIA_NO_TAG_NAME]) + [Media.uncategorized]
      @page_subtitle = t(".collection_page_title", collection_title: @collection.title)
      @medium = Media.find_by_name(params[:media_id]) if params[:media_id]
      @counts = SearchCounts.fandom_ids_for_collection(@collection)
      @fandoms = (@medium ? @medium.fandoms : Fandom.all).where(id: @counts.keys).by_name
    elsif params[:media_id]
      @medium = Media.find_by_name!(params[:media_id])
      @page_subtitle = @medium.name
      @fandoms = if @medium == Media.uncategorized
                   @medium.fandoms.in_use.by_name
                 else
                   @medium.fandoms.canonical.by_name.with_count
                 end
    else
      flash[:notice] = t(".choose_media")
      redirect_to media_index_path and return
    end
    @fandoms_by_letter = @fandoms.group_by { |f| f.sortable_name[0].upcase }
  end

  def show
    @fandom = Fandom.find_by_name(params[:id])
    if @fandom.nil?
      flash[:error] = ts("Could not find fandom named %{fandom_name}", fandom_name: params[:id])
      redirect_to media_index_path and return
    end
    @characters = @fandom.characters.canonical.by_name
  end

  def unassigned
    @fandoms = Fandom.joins("LEFT JOIN wrangling_assignments ON (wrangling_assignments.fandom_id = tags.id)
                 LEFT JOIN users ON (users.id = wrangling_assignments.user_id)").where(canonical: true, users: { id: nil })

    if params[:media_id].present?
      @media = Media.find_by_name(params[:media_id])
      @fandoms = @fandoms.joins(:common_taggings).where(common_taggings: { filterable: @media }) if @media
    end

    order = params[:sort] == "count" ? "count DESC" : "sortable_name ASC"
    @fandoms = @fandoms.order(order).with_count.paginate(page: params[:page], per_page: 250)
  end
end
