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
    work = nil
    if response.respond_to?(:ultimate_parent)
      work = response.ultimate_parent
    elsif response.respond_to?(:commentable)
      work = response.commentable
    elsif response.respond_to?(:bookmarkable)
      work = response.bookmarkable
    end
    work.is_a?(Work) ? work : nil
  end
  
end