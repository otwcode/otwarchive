class LogItem < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :admin
  
  belongs_to :role
  
  validates_presence_of :note
  validates_presence_of :action
  
  validates_length_of :note, :maximum => ArchiveConfig.LOGNOTE_MAX
  
  attr_protected :note_sanitizer_version
  before_save :update_sanitizer_version
  def update_sanitizer_version
    note_sanitizer_version = ArchiveConfig.SANITIZER_VERSION
  end

  
end