module I18n
  module Backend
    class Simple
      # This one is needed because translate normally discards the default value from 
      # the information passed to MissingTranslationData handler, preventing it 
      # from trying a fallback locale correctly
      def translate(locale, key, options = {})
        raise InvalidLocale.new(locale) if locale.nil?
        return key.map { |k| translate(locale, k, options) } if key.is_a? Array
        
        if options[:default]
          options[:saved_default] = options[:default]
        end

        reserved = :scope, :default
        count, scope, default = options.values_at(:count, *reserved)
        options.delete(:default)
        values = options.reject { |name, value| reserved.include?(name) }

        entry = lookup(locale, key, scope)
        if entry.nil?
          entry = default(locale, default, options)
          if entry.nil?
            raise(I18n::MissingTranslationData.new(locale, key, options))
          else
            #Translation.add_default_to_db(locale, key, options) if Locale.find_main_cached.short == locale.to_s && options[:saved_default]
          end
        else
          if Locale.find_main_cached.short == locale.to_s && options[:saved_default] && entry != options[:saved_default]
            if false
            entry = options[:saved_default]
            #if key.is_a?(String)
              n = key.split('.')
              tr_key = n.last
              namespace = (n - [n.last]).join('.')
              translation = Locale.find_main_cached.translations.find(:first, :conditions => {:tr_key => tr_key, :namespace => namespace})
              translation.text = options[:saved_default]
              translation.updated = true
              translation.save
            end
          end
        end
        entry = pluralize(locale, entry, count)
        entry = interpolate(locale, entry, values)
        entry
      end
    end
  end
end