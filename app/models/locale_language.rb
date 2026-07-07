class LocaleLanguage < ApplicationRecord
  validates :short, presence: true, uniqueness: true, length: { maximum: 4 }
  validates :name, presence: true, uniqueness: true

  has_many :locales, foreign_key: :language_id, inverse_of: :locale_language, dependent: :restrict_with_exception
  has_many :admin_posts, foreign_key: :language_id, inverse_of: :locale_language, dependent: :restrict_with_exception
  has_many :admin_post_tags, foreign_key: :language_id, inverse_of: :locale_language, dependent: :restrict_with_exception

  scope :default_order, -> { order(Arel.sql("COALESCE(NULLIF(sortable_name,''), short)")) }

  def to_param
    short
  end

  def self.default
    find_or_create_by(short: ArchiveConfig.DEFAULT_LANGUAGE_SHORT, name: ArchiveConfig.DEFAULT_LANGUAGE_NAME)
  end
end
