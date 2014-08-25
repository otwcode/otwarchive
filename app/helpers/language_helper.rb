module LanguageHelper
  def available_translations
    translations = ArchiveFaq.translated_locales
    translations.map! { |f| Language.find_by_short(f) }
    return translations
  end
end