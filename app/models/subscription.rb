class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :subscribable, :polymorphic => true
  
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
  
end
