class YuletideSweeper < ActionController::Caching::Sweeper

  observe Collection, Work

  def after_save(record)
    @collection = Collection.find_by_name("yuletide2010")
    if record.is_a?(Work) && record.collections.include?(@collection)
      if record.restricted?
        expire_action :controller => 'yuletide2010',
                      :action => 'restricted_work',
                      :id => record.id
      else
        expire_page :controller => 'yuletide2010',
                    :action => 'work',
                    :id => record.id
      end
    elsif record == @collection
      expire_page :controller => 'yuletide2010',
                  :action => 'index'
      cache_dir = RAILS_ROOT + "/public/yuletide2010"
      FileUtils.rm_r(Dir.glob(cache_dir+"/*")) rescue Errno::ENOENT
      logger.info("Yuletide cache fully swept.")
    end
  end

end
