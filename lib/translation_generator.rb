class TranslationGenerator
  
  # Search through application files and generate a yml file for the default locale
  # based on the translation keys and default values in the code
  def generate_default_translation_file
    locale = I18n.default_locale.to_s
    location_to_write = File.dirname(__FILE__) + "/../config/locales/#{locale}.yml"
    yml = YAML::load(File.open(location_to_write))
    yml[locale] = {}
    
    files_to_scan.sort.inject(HashWithIndifferentAccess.new) do |files, file|
      default_keys = default_keys_from_location(file)
      translations = IO.read(file).scan(/\bt\((.+)\)/).flatten
      translations.each do |t|
        parsed = parse_translation(t, default_keys)
        keys = parsed.first
        default_value = parsed.last
        last_key = keys.pop
        parent = yml[locale]
        begin        
          keys.each do |key|          
            parent[key] ||= {}
            parent = parent[key]          
          end 

          parent[last_key] = default_value
        rescue
        end
      end
    end    
    File.open(location_to_write, 'w+') { |out| YAML::dump(yml, out) }
  end
  
  private
  
  # Takes the contents of translate method and the default keys
  # based on the file and returns appropriate keys and the associated
  # default text value
  def parse_translation(translation_content, default_keys)
    t = translation_content.split(',')
    key_text = t.shift
    remainder = t.join(',')    

    key_text = key_text.strip[1..-2]
    keys = key_text.split('.').reject {|k| k.blank?}
    unless (keys & default_keys) == default_keys
      keys = default_keys + keys
    end
        
    begin
      if remainder.blank?
        default_text = ""
      else
        text = remainder.split(/:default\s?=>\s?/).last
        quote = text.first
        if %w(' ").include?(quote)
          text.match(/#{quote}([^#{quote}]+)\\?#{quote}\)?/)
          default_text = $1 || ""
        else
          default_text = ""
        end
      end
    rescue
      default_text = ""
    end
    [keys, default_text]
  end
  
  # Default keys based on the location of the translation
  # ex. "/views/users/index.html.erb" -> ['users', 'index']
  def default_keys_from_location(location)
    location = location.split("/app/").last
    dirs = location.split("/")
    filename = dirs.pop.split('.').first
    dirs.shift
    keys = dirs + [filename]
  end

  def files_to_scan
    root_dir = File.dirname(__FILE__) + '/..'
    Dir.glob(File.join(root_dir, "{app}", "**","*.{rb,erb,rhtml}"))
  end
  
end