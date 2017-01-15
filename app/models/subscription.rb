class Subscription < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

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
    chapter_text = creation.is_a?(Chapter) ? "#{creation.chapter_header} of " : ""
    work_title = creation.is_a?(Chapter) ? creation.work.title : creation.title
    text = "#{authors} posted #{chapter_text}#{work_title}"
    text += subscribable_type == "Series" ? " in the #{self.name} series" : ""
  end
    
end
