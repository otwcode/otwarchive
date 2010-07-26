class Reading < ActiveRecord::Base
  belongs_to :user
  belongs_to :work
  
  # create a reading object, but only if the user has reading
  # history enabled and is not the author of the work
  # called from show in work controller
  def self.update_or_create(work, user)
    return unless work.is_a? Work
    return unless user.is_a? User
    if user.preference.try(:history_enabled)
      unless user.is_author_of?(work)
        reading = Reading.find_or_initialize_by_work_id_and_user_id(work.id, user.id)
        reading.major_version_read = work.major_version
        reading.minor_version_read = work.minor_version
        reading.view_count = reading.view_count + 1
        reading.save
      end
    end
    return reading
  end
end
