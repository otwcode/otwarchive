class TranslationNote < ActiveRecord::Base
  belongs_to :user
  belongs_to :locale


  attr_protected :note_sanitizer_version
  before_save :update_sanitizer_version
  def update_sanitizer_version
    note_sanitizer_version = ArchiveConfig.SANITIZER_VERSION
  end
end
