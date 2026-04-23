class CollectionProfile < ApplicationRecord
  belongs_to :collection

  after_commit :expire_profile_fragment_caches, on: %i[create update destroy]

  def expire_profile_fragment_caches
    return unless collection

    Collection.expire_profile_caches_for_hierarchy(collection)
  end

  validates_length_of :intro, 
    allow_blank: true,
    maximum: ArchiveConfig.INFO_MAX, too_long: ts("must be less than %{max} letters long.", max: ArchiveConfig.INFO_MAX)

  validates_length_of :faq,
    allow_blank: true,
    maximum: ArchiveConfig.INFO_MAX, too_long: ts("must be less than %{max} letters long.", max: ArchiveConfig.INFO_MAX)

  validates_length_of :rules,
    allow_blank: true,
    maximum: ArchiveConfig.INFO_MAX, too_long: ts("must be less than %{max} letters long.", max: ArchiveConfig.INFO_MAX)

  validates_length_of :assignment_notification,
    allow_blank: true,
    maximum: ArchiveConfig.SUMMARY_MAX, too_long: ts("must be less than %{max} letters long.", max: ArchiveConfig.SUMMARY_MAX)

  validates_length_of :gift_notification,
    allow_blank: true,
    maximum: ArchiveConfig.SUMMARY_MAX, too_long: ts("must be less than %{max} letters long.", max: ArchiveConfig.SUMMARY_MAX)
end
