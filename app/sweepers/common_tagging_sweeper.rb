class CommonTaggingSweeper < ActionController::Caching::Sweeper
  observe CommonTagging
  
  # upon creation of a common_tagging, the filterable has gained a child, so expire its children cache
  def after_create(common_tagging)
    expire_fragment("views/tags/#{common_tagging.filterable_id}/children")
  end
  
  # upon destruction of a common_tagging, the filterable has lost a child, so expire its children cache
  def before_destroy(common_tagging)
    expire_fragment("views/tags/#{common_tagging.filterable_id}/children")
  end

end
