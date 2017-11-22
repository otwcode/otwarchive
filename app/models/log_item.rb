class LogItem < ApplicationRecord

  belongs_to :user
  belongs_to :admin

  belongs_to :role

  validates_presence_of :note
  validates_presence_of :action

  validates_length_of :note, maximum: ArchiveConfig.LOGNOTE_MAX

end
