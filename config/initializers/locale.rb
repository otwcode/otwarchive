begin
  ActiveRecord::Base.connection  # if we have no database fall through to rescue
  # try to set Locale using Archive Config
  Locale.set_base_locale(:short => ArchiveConfig.DEFAULT_LOCALE_SHORT, :iso => ArchiveConfig.DEFAULT_LOCALE_ISO, :name => ArchiveConfig.DEFAULT_LOCALE_NAME)
rescue
  # that didn't work, try using hard coded information
  begin
    Locale.set_base_locale(:short => "en", :iso => "en-US", :name => "English")
  rescue
    # that didn't work, give up
    puts "locale not set"
  end
end
