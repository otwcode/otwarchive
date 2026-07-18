class MediaController < ApplicationController
  before_action :load_collection

  def index
    uncategorized = Media.uncategorized
    @media = Media.canonical.by_name.where.not(name: [ArchiveConfig.MEDIA_UNCATEGORIZED_NAME, ArchiveConfig.MEDIA_NO_TAG_NAME]) + [uncategorized]
    @fandom_listing = {}
    @media.each do |medium|
      if medium == uncategorized
        @fandom_listing[medium] = medium.children.in_use.by_type('Fandom').order('created_at DESC').limit(5)
      else
        @fandom_listing[medium] = (logged_in? || logged_in_as_admin?) ?
          # was losing the select trying to do this through the parents association
          Fandom.unhidden_top(5).joins(:common_taggings).where(canonical: true, common_taggings: {filterable_id: medium.id, filterable_type: 'Tag'}) :
          Fandom.public_top(5).joins(:common_taggings).where(canonical: true, common_taggings: {filterable_id: medium.id, filterable_type: 'Tag'})
      end
    end
    @page_subtitle = t(".browser_title")
  end

  def show
    redirect_to media_fandoms_path(media_id: params[:id])
  end
end
