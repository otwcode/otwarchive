RTL_LOCALES = %w[ar fa he].freeze

module LanguageHelper
  def available_faq_locales
    ArchiveFaq.translated_locales.map { |code| Locale.find_by(iso: code) }
  end

  def rtl?
    RTL_LOCALES.include?(Globalize.locale.to_s)
  end

  def rtl_language?(language)
    RTL_LOCALES.include?(language.short)
  end

  def english?
    params[:language_id] == "en"
  end

  def translated_questions(all_questions)
    questions = []
    all_questions.each do |question|
      question.translations.each do |translation|
        if translation.is_translated == "1" && params[:language_id].to_s == translation.locale.to_s
          questions << question
        end
      end
    end
    questions
  end

  def language_options_for_select(languages, value_attribute)
    languages.map { |language| [language.name, language[value_attribute], { lang: language.short }] }
  end

  def locale_options_for_select(locales, value_attribute)
    locales.map { |locale| [locale.name, locale[value_attribute], { lang: locale.language.short }] }
  end
end
