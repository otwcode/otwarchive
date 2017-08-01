class ApplicationRecord < ActiveRecord::Base

  before_save :udpate_sanitizer_version

  def update_sanitizer_version
    ArchiveConfig.FIELDS_ALLOWING_HTML.each do |field|
      if self.respond_to?("#{field}_changed?") && self.send("#{field}_changed?")
        self.send("#{field}_sanitizer_version=", ArchiveConfig.SANITIZER_VERSION)
      end
    end
  end

end
