begin
  ActiveRecord::Base.connection  # if we have no database fall through to rescue
  Locale.set_base_locale(:short => ArchiveConfig.DEFAULT_LOCALE_SHORT, :iso => ArchiveConfig.DEFAULT_LOCALE_ISO, :name => ArchiveConfig.DEFAULT_LOCALE_NAME)
rescue
  Locale.set_base_locale(:short => "en", :iso => "en-US", :name => "English")
end