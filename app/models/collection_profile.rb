class CollectionProfile < ActiveRecord::Base
  belongs_to :collection

  attr_protected :intro_sanitizer_version
  attr_protected :faq_sanitizer_version
  attr_protected :rules_sanitizer_version
  before_save :update_sanitizer_version
  def update_sanitizer_version
    intro_sanitizer_version = ArchiveConfig.SANITIZER_VERSION
    faq_sanitizer_version = ArchiveConfig.SANITIZER_VERSION
    rules_sanitizer_version = ArchiveConfig.SANITIZER_VERSION
  end
  
  validates_length_of :intro, 
    :allow_blank => true,
    :maximum => ArchiveConfig.INFO_MAX, :too_long => t('collection_profile.intro_too_long', :default => "must be less than %{max} letters long.", :max => ArchiveConfig.INFO_MAX)

  validates_length_of :faq, 
    :allow_blank => true,
    :maximum => ArchiveConfig.INFO_MAX, :too_long => t('collection_profile.faq_too_long', :default => "must be less than %{max} letters long.", :max => ArchiveConfig.INFO_MAX)

  validates_length_of :rules, 
    :allow_blank => true,
    :maximum => ArchiveConfig.INFO_MAX, :too_long => t('collection_profile.rules_too_long', :default => "must be less than %{max} letters long.", :max => ArchiveConfig.INFO_MAX)

  validates_length_of :gift_notification, 
    :allow_blank => true,
    :maximum => ArchiveConfig.SUMMARY_MAX, :too_long => t('collection_profile.gift_notification_too_long', :default => "must be less than %{max} letters long.", :max => ArchiveConfig.SUMMARY_MAX)

end
