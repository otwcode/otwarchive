class ScheduledDatabaseCheckJob
  def self.perform(job_type)
    case job_type
    when 'clean_subscription_series'
      Subscription.where(subscribable_type: "Series").includes(:subscribable).find_each do |s| 
        s.delete if s.name.nil? && Series.find_by_id(s.subscribable_id).nil?
      end
    when 'clean_subscription_user'
      Subscription.where(subscribable_type: "User").includes(:subscribable).find_each do |s|
        s.delete if s.name.nil? && User.find_by_id(s.subscribable_id).nil?
      end
    when 'clean_subscription_work'
      Subscription.where(subscribable_type: "Work").includes(:subscribable).find_each do |s|
        s.delete if s.name.nil? && Work.find_by_id(s.subscribable_id).nil?
      end
    end
  end
end
