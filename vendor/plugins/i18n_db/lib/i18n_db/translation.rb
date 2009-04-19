class Translation < ActiveRecord::Base
  belongs_to :locale
  belongs_to :translator, :class_name => 'User', :foreign_key => 'translator_id'
  belongs_to :beta, :class_name => 'User', :foreign_key => 'beta_id'
  validates_presence_of :namespace
  validates_presence_of :tr_key
  
  def validate
    unless locale.main?
      main_tr = counterpart_in_main
      if main_tr && main_tr.text && self.text
        if main_tr.count_macros != count_macros
          errors.add("text", "did not preserve macro variables, e.g. {{to_be_kept}}. Please do not change or translate the macros.")
        end
        if main_tr.count_link_targets != count_link_targets
          errors.add("text", "did not preserve html links, e.g. <a href=\"to_be_kept\">...</a>. Please do not change or translate the URLs.")
        end
      end
    end
  end
  
  def count_macros
    macros = {}
    self.text.scan /\{\{(.*?)\}\}/ do |matches|
      key = matches.first
      macros[key] ||= 0
      macros[key] += 1
    end
    macros
  end
  
  def count_link_targets
    link_targets = {}
    self.text.scan /href=(.*?)>/ do |matches|
      key = matches.first
      link_targets[key] ||= 0
      link_targets[key] += 1
    end
    link_targets
  end


  def counterpart_in(locale)
    locale.translations.find_or_create_by_namespace_and_tr_key(:namespace => namespace, :tr_key => tr_key)
  end
  
  def counterpart_in_main
    Locale.find_main_cached.translations.find(:first, :conditions => { :namespace => namespace, :tr_key => tr_key })
  end

  def self.pick(key, locale, namespace = nil)
    conditions = 'tr_key = ? AND locale_id = ?'
    namespace_condition = namespace ? ' AND namespace = ?' : ' AND namespace IS NULL'
    conditions << namespace_condition
    find(:first, :conditions => [conditions,*[key, locale.id, namespace].compact])
  end

  #Find all namespaces used in translations
  def self.find_all_namespaces
    sql = <<-SQL
SELECT distinct(namespace) FROM translations order by namespace
SQL
    self.connection.select_values(sql).compact
  end
  
  def self.simple_localization_to_sql(locale, path)
    hash = YAML.load_file(path)
    hash_to_sql(locale, hash["app"], "app")
  end
  
  def self.hash_to_sql(locale, hash, namespace)
    hash.each do |key, val|
      if Hash === val
        hash_to_sql(locale, val, "#{namespace}.#{key}")
      else
        locale.translations.create \
          :tr_key => key, 
          :namespace => namespace, 
          :text => simple_localization_escaping_to_rails(val)
      end
    end
  end
  
  def self.simple_localization_escaping_to_rails(str)
    str.gsub(/:(\w[\w\d_]*)/, '{{\\1}}')
  end 
  
  #### OTW CUSTOMIZATIONS ###
  
  # Rails expects an array of strings
  ARRAY_KEYS = ['date.day_names', 'date.abbr_day_names']								
  # Rails expects an array of strings that starts with nil								
  ARRAY_KEYS_WITH_NIL = ['date.month_names', 'date.abbr_month_names']
  # Rails expects an array of symbols								
  ARRAY_OF_SYMBOL_KEYS = ['date.order']
  # Rails expects a hash of format options
  FORMAT_HASHES = ['date.formats', 'time.formats']
  # Gets called during the localize method
  TIME_AM_PM = ['time.am', 'time.pm']
  # Group them together to make it easy to see if we need to convert the database string to an array
  SPECIAL_CASES = ARRAY_KEYS + ARRAY_KEYS_WITH_NIL + ARRAY_OF_SYMBOL_KEYS + FORMAT_HASHES + TIME_AM_PM
  
  LOCALIZE_DEFAULTS = {
    "date.formats" => {:default => "%Y-%m-%d", :short => "%b %d", :long => "%B %d, %Y"},
    "date.day_names" => ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    "date.abbr_day_names" => ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    "date.month_names" => [nil, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
    "date.abbr_month_names" => [nil, 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    "date.order" => [:year, :month, :day],
    "time.formats" => {:default => "%a, %d %b %Y %H:%M:%S %z", :short => "%d %b %H:%M", :long => "%B %d, %Y %H:%M"}, 
    "time.am" => "am",
    "time.pm" => "pm"
  }
  
  # Rails requires arrays and hashes of data to localize dates and times. Since we're using the database
  # to store our translations, we need to manipulate things a bit to make it work, and also add some fallbacks.
  def self.catch_special_cases(key, locale)
    special_case = LOCALIZE_DEFAULTS[key]
    if SPECIAL_CASES.include?(key)
      locale = Locale.find_by_iso(locale.to_s) || Locale.default
      if FORMAT_HASHES.include?(key) 
        if (translations = locale.translations.find_all_by_namespace(key)) && translations.length == LOCALIZE_DEFAULTS[key].length
          special_case = {}
          translations.each do |t|
            if t.text.blank?
              t.update_attribute(:text, LOCALIZE_DEFAULTS[key][t.tr_key.to_sym])
            end 
            special_case[t.tr_key.to_sym] = t.text
          end 
        end        
        return special_case
      else      
        keys = key.split('.')
        tr_key = keys.pop.to_s
        namespace = keys.join('.')      
        if translation = locale.translations.find_by_tr_key_and_namespace(tr_key, namespace)
          text = translation.text
          if text.blank?
            translation.update_attribute(:text, LOCALIZE_DEFAULTS[key].compact.join(', '))
            special_case = LOCALIZE_DEFAULTS[key]
          else
            special_case = case  
              when ARRAY_KEYS.include?(key)
                text.split(', ')
              when ARRAY_KEYS_WITH_NIL.include?(key)
                [nil] + text.split(', ')  
              when ARRAY_OF_SYMBOL_KEYS.include?(key)
                text.split(', ').collect {|new_key| new_key.to_sym }           
              else
                text            
            end
          end
        end
      end
    end
    special_case
  end

  # When a new key is added to the app, and a default value is given, this method
  # saves it to the database so it can be translated for other locales  
  def self.add_default_to_db(locale, key, default, scope=nil)
    if scope && scope.respond_to?(:join)
      namespace = scope.join('.')
      tr_key = key
    else
      keys = I18n.send(:normalize_translation_keys, locale, key, scope)
      keys.delete_at(0)
      unless keys.blank?
        tr_key = keys.pop.to_s
        namespace = keys.join('.')
      end
    end
    locale = Locale.find_main_cached
    if translation = locale.translations.find_by_tr_key_and_namespace(tr_key, namespace)
      translation.text = default
    else
      translation = locale.translations.build(:tr_key => tr_key, :namespace => namespace, :text => default)
    end
    translation.save    
  end
end
