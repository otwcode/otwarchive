module LanguageHelper
  def available_faq_locales
    ArchiveFaq.translated_locales.map { |code| Locale.find_by_iso(code) }
  end

  def rtl?
    %w(ar he).include?(Globalize.locale.to_s)
  end
end
