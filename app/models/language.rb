class Language < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  validates_presence_of :short
  validates_uniqueness_of :short
  validates_presence_of :name

  has_many :works
  has_many :locales
  has_many :admin_posts
  has_many :archive_faqs

  scope :default_order, order(:short)

  def to_param
    short
  end

  def self.default
    self.find_or_create_by_short_and_name(:short => ArchiveConfig.DEFAULT_LANGUAGE_SHORT, :name => ArchiveConfig.DEFAULT_LANGUAGE_NAME)
  end

  def work_count
    self.works.count(:conditions => {:posted => true})
  end

  def fandom_count
    Fandom.count(:joins => :works, :conditions => {:works => {:id => self.works.posted.collect(&:id)}}, :distinct => true, :select => 'tags.id')
  end

end
