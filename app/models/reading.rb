class Reading < ApplicationRecord
  belongs_to :user
  belongs_to :work

  after_save :expire_cached_home_marked_for_later, if: :saved_change_to_toread?
  after_destroy :expire_cached_home_marked_for_later, if: :toread?

  # called from show in work controller
  def self.update_or_create(work, user)
    if user && user.preference.try(:history_enabled) && !user.is_author_of?(work)
      reading_json = [user.id, Time.now, work.id, work.major_version, work.minor_version, false].to_json
      REDIS_GENERAL.sadd("Reading:new", reading_json)
    end
  end

  # called from reading controller
  def self.mark_to_read_later(work, user, toread)
    reading = Reading.find_or_initialize_by(work_id: work.id, user_id: user.id)
    reading.major_version_read = work.major_version
    reading.minor_version_read = work.minor_version
    reading.last_viewed = Time.now
    reading.toread = toread
    reading.save
  end

  # called from rake
  def self.update_or_create_in_database
    REDIS_GENERAL.smembers("Reading:new").reverse.each_slice(ArchiveConfig.READING_BATCHSIZE || 1000) do |batch|
      Reading.transaction do
        batch.each do |reading_json|
          Reading.reading_object(reading_json)
        end
      end
    end
  end

  # create a reading object, but only if the user has reading
  # history enabled and is not the author of the work
  def self.reading_object(reading_json)
    user_id, time, work_id, major_version, minor_version, later = ActiveSupport::JSON.decode(reading_json)
    reading = Reading.find_or_initialize_by(work_id: work_id, user_id: user_id)
    reading.major_version_read = major_version
    reading.minor_version_read = minor_version
    reading.view_count = reading.view_count + 1 unless later
    reading.last_viewed = time
    reading.save
    REDIS_GENERAL.srem("Reading:new", reading_json)
    return reading
  end

  private

  def expire_cached_home_marked_for_later
    unless Rails.env.development?
      Rails.cache.delete("home/index/#{user_id}/home_marked_for_later")
    end
  end
end
