class StaticSweeper < ActionController::Caching::Sweeper

  observe Collection, Work

  def after_update(record)
    if record.is_a?(Work) && !record.collections.blank?
      fandoms = record.filters.by_type("Fandom")
      for collection in record.collections
        expire_page :controller => 'static/works',
                    :action => 'show',
                    :id => record.id,
                    :collection_id => collection.to_param
        fandoms.each do |fandom|
          expire_page :controller => 'static/fandoms',
                      :action => 'show',
                      :id => fandom.to_param,
                      :collection_id => collection.to_param
        end
      end
    elsif record.is_a?(Collection)
      expire_page :controller => 'static/collections',
                  :action => 'show',
                  :id => record.to_param
      cache_dir = Rails.root.to_s + "/public/static/collections/" + record.name
      FileUtils.rm_r(Dir.glob(cache_dir+"/*")) rescue Errno::ENOENT
      logger.info("#{record.name} static cache fully swept.")
    end
  end

end
