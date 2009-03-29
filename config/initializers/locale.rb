begin
  ActiveRecord::Base.connection  # if we have no database fall through to rescue
  # try to set language and locale using Archive Config
  language = Language.default
  Locale.set_base_locale(:iso => ArchiveConfig.DEFAULT_LOCALE_ISO, :name => ArchiveConfig.DEFAULT_LOCALE_NAME, :language_id => language.id)
rescue
  # that didn't work, try using hard coded information
  begin
    language = Language.find_or_create_by_short_and_name(:short => 'en', :name => 'English')
    Locale.set_base_locale(:iso => "en-US", :name => "English (US)", :language_id => language.id)
  rescue
    # that didn't work, give up
    puts "language/locale not set"
  end
end
