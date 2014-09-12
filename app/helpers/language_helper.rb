module LanguageHelper
  def available_translations
    translations = ArchiveFaq.translated_locales
    translations.map! { |f| Language.find_by_short(f) }
    return translations
  end

  def rtl?
    if Globalize.locale.to_s == "ar" || Globalize.locale.to_s == "he"
      return true
    else
      return false
    end
  end
end
