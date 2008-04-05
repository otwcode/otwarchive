module Globalize 
  class RFC_3066 # :nodoc:
    attr_accessor :country, :language, :locale
    def self.parse(locale)
      # check for validity
      raise ArgumentError, "bad format for #{locale}, not rfc-3066 compliant" if
        locale !~ /^[a-zA-Z0-9\-]+$/  

      # split/assign
      lang, country, remain = locale.split('-', 3)
      raise ArgumentError, "bad format for #{locale}, not rfc-3066 compliant" if
        lang !~ /^[a-zA-Z]{1,8}$/
      new_language = lang if lang.size == 2 || lang.size == 3
      raise ArgumentError, "bad format for #{locale}, not rfc-3066 compliant" if
        !new_language && lang != 'i' && lang != 'x'
      
      raise ArgumentError, "bad format for #{locale}, not rfc-3066 compliant" if
        country && (country.size < 2 || country.size > 8)
      new_country = country if country && country.size == 2

      rfc = self.new
      rfc.country = new_country
      rfc.language = new_language
      rfc.locale = locale

      return rfc
    end

    def self.valid?(locale)
      begin
        parse(locale)
      rescue ArgumentError
        return false
      else
        return true
      end
    end

  end
end
