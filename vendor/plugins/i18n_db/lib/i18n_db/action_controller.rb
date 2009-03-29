module I18nDb
  module ActionController
  
    private
    
    def reload_translations_for_locale(locale, updated_at)
      translations = Rails.cache.fetch("locales/#{locale}/#{updated_at.to_i}") do
        logger.warn "Loading translations for locale #{locale}"
        I18n.translations_from_db(locale)
      end
      
      I18n.backend.instance_eval do
        # wipe the existing app-level translations from memory, because 
        # otherwise stale items could remain after the merge
        if @translations && @translations[locale.to_sym] && @translations[locale.to_sym][:app]
          @translations[locale.to_sym][:app] = {} 
        end
      end
      
      I18n.backend.store_translations(I18n.locale, translations)
      nil
    end
    
    # There are 3 storages for translations, in order of decreasing speed:
    # * Per-process class variable
    # * Memcached
    # * ActiveRecord
    # Upon each request, timestamps of the class variable locales are verified (by the means of a tiny 
    # and fast memcached lookup).
    def ensure_translations_updated(locale)
      loc_obj = nil
      
      updated_at = Rails.cache.fetch("locale_versions/#{locale}") do
        loc_obj = Locale.find_by_iso(locale)
        timestamp = loc_obj.updated_at if loc_obj
        timestamp ||= 0
      end
      
      return false unless updated_at || loc_obj
      
      cached_versions = I18n.backend.instance_eval { @locale_versions }
      translations = I18n.backend.instance_eval { @translations }
      unless cached_versions 
        cached_versions = {}
      end
      unless cached_versions[locale] && cached_versions[locale] == updated_at && translations && translations[locale]
        reload_translations_for_locale(locale, updated_at)
        cached_versions[locale] = updated_at
      end
      I18n.backend.instance_eval { @locale_versions = cached_versions }
    end

    def set_locale(locale=:en)
      I18n.locale = locale
      
      ensure_translations_updated(locale.to_s)
                  
      #unless I18n::Backend::Simple.instance_methods.include? "translate_without_default_passed_to_exception"
      #  I18n::Backend::Simple.class_eval do
      #    alias_method_chain :translate, :default_passed_to_exception
      #  end
      #end
    end
  end
end