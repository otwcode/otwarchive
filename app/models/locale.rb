class Locale < ActiveRecord::Base
  belongs_to :language
  # has_many :translations
  # has_many :translation_notes
  validates_presence_of :iso
  validates_uniqueness_of :iso
  validates_presence_of :name

  scope :default_order, order(:iso)

  def to_param
    iso
  end

  def self.default
    language = Language.default
    Locale.set_base_locale(:iso => ArchiveConfig.DEFAULT_LOCALE_ISO, :name => ArchiveConfig.DEFAULT_LOCALE_NAME, :language_id => language.id)
  end

  def self.set_base_locale(locale={:iso => "en", :name => "English"})
    language = Language.find_by_short(ArchiveConfig.DEFAULT_LANGUAGE_SHORT)
    Locale.find_by_iso(locale[:iso].to_s) || language.locales.create(:iso => locale[:iso].to_s, :name => locale[:name].to_s, :main => 1)
  end

end
