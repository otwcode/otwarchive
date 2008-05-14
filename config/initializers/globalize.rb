# Include Globalize!
include Globalize
begin
  ActiveRecord::Base.connection  # if we have no database fall through to rescue
  Locale.set_base_language(ArchiveConfig.BASE_LANGUAGE)
  LANGUAGE_NAMES = Hash.new
  ArchiveConfig.SUPPORTED_LOCALES.each do |lang, locale|
    LANGUAGE_NAMES.merge!({lang => (langobj = Language.pick(locale)).nil? ? lang.to_s : langobj.native_name })
  end
rescue
  Locale.set_base_language("en-US")
  LANGUAGE_NAMES = { "en"=>"English" }
end
