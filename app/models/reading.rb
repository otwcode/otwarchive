class Reading < ActiveRecord::Base
  belongs_to :user
  belongs_to :work

  after_save :expire_cached_home_marked_for_later, if: :toread?
  after_destroy :expire_cached_home_marked_for_later, if: :toread?

  # called from show in work controller
  def self.update_or_create(work, user)
    if user && user.preference.try(:history_enabled) && !user.is_author_of?(work)
      reading_json = [user.id, Time.now, work.id, work.major_version, work.minor_version, false].to_json
      REDIS_GENERAL.sadd("Reading:new", reading_json)
    end
  end

  # called from reading controller
  def self.mark_to_read_later(work, user)
    reading_json = [user.id, Time.now, work.id, work.major_version, work.minor_version, true].to_json
    REDIS_GENERAL.sadd("Reading:new", reading_json)
  end

  # called from rake
  def self.update_or_create_in_database
    REDIS_GENERAL.smembers("Reading:new").reverse.each do |reading_json|
      Reading.reading_object(reading_json)
    end
  end

  # create a reading object, but only if the user has reading
  # history enabled and is not the author of the work
  def self.reading_object(reading_json)
    user_id, time, work_id, major_version, minor_version, later = ActiveSupport::JSON.decode(reading_json)
    reading = Reading.find_or_initialize_by_work_id_and_user_id(work_id, user_id)
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
    REDIS_GENERAL.srem("Reading:new", reading_json)
    return reading
  end

  private

  def expire_cached_home_marked_for_later
    unless Rails.env.development?
      Rails.cache.delete("home/index/#{User.current_user.id}/home_marked_for_later")
    end
  end
end
