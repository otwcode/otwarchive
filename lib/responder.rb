module Responder
  def self.included(responder)
    responder.class_eval do
      after_create :update_work_stats
      after_destroy :update_work_stats
    end
  end

  def update_work_stats
    work = get_work(self)
    return unless work.present?
    REDIS_GENERAL.sadd('works_to_update_stats', work.id)
  end

  def get_work
    work = nil
    if self.respond_to?(:ultimate_parent)
      work = self.ultimate_parent
    elsif self.respond_to?(:commentable)
      work = self.commentable
    elsif self.respond_to?(:bookmarkable)
      work = response.bookmarkable
    end

    work.is_a?(Work) ? work : nil
  end
end

