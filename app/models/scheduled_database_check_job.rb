class ScheduledDatabaseCheckJob
  def self.perform(job_type)
    case job_type
    when "clean_subscription_series"
      Subscription.where(subscribable_type: "Series").joins("left join series on series.id = subscriptions.subscribable_id").where("series.id is NULL").find_each do |s|
        s.delete if s.name.nil? && (Series.find_by id: s.subscribable_id).nil?
      end
    when "clean_subscription_user"
      Subscription.where(subscribable_type: "User").joins("left join users on users.id = subscriptions.subscribable_id").where("users.id is NULL").find_each do |s|
        s.delete if s.name.nil? && (User.find_by id: s.subscribable_id).nil?
      end
    when "clean_subscription_work"
      Subscription.where(subscribable_type: "Work").joins("left join works on works.id = subscriptions.subscribable_id").where("works.id is NULL").find_each do |s|
        s.delete if s.name.nil? && (Work.find_by id: s.subscribable_id).nil?
      end
    end
  end
end
