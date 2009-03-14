begin
  ActiveRecord::Base.connection  # if we have no database fall through to rescue
  begin
    Locale.set_base_locale(ArchiveConfig.BASE_LANGUAGE)
  rescue
     puts "Run rake db:migrate to set up the locale table!"
  end
rescue
  Locale.set_base_locale(:short => "en", :iso => "en-US", :name => "English")
end