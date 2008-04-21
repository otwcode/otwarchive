# Include Globalize!
include Globalize 
Locale.set_base_language('en-US') 

SUPPORTED_LANGUAGES = { :english => 'en-US', :italian => 'it-IT', :french => 'fr-FR', 
    :german => 'de-DE', :japanese => 'ja-JP', :spanish => 'es-ES', :czech => 'cs-CZ', 
    :chinese => 'zh-CHS', :russian => 'ru-RU', :portuguese => 'pt-BR', :dutch => 'nl-NL', 
    :indonesian => 'id-ID', :finnish => 'fi-FI'
}

LANGUAGE_NAMES = {}
# load the native language names into the constant
SUPPORTED_LANGUAGES.each do |lang, locale|
  LANGUAGE_NAMES.merge!({locale => (langobj = Language.pick(locale)).nil? ? lang.to_s : langobj.native_name })
end
 
