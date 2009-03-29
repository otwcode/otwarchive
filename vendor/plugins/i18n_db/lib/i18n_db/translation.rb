class Translation < ActiveRecord::Base
  belongs_to :locale
  belongs_to :translator, :class_name => 'User', :foreign_key => 'translator_id'
  belongs_to :beta, :class_name => 'User', :foreign_key => 'beta_id'
  
  def validate
    unless locale.main?
      main_tr = counterpart_in_main
      if main_tr && main_tr.text
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
    locale.translations.find(:first, :conditions => { :namespace => namespace, :tr_key => tr_key }) || locale.translations.build(:namespace => namespace, :tr_key => tr_key)
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
