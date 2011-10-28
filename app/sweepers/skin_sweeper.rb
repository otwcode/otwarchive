class SkinSweeper < ActionController::Caching::Sweeper
  observe Skin, WorkSkin
  
  def after_save(record)
    expire_skin_cache_for(record)
  end

  def after_destroy(record)
    expire_skin_cache_for(record)
  end
  
  private
  def expire_skin_cache_for(record)
    if record.is_a?(WorkSkin)
      expire_fragment("#{record.id}-work-skin")
    elsif record.is_a?(Skin)
      expire_fragment("#{record.id}-default-site-skin")
      expire_fragment("#{record.id}-defaulttranslator-site-skin")
      expire_fragment("#{record.id}-defaultadmin-site-skin")
      expire_fragment("#{record.id}-defaulttranslatoradmin-site-skin")
    end      
  end

end