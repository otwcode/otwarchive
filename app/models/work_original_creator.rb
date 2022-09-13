class WorkOriginalCreator < ApplicationRecord
  belongs_to :work

  # Get the id and username (if still available) for the associated user.
  def display
    user = User.find_by(id: user_id)
    user ? "#{user_id} (#{user.login})" : user_id.to_s
  end

  # Remove any original creator records that have been around for longer
  # than the TTL in the archive configuration.
  def self.cleanup
    WorkOriginalCreator
      .delete_by("updated_at <= ?", ArchiveConfig.ORIGINAL_CREATOR_TTL_HOURS.hours.ago)
  end
end
