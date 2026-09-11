class Locale < ApplicationRecord
  belongs_to :locale_language, foreign_key: :language_id, inverse_of: :locales
  validates_presence_of :iso
  validates :iso, uniqueness: true
  validates_presence_of :name
  validate :interface_enabled_only_if_email_enabled

  scope :default_order, -> { order(:iso) }

  def interface_enabled_only_if_email_enabled
    errors.add(:interface_enabled, :only_if_email_enabled) if interface_enabled && !email_enabled
  end

  def to_param
    iso
  end

  def self.default
    locale_language = LocaleLanguage.default
    Locale.set_base_locale(iso: ArchiveConfig.DEFAULT_LOCALE_ISO, name: ArchiveConfig.DEFAULT_LOCALE_NAME, language_id: locale_language.id)
  end

  def self.set_base_locale(locale={iso: "en", name: "English"})
    locale_language = LocaleLanguage.find_by(short: ArchiveConfig.DEFAULT_LANGUAGE_SHORT)
    Locale.find_by(iso: locale[:iso].to_s) || locale_language.locales.create(iso: locale[:iso].to_s, name: locale[:name].to_s, main: 1)
  end

  after_update :update_translations, if: :saved_change_to_iso?
  def update_translations
    ArchiveFaq::Translation.where(locale: iso_before_last_save).update_all(locale: iso)
    Question::Translation.where(locale: iso_before_last_save).update_all(locale: iso)
  end
end
