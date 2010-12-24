class YuletideSweeper < ActionController::Caching::Sweeper

  observe Collection, Work

  def after_update(record)
    @collection = Collection.find_by_name("yuletide2010")
    if record.is_a?(Work) && record.collections.include?(@collection)
      if record.restricted?
        expire_action :controller => 'yuletide2010',
                      :action => 'restricted_works'
        expire_action :controller => 'yuletide2010',
                      :action => 'restricted_work',
                      :id => record.id
      else
        expire_page :controller => 'yuletide2010',
                    :action => 'work',
                    :id => record.id
        fandoms = record.filters.by_type("Fandom")
        fandoms.each do |fandom|
          expire_page :controller => 'yuletide2010',
                      :action => 'show',
                      :id => fandom.to_param
        end
      end
    elsif record == @collection
      expire_page :controller => 'yuletide2010',
                  :action => 'index'
      expire_action :controller => 'yuletide2010',
                    :action => 'restricted_works'
      works = record.works.where(:restricted => true)
      works.each do |work|
        expire_action :controller => 'yuletide2010',
                      :action => 'restricted_work',
                      :id => work.id
      end
      cache_dir = RAILS_ROOT + "/public/yuletide2010"
      FileUtils.rm_r(Dir.glob(cache_dir+"/*")) rescue Errno::ENOENT
      logger.info("Yuletide cache fully swept.")
    end
  end

end
