class Language < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  validates_presence_of :short
  validates_uniqueness_of :short
  validates_presence_of :name

  has_many :works
  has_many :locales
  has_many :admin_posts
  has_many :archive_faqs

  scope :default_order, -> { order("COALESCE(NULLIF(sortable_name,''), short)") }

  def to_param
    short
  end

  def self.default
    self.find_or_create_by(short: ArchiveConfig.DEFAULT_LANGUAGE_SHORT, name: ArchiveConfig.DEFAULT_LANGUAGE_NAME)
  end

  def work_count
    self.works.where(posted: true).count
  end

  def fandom_count
    Fandom.joins(:works).where(works: {id: self.works.posted.collect(&:id)}).distinct.select('tags.id').count
  end

end
