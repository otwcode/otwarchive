class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :subscribable, :polymorphic => true
  
  validates_presence_of :user, :subscribable_id, :subscribable_type
  
  # Get the subscriptions associated with this work
  # currently: users subscribed to work, users subscribed to creator of work
  scope :for_work, lambda {|work|
    where(["(subscribable_id = ? AND subscribable_type = 'Work') 
            OR (subscribable_id IN (?) AND subscribable_type = 'User')
            OR (subscribable_id IN (?) AND subscribable_type = 'Series')",
            work.id, 
            work.pseuds.value_of(:user_id),
            work.series.value_of(:id)]).
    group(:user_id)
  }
  
  scope :for_work_directly, lambda { |work| 
    where(subscribable_id: work.id, subscribable_type: 'Work')
  }
  
  # The name of the object to which the user is subscribed
  def name
    if subscribable.respond_to?(:login)
      subscribable.login
    elsif subscribable.respond_to?(:name)
      subscribable.name
    elsif subscribable.respond_to?(:title)
      subscribable.title
    end
  end
  
  def subject_text(creation)
    authors = creation.pseuds.map{ |p| p.byline }.to_sentence
    "#{authors} posted #{creation_name(creation)}"
  end

  def creation_name(creation)
    if creation.is_a?(Chapter)
      "#{chapter_name(creation)} of #{creation.work.title}"
    elsif subscribable_type == 'User'
      creation.title
    elsif subscribable_type == 'Series'
      "#{creation.title} in #{self.name} series"
    end      
  end

  def chapter_name(creation)
    title = creation.chapter_title
    title.match(/^Chapter /) ? title : "Chapter #{title}"
  end
    
end
