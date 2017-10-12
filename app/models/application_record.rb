class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.per_page = ArchiveConfig.ITEMS_PER_PAGE

  # ES UPGRADE TRANSITION #
  # Remove method
  def self.use_new_search?
    $rollout.active?(:use_new_search) ||
      User.current_user.present? && $rollout.active?(:use_new_search, User.current_user) ||
      true
  end

  before_save :update_sanitizer_version

  def update_sanitizer_version
    ArchiveConfig.FIELDS_ALLOWING_HTML.each do |field|
      if self.will_save_change_to_attribute?(field)
        self.send("#{field}_sanitizer_version=", ArchiveConfig.SANITIZER_VERSION)
      end
    end
  end
end
