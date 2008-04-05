module Globalize
  class Language < ActiveRecord::Base # :nodoc:
    set_table_name "globalize_languages"

    validates_presence_of :english_name

    validates_uniqueness_of :iso_639_1, :if => :iso_639_1
    validates_uniqueness_of :iso_639_2, :if => :iso_639_2
    validates_uniqueness_of :iso_639_3, :if => :iso_639_3
    validates_uniqueness_of :rfc_3066,  :if => :rfc_3066

    validates_length_of :pluralization, :maximum => 200, :if => :pluralization
    validates_format_of :pluralization, :with => /^[c=\d?:%!<>&|() ]+$/, :if => :pluralization,
      :message => " has invalid characters. Allowed characters are: " + 
        "'c', '=', 0-9, '?', ':', '%', '!', '<', '>', '&', '|', '(', ')', ' '."

    def self.reloadable?; false end

    def after_initialize
      if !pluralization.nil? && pluralization.size > 200
        raise SecurityError, "Pluralization field for #{self.english_name} language " +
          "contains potentially harmful code. " +
          "Must be less than 200 characters in length. Was #{pluralization.size} characters."
      end

      if !pluralization.nil? && pluralization !~ /^[c=\d?:%!<>&|() ]+$/
        raise SecurityError, "Pluralization field ('#{pluralization}') for #{self.english_name} language " +
          "contains potentially harmful code. " +
          "Must only use the characters: 'c', '=', 0-9, '?', ':', " +
          "'%', '!', '<', '>', '&', '|', '(', ')', ' '."
      end
    end

    def self.pick(rfc)
      if rfc.kind_of? String then rfc = RFC_3066.parse(rfc) end
      if rfc.locale.include? '-'
        lang = find_by_rfc_3066(rfc.locale)
        return lang if lang
      end

      code = rfc.language
      if code.size == 2
        lang = find_by_iso_639_1(code)
      elsif code.size == 3
        lang = find_by_iso_639_3(code)
      end

      lang
    end

    def code; iso_639_1 || iso_639_3 || rfc_3066; end
    
    def code=(new_code)
      if new_code =~ /-/
        self.rfc_3066 = new_code
      else
        raise ArgumentError, 
          "code must be in rfc_3066 format, with a hyphen character; was #{new_code}"
      end
    end

    def native_name; self['native_name'] || self['english_name'] end

    def ==(other)
      return false if !other.kind_of? Language
      self.code == other.code
    end

    def plural_index(num)

      # number is not defined, so we assume no pluralization
      return 1 if num.nil?

      c = num
      expr = pluralization || 'c == 1 ? 2 : 1'

      instance_eval(expr)
    end

    def to_s;    english_name end
    def inspect; english_name end

  end
end
