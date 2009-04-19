module I18nDB
  module Backend
    class DBBased < I18n::Backend::Simple
      # This one is needed because translate normally discards the default value from 
      # the information passed to MissingTranslationData handler, preventing it 
      # from trying a fallback locale correctly
      def translate(locale, key, options = {})
        raise InvalidLocale.new(locale) if locale.nil?
        
        if entry = Translation.catch_special_cases(key.to_s, locale)
          return entry
        end
        
        return key.map { |k| translate(locale, k, options) } if key.is_a? Array
        
        if options[:default]
          saved_default = options[:default]
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
          elsif Locale.find_main_cached.iso == locale.to_s && saved_default 
            Translation.add_default_to_db(locale, key, saved_default, options[:scope]) 
          end
        end
        entry = pluralize(locale, entry, count)
        entry = interpolate(locale, entry, values)
        entry
      end  
    end
  end
end