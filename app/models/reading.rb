class Reading < ActiveRecord::Base
  belongs_to :user
  belongs_to :work

  # called from show in work controller
  def self.update_or_create(work, user)
    reading_json = [user.id, Time.now, work.id, work.major_version, work.minor_version, false].to_json
    $redis.sadd("Reading:new", reading_json)
  end

  # called from reading controller
  def self.mark_to_read_later(work, user)
    reading_json = [user.id, Time.now, work.id, work.major_version, work.minor_version, true].to_json
    $redis.sadd("Reading:new", reading_json)
  end

  # called from rake
  def self.update_or_create_in_database
    $redis.smembers("Reading:new").reverse.each do |reading_json|
      Reading.reading_object(reading_json)
    end
  end

  # create a reading object, but only if the user has reading
  # history enabled and is not the author of the work
  def self.reading_object(reading_json)
    user_id, time, work_id, major_version, minor_version, later = ActiveSupport::JSON.decode(reading_json)
    work = Work.find_by_id(work_id)
    user = User.find_by_id(user_id)
    return unless work.is_a? Work
    return unless user.is_a? User
    if user.preference.try(:history_enabled)
      unless user.is_author_of?(work)
        reading = Reading.find_or_initialize_by_work_id_and_user_id(work.id, user.id)
        reading.major_version_read = major_version
        reading.minor_version_read = minor_version
        reading.view_count = reading.view_count + 1 unless later
        reading.last_viewed = time
        # toggle between to read and marking read
        if later
          if reading.toread
          # it had been marked to read, and is now being marked read
            reading.toread = false
          else
            reading.toread = true
          end
        end
        reading.save
      end
    end
    $redis.srem("Reading:new", reading_json)
    return reading
  end
end
