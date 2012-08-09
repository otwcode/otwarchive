class ResponseObserver < ActiveRecord::Observer
  observe Kudo, Comment, Bookmark
  
  def after_create(response)
    update_work_stats(response)
  end
  
  def after_destroy(response)
    update_work_stats(response)
  end
  
  def update_work_stats(response)
    work = get_work(response)
    return unless work.present?
    $redis.sadd('works_to_update_stats', work.id)
  end
  
  def get_work(response)
    if response.respond_to?(:parent)
      response.parent if response.is_a?(Work)
    elsif response.respond_to?(:commentable)
      response.commentable if response.is_a?(Work)
    elsif response.respond_to?(:bookmarkable)
      response.bookmarkable if response.is_a?(Work)
    end
  end
  
end