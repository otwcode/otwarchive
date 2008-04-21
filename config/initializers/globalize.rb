# Include Globalize!
include Globalize 
Locale.set_base_language('en-US') 

SUPPORTED_LOCALES = { 'en' => 'en-US', 'it' => 'it-IT', 'fr' => 'fr-FR', 
    'de' => 'de-DE', 'ja' => 'ja-JP', 'es' => 'es-ES', 'cs' => 'cs-CZ', 
    'zh' => 'zh-CHS', 'ru' => 'ru-RU', 'pt' => 'pt-BR', 'nl' => 'nl-NL', 
    'id' => 'id-ID', 'fi' => 'fi-FI'
}

LANGUAGE_NAMES = {}
# load the native language names into the constant
SUPPORTED_LOCALES.each do |lang, locale|
  LANGUAGE_NAMES.merge!({lang => (langobj = Language.pick(locale)).nil? ? lang.to_s : langobj.native_name })
end
 
