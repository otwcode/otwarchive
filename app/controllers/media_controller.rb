class MediaController < ApplicationController
  before_filter :load_collection

  skip_after_filter :store_location, only: :show

  def index
    uncategorized = Media.uncategorized
    @media = Media.by_name - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME), uncategorized] + [uncategorized]
    @fandom_listing = {}
    @media.each do |medium|
      if medium == uncategorized
        @fandom_listing[medium] = medium.children.in_use.by_type('Fandom').find(:all, :order => 'created_at DESC', :limit => 5)
      else
        definitions = {
          joins: :common_taggings,
          conditions: {
            canonical: true,
            common_taggings: {
              filterable_id: medium.id, filterable_type: 'Tag'
            }
          }
        }

        @fandom_listing[medium] = if user_signed_in? || admin_signed_in?
                                    # was losing the select trying to do this through the parents association
                                    Fandom.unhidden_top(5).find(:all, definitions)
                                  else
                                    Fandom.public_top(5).find(:all, definitions)
                                  end
      end
    end
    @page_subtitle = ts("Fandoms")
  end

  def show
    redirect_to medium_fandoms_path(:medium_id => params[:id])
  end
end
