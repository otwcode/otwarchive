class Question < ActiveRecord::Base
  belongs_to :archive_faq
  attr_protected :content_sanitizer_version
  attr_protected :screencast_sanitizer_version
end
