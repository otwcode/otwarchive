class WorkDisplay
  
  attr_accessor :work, :current_user
  
  def initialize(work, chapter=nil)
    @work = work
    @chapter = chapter
    @current_user = User.current_user
  end
  
  def previous_chapter
    return if chapter.nil?
    work.chapters.posted.where("position < ?", chapter.position).order('position DESC').first
  end
  
  def next_chapter
    return if chapter.nil?
    work.chapters.posted.where("position > ?", chapter.position).order('position ASC').first
  end
  
  def bookmark
    return unless current_user.respond_to?(:pseuds)
    work.bookmarks.where(pseud_id: current_user.pseuds.map(&:id)).first
  end
  
  def kudos
    work.kudos.with_pseud.includes(:pseud => :user).order("created_at DESC")
  end
  
  def subscription
    if current_user && current_user.respond_to?(:subscriptions)
      current_user.subscriptions.for_work_directly(work).first || 
        current_user.subscriptions.build(subscribable: work)
    end
  end
  
  def saved_work
    return unless current_user.respond_to?(:saved_works)
    current_user.saved_works.find_or_initialize_by_work_id(work.id)
  end
  
end
  