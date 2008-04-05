module Globalize #:nodoc:
  class SupportedLocales

    attr_accessor :supported_locales, :active_locales
    attr_accessor :base_locale, :default_locale
    attr_accessor :supported_locales_map, :active_locales_map
    attr_accessor :base_locale_object, :default_locale_object

=begin
    Class that encapsulates the concept of an applications supported locales.
    Allows specification of:

      * Supported locales

          e.g. SupportedLocales.define(['es-ES,'he-IL'])

        An application can support a number of locales
        (e.g. visible in both the front and back ends)

      * Globalize base locale

          e.g. SupportedLocales.define(['es-ES,'he-IL'], 'en-US')

        Note: This defaults to 'en-US' if unspecified

      * Active locales

          e.g. SupportedLocales.define(['es-ES,'he-IL','fr-FR'], 'en-US', ['es-ES,'fr-FR'])

        Perhaps you only want to allow certain locales to be visible in the front
        end while content in other locales is still being translated.

      * Default locale

        e.g. SupportedLocales.define(['es-ES,'he-IL','fr-FR'], 'en-US', ['es-ES,'fr-FR'], 'es-ES')

        Perhaps the default locale of your front end is distinct from the base
        locale used in the back end.

        Note: This defaults to the base locale if unspecified
=end
    def self.define(supported_locales = [], base_locale = 'en-US', active_locales = [], default_locale = nil)
      return @@instance if (defined?(@@instance) && @@instance)
      @@instance = new(supported_locales, base_locale, active_locales, default_locale)
    end

    private_class_method  :new

    def self.instance
      return @@instance if defined? @@instance
    end

    def self.clear
      @@instance = nil
    end

    def initialize(supported_locales, base_locale, active_locales, default_locale)
      @supported_locales = supported_locales
      @base_locale = base_locale

      @default_locale = default_locale
      @default_locale = base_locale.dup unless default_locale

      @active_locales = supported_locales.dup unless supported_locales.empty?
      @active_locales = active_locales unless active_locales.empty?

      raise "No supported Globalize locales defined. Please specify at least one!" if @supported_locales.empty?
      setup
    end

    class << self
      def supported_locale_codes
        self.instance.supported_locales
      end

      def supported_locales
        self.instance.supported_locales.collect do |locale_code|
          self.instance.supported_locales_map[locale_code]
        end
      end

      def supported_language_codes
        self.instance.supported_locales.collect do |locale_code|
          self.instance.supported_locales_map[locale_code].language.code
        end
      end

      def active_locale_codes
        self.instance.active_locales
      end

      def active_locales
        self.instance.active_locales.collect do |locale_code|
          self.instance.active_locales_map[locale_code]
        end
      end

      def active_language_codes
        self.instance.active_locales.collect do |locale_code|
          self.instance.active_locales_map[locale_code].language.code
        end
      end

      def inactive_locale_codes
        self.instance.supported_locales - self.instance.active_locales
      end

      def inactive_locales
        inactive_locale_codes.collect do |locale_code|
          self.instance.supported_locales_map[locale_code]
        end
      end

      def inactive_language_codes
        inactive_locale_codes.collect do |locale_code|
          self.instance.supported_locales_map[locale_code].language.code
        end
      end

      def supported?(locale)
        case locale
          when String
            supported_locale_codes.include?(locale) || supported_language_codes.include?(locale)
          when Globalize::Locale
          self.instance.supported_locales_map.values.any? {|l| l.code == locale.code}
        end
      end

      def supported(code)
        self.instance.supported_locales_map[code] || supported_language(code)
      end

      def supported_language(language_code)
        supported_code = self.instance.supported_locales_map.keys.detect do |code|
          code[0..1] == language_code
        end
        self.instance.supported_locales_map[supported_code] if supported_code
      end

      alias_method :[], :supported

      def active(code)
        self.instance.active_locales_map[code] || active_language(code)
      end

      def active_language(language_code)
        active_code = self.instance.active_locales_map.keys.detect do |code|
          code[0..1] == language_code
        end
        self.instance.active_locales_map[active_code] if active_code
      end

      def non_base(code)
        return nil if code == base_locale_code || code == base_language_code
        self.instance.supported_locales_map[code] || non_base_language(code)
      end

      def non_base_language(language_code)
        return nil if language_code == base_language_code
        non_base_code = self.instance.supported_locales_map.keys.detect do |code|
          code[0..1] == language_code
        end
        self.instance.supported_locales_map[non_base_code] if non_base_code
      end

      def non_base?(locale)
        case locale
          when String
            non_base_locale_codes.include?(locale) || non_base_language_codes.include?(locale)
          when Globalize::Locale
            non_base_locales.any? {|l| l.code == locale.code}
        end
      end

      def active?(locale)
        case locale
          when String
            active_locale_codes.include?(locale) || active_language_codes.include?(locale)
          when Globalize::Locale
            self.instance.active_locales_map.values.any? {|l| l.code == locale.code}
        end
      end

      def inactive?(locale)
        case locale
          when String
            inactive_locale_codes.include?(locale) || inactive_language_codes.include?(locale)
          when Globalize::Locale
            inactive_locales.any? {|l| l.code == locale.code}
        end
      end

      def base_locale
        self.instance.base_locale_object
      end

      def default_locale
        self.instance.default_locale_object
      end

      def base_locale_code
        self.instance.base_locale
      end

      def base_language_code
        self.instance.base_locale_object.language.code
      end

      def default_locale_code
        self.instance.default_locale
      end

      def default_language_code
        self.instance.default_locale_object.language.code
      end

      def base_english_name
        Globalize::Locale.base_language.english_name
      end

      def base_native_name
        Globalize::Locale.base_language.native_name
      end

      def default_english_name
        self.instance.default_locale_object.language.english_name
      end

      def default_native_name
        self.instance.default_locale_object.language.native_name
      end

      def non_base_locales
        self.instance.supported_locales.dup.delete_if {|locale_code| locale_code == base_locale_code}.collect {|locale_code| self.instance.supported_locales_map[locale_code]}.compact
      end

      def non_base_locale_codes
        non_base_locales.collect {|locale| locale.code}
      end

      def non_base_language_codes
        non_base_locales.collect {|locale| locale.language.code}
      end

      def non_base_native_language_names
        non_base_locales.collect {|locale| locale.language.native_name}
      end

      def non_base_english_language_names
        non_base_locales.collect {|locale| locale.language.english_name}
      end

      def supported_native_language_names
        supported_locales.collect {|locale| locale.language.native_name}
      end

      def supported_english_language_names
        supported_locales.collect {|locale| locale.language.english_name}
      end

      def active_native_language_names
        active_locales.collect {|locale| locale.language.native_name}
      end

      def active_english_language_names
        active_locales.collect {|locale| locale.language.english_name}
      end

      def inactive_native_language_names
        inactive_locales.collect {|locale| locale.language.native_name}
      end

      def inactive_english_language_names
        inactive_locales.collect {|locale| locale.language.english_name}
      end
    end

    protected

      def setup
        @base_locale_object = Globalize::Locale.new(@base_locale)
        raise "Globalize base language undefined!" unless @base_locale_object.language

        Globalize::Locale.clear_cache
        Globalize::Locale.set_base_language(@base_locale_object.language)
        raise "Globalize base language undefined!" unless Globalize::Locale.base_language

        @supported_locales.unshift(@base_locale) unless @supported_locales.include? @base_locale
        @supported_locales_map = Hash[*@supported_locales.collect do |locale_code|
          locale = Globalize::Locale.new(locale_code)
          raise "Language for code: #{locale_code} doesn't exist! Check globalize tables." unless locale.language
          [locale_code, locale] if locale
        end.flatten]

        @active_locales.unshift(@base_locale) unless @active_locales.include? @base_locale
        @active_locales_map = Hash[*@active_locales.collect do |locale_code|
          raise "Globalize active locale code (#{locale_code}) not one of supported locales"  unless @supported_locales_map[locale_code]
          [locale_code, @supported_locales_map[locale_code]]
        end.flatten]

        raise "Globalize default locale not one of supported locales" unless @active_locales.include?(@default_locale)
        @default_locale_object = Globalize::Locale.new(@default_locale)
        raise "Globalize default language undefined!" unless @default_locale_object.language
      end
  end

  class ActiveLocales < SupportedLocales
    class << self
      alias_method :[], :active
    end
  end

  class NonBaseLocales < SupportedLocales
    class << self
      alias_method :[], :non_base
    end
  end
end