class Locale < ActiveRecord::Base
  has_many :translations
  validates_presence_of :iso
  validates_presence_of :short
  
  # Returns a floating point number between 0.0 and 1.0, reflecting the fraction of the translations that
  # are up to date in this locale (i.e. that exist and are not older than the corresponding string for 
  # the main locale 
  def completeness
    return 1.0 if main?
    
    main_translations_count = Locale.find_main_cached.translations.count
    main_translations = Locale.find_main_translations
    local_translations = translations.inject({}) { |memo, tr| memo["#{tr.namespace}/#{tr.tr_key}"] = tr; memo }
    
    outdated = 0
    main_translations.each do |key, main_tr|
      if !local_translations[key] || (local_translations[key].updated_at && main_tr.updated_at && local_translations[key].updated_at < main_tr.updated_at)
        outdated += 1
      end
    end
    (main_translations_count - outdated).to_f / main_translations_count
  end
  
  def self.find_main_cached
    @@find_main_cached ||= find_by_main(1)
  end
  
  # Ensure that there's at least one language in the database
  def self.set_base_locale(locale={:short => "en", :iso => "en-US", :name => "English"})
    find_main_cached || Locale.find_by_short_and_iso(locale[:short].to_s, locale[:iso].to_s) || Locale.create(:short => locale[:short].to_s, :iso => locale[:iso].to_s, :name => locale[:name].to_s, :main => 1)
  end
        
  # Sets up a hash with keys like "app.pages.membership/n_months_free" and values being
  # translation activerecord objects
  def self.find_main_translations
    find_main_cached.translations.inject({}) { |memo, tr| memo["#{tr.namespace}/#{tr.tr_key}"] = tr; memo }
  end
end