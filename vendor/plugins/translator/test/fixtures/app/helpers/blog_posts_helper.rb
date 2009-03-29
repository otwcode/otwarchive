# Helper
module BlogPostsHelper
  
  # Get the list of archives
  def get_archives
    # Will be scoped to controller.action ("blog_posts.archives")
    t('title')
  end
  
end