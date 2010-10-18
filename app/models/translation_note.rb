class TranslationNote < ActiveRecord::Base
  belongs_to :user
  belongs_to :locale


  attr_protected :note_sanitizer_version
end
