class LocaleLanguage < ApplicationRecord
  validates :short, presence: true
  validates :short, uniqueness: true
  validates :name, presence: true

  has_many :locales, dependent: :restrict_with_exception
  has_many :admin_posts, dependent: :restrict_with_exception
  has_many :archive_faqs, dependent: :restrict_with_exception

  scope :default_order, -> { order(Arel.sql("COALESCE(NULLIF(sortable_name,''), short)")) }

  def to_param
    short
  end

  def self.default
    self.find_or_create_by(short: ArchiveConfig.DEFAULT_LANGUAGE_SHORT, name: ArchiveConfig.DEFAULT_LANGUAGE_NAME)
  end
end
