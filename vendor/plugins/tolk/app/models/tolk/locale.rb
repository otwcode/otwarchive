module Tolk
  class Locale < ActiveRecord::Base
    set_table_name "tolk_locales"
    
    MAPPING = {
      'ar'    => 'Arabic',
      'bs'    => 'Bosnian',
      'bt'    => 'Bulgarian',
      'ca'    => 'Catalan',
      'cz'    => 'Czech',
      'da'    => 'Danish',
      'de'    => 'German',
      'dsb'   => 'Lower Sorbian',
      'el'    => 'Greek',
      'en'    => 'English',
      'es'    => 'Spanish',
      'et'    => 'Estonian',
      'fa'    => 'Persian',
      'fi'    => 'Finnish',
      'fr'    => 'French',
      'he'    => 'Hebrew',
      'hr'    => 'Croatian',
      'hsb'   => 'Upper Sorbian',
      'hu'    => 'Hungarian',
      'id'    => 'Indonesian',
      'is'    => 'Icelandic',
      'it'    => 'Italian',
      'jp'    => 'Japanese',
      'ko'    => 'Korean',
      'lo'    => 'Lao',
      'lt'    => 'Lithuanian',
      'lv'    => 'Latvian',
      'mk'    => 'Macedonian',
      'nl'    => 'Dutch',
      'no'    => 'Norwegian',
      'pl'    => 'Polish',
      'pt-BR' => 'Portuguese (Brazilian)',
      'pt-PT' => 'Portuguese (Portugal)',
      'ro'    => 'Romanian',
      'ru'    => 'Russian',
      'se'    => 'Swedish',
      'sk'    => 'Slovak',
      'sl'    => 'Slovenian',
      'sr'    => 'Serbian',
      'sw'    => 'Swahili',
      'th'    => 'Thai',
      'tr'    => 'Turkish',
      'uk'    => 'Ukrainian',
      'vi'    => 'Vietnamese',
      'zh'    => 'Chinese'
    }

    has_many :phrases, :through => :translations, :class_name => 'Tolk::Phrase'
    has_many :translations, :class_name => 'Tolk::Translation', :dependent => :destroy
    accepts_nested_attributes_for :translations, :reject_if => proc { |attributes| attributes['text'].blank? }
    before_validation_on_update :remove_invalid_translations_from_target

    cattr_accessor :locales_config_path
    self.locales_config_path = "#{Rails.root}/config/locales"

    cattr_accessor :primary_locale_name
    self.primary_locale_name = I18n.default_locale.to_s

    include Tolk::Sync
    include Tolk::Import

    validates_uniqueness_of :name
    validates_presence_of :name

    cattr_accessor :special_prefixes
    self.special_prefixes = ['activerecord.attributes']

    cattr_accessor :special_keys
    self.special_keys = ['activerecord.models']

    class << self
      def primary_locale(reload = false)
        @_primary_locale = nil if reload
        @_primary_locale ||= begin
          raise "Primary locale is not set. Please set Locale.primary_locale_name in your application's config file" unless self.primary_locale_name
          find_or_create_by_name(self.primary_locale_name)
        end
      end

      def primary_language_name
        primary_locale.language_name
      end

      def secondary_locales
        all - [primary_locale]
      end

      def dump_all(to = self.locales_config_path)
        secondary_locales.each do |locale|
          File.open("#{to}/#{locale.name}.yml", "w+") do |file|
            data = locale.to_hash
            data.respond_to?(:ya2yaml) ? file.write(data.ya2yaml(:syck_compatible => true)) : YAML.dump(locale.to_hash, file)
          end
        end
      end

      def special_key_or_prefix?(prefix, key)
        self.special_prefixes.include?(prefix) || self.special_keys.include?(key)
      end

      PLURALIZATION_KEYS = ['zero', 'one', 'two', 'few', 'many', 'other']
      def pluralization_data?(data)
        keys = data.keys.map(&:to_s)
        keys.all? {|k| PLURALIZATION_KEYS.include?(k) }
      end
    end

    def has_updated_translations?
      translations.count(:conditions => {:'tolk_translations.primary_updated' => true}) > 0
    end

    def phrases_with_translation(page = nil)
      find_phrases_with_translations(page, :'tolk_translations.primary_updated' => false)
    end

    def phrases_with_updated_translation(page = nil)
      find_phrases_with_translations(page, :'tolk_translations.primary_updated' => true)
    end

    def count_phrases_without_translation
      existing_ids = self.translations.all(:select => 'tolk_translations.phrase_id').map(&:phrase_id).uniq
      Tolk::Phrase.count - existing_ids.count
    end

    def phrases_without_translation(page = nil, options = {})
      phrases = Tolk::Phrase.scoped(:order => 'tolk_phrases.key ASC')

      existing_ids = self.translations.all(:select => 'tolk_translations.phrase_id').map(&:phrase_id).uniq
      phrases = phrases.scoped(:conditions => ['tolk_phrases.id NOT IN (?)', existing_ids]) if existing_ids.present?

      result = phrases.paginate({:page => page}.merge(options))
      Tolk::Phrase.send :preload_associations, result, :translations
      result
    end

    def search_phrases(query, page = nil, options = {})
      return [] unless query.present?

      translations = Tolk::Locale.primary_locale.translations.all(:conditions => ["tolk_translations.text LIKE ?", "%#{query}%"])

      phrases = Tolk::Phrase.scoped(:order => 'tolk_phrases.key ASC')      
      phrases = phrases.scoped(:conditions => ['tolk_phrases.id IN(?)', translations.map(&:phrase_id).uniq])
      phrases.paginate({:page => page}.merge(options))
    end
    
    def search_phrases_without_translation(query, page = nil, options = {})
      return phrases_without_translation(page, options) unless query.present?
      
      phrases = Tolk::Phrase.scoped(:order => 'tolk_phrases.key ASC')

      found_translations_ids = Tolk::Locale.primary_locale.translations.all(:conditions => ["tolk_translations.text LIKE ?", "%#{query}%"], :select => 'tolk_translations.phrase_id').map(&:phrase_id).uniq
      existing_ids = self.translations.all(:select => 'tolk_translations.phrase_id').map(&:phrase_id).uniq
      phrases = phrases.scoped(:conditions => ['tolk_phrases.id NOT IN (?) AND tolk_phrases.id IN(?)', existing_ids, found_translations_ids]) if existing_ids.present?

      result = phrases.paginate({:page => page}.merge(options))
      Tolk::Phrase.send :preload_associations, result, :translations
      result
    end

    def to_hash
      { name => translations.each_with_object({}) do |translation, locale|
        if translation.phrase.key.include?(".")
          locale.deep_merge!(unsquish(translation.phrase.key, translation.value))
        else
          locale[translation.phrase.key] = translation.value
        end
      end }
    end

    def to_param
      name.parameterize
    end

    def primary?
      name == self.class.primary_locale_name
    end

    def language_name
      MAPPING[self.name] || self.name
    end

    def [](key)
      if phrase = Tolk::Phrase.find_by_key(key)
        t = self.translations.find_by_phrase_id(phrase.id)
        t.text if t
      end
    end

    def translations_with_html
      translations = self.translations.all(:conditions => "tolk_translations.text LIKE '%>%' AND 
        tolk_translations.text LIKE '%<%' AND tolk_phrases.key NOT LIKE '%_html'", :joins => :phrase)
      Translation.send :preload_associations, translations, :phrase
      translations
    end

    private

    def remove_invalid_translations_from_target
      self.translations.proxy_target.each do |t|
        unless t.valid?
          self.translations.proxy_target.delete(t)
        else
          t.updated_at = Time.current # Silly hax to fool autosave into saving the record
        end
      end

      true
    end

    def find_phrases_with_translations(page, conditions = {})
      result = Tolk::Phrase.paginate(:page => page,
        :conditions => { :'tolk_translations.locale_id' => self.id }.merge(conditions),
        :joins => :translations, :order => 'tolk_phrases.key ASC')

      Tolk::Phrase.send :preload_associations, result, :translations

      result.each do |phrase|
        phrase.translation = phrase.translations.for(self)
      end

      result
    end

    def unsquish(string, value)
      if string.is_a?(String)
        unsquish(string.split("."), value)
      elsif string.size == 1
        { string.first => value }
      else
        key  = string[0]
        rest = string[1..-1]
        { key => unsquish(rest, value) }
      end
    end
  end
end
