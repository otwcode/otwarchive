require 'active_support'
require 'action_view/helpers/translation_helper'

# Note: added 'ScopeTranslator' namespace so we wouldn't run into problems if
# we needed an actual Translator model later on --elz

# Extentions to make internationalization (i18n) of a Rails application simpler. 
# Support the method +translate+ (or shorter +t+) in models/view/controllers/mailers.
module ScopeTranslator
  module Translator
    # Error for use within Translator
    class TranslatorError < StandardError #:nodoc:
    end

    # Translator version
    VERSION = '0.8.6'

    # Whether strict mode is enabled
    @@strict_mode = false

    # Whether to fallback from the set locale to the default locale
    @@fallback_mode = false

    # Whether to pseudo-translate all fetched strings
    @@pseudo_translate = false

    # Pseudo-translation text to prend to fetched strings.
    # Used as a visible marker. Default is "["
    @@pseudo_prepend = "["

    # Pseudo-translation text to append to fetched strings.
    # Used as a visible marker. Default is "]"
    @@pseudo_append = "]"

    # An optional callback to be notified when there are missing translations in views
    @@missing_translation_callback = nil

    # Invokes the missing translation callback, if it is defined
    def self.missing_translation_callback(exception, key, options = {}) #:nodoc:
      @@missing_translation_callback.call(exception, key, options) if !@@missing_translation_callback.nil?
    end
 
    # Set an optional block that gets called when there's a missing translation within a view.
    # This can be used to log missing translations in production.
    #
    # Block takes two required parameters:
    # - exception (original I18n::MissingTranslationData that was raised for the failed translation)
    # - key (key that was missing)
    # - options (hash of options sent to translator)
    # Example:
    #   set_missing_translation_callback do |ex, key, options|
    #     logger.info("Failed to find #{key}")
    #   end
    def self.set_missing_translation_callback(&block)
      @@missing_translation_callback = block
    end

    # Performs lookup with a given scope. The scope should be an array of strings or symbols
    # ordered from highest to lowest scoping. For example, for a given PicturesController 
    # with an action "show" the scope should be ['pictures', 'show'] which happens automatically.
    #
    # The key and options parameters follow the same rules as the I18n library (they are passed through).
    # 
    # The search order is from most specific scope to most general (and then using a default value, if provided).
    # So continuing the previous example, if the key was "title" and options included :default => 'Some Picture'
    # then it would continue searching until it found a value for:
    # * pictures.show.title
    # * pictures.title
    # * title
    # * use the default value (if provided)
    #
    # The key itself can contain a scope. For example, if there were a set of shared error messages within the 
    # Pictures controller, that could be found using a key like "errors.deleted_picture". The inital search with
    # narrowest scope ('pictures.show.errors.deleted_picture') will not find a value, but the subsequent search with
    # broader scope ('pictures.errors.deleted_picture') will find the string.
    #
    def self.translate_with_scope(scope, key, options={})
      scope ||= [] # guard against nil scope
  
      # Let Rails 2.3 handle keys starting with "."
      raise TranslatorError, "Skip keys with leading dot" if key.to_s.first == "."
  
      # Keep the original options clean
      original_scope = scope.dup
      scoped_options = {}.merge(options)
      
      # Raise to know if the key was found
      scoped_options[:raise] = true
  
      # Remove any default value when searching with scope
      scoped_options.delete(:default)
  
      # Returns an array in special cases or nil
      str = Translation.catch_special_cases(key, options[:locale])
        
      # Loop through each scope until a string is found.
      # Example: starts with scope of [:blog_posts :show] then tries scope [:blog_posts] then 
      # without any automatically added scope ("[]").
      while str.nil?
        # Set scope to use for search
        scoped_options[:scope] = scope
  
        begin
          # try to find key within scope (dup the options because I18n modifies the hash)
          str = I18n.translate(key, scoped_options.dup)
        rescue I18n::MissingTranslationData => exc
          # did not find the string, remove a layer of scoping.
          # break when there are no more layers to remove (pop returns nil)
          break if scope.pop.nil?
        end
      end
      
      # If a string is not yet found, potentially check the default locale if in fallback mode.
      if str.nil? && ScopeTranslator::Translator.fallback? && (I18n.locale != I18n.default_locale) && options[:locale].nil?
        # Recurse original request, but in the context of the default locale
        str ||= ScopeTranslator::Translator.translate_with_scope(original_scope, key, options.merge({:locale => I18n.default_locale}))
      end
  
      # If a string was still not found, fall back to trying original request (gets default behavior)
      options[:scope] = original_scope
      str ||= I18n.translate(key, options)
  
      # If pseudo-translating, prepend / append marker text
      if ScopeTranslator::Translator.pseudo_translate? && !str.nil?
        str = ScopeTranslator::Translator.pseudo_prepend + str + ScopeTranslator::Translator.pseudo_append
      end
      
      # Added method here to add default translations into the database
      # Beats having to do it by hand --elz
      if (I18n.locale == I18n.default_locale) && options[:default].is_a?(String) && str != options[:default]
        Translation.add_default_to_db(I18n.locale, key, options[:default], options[:scope])
        str = I18n.translate(key, options)
      end
  
      str
    end

    class << Translator
  
      # Generic translate method that mimics <tt>I18n.translate</tt> (e.g. no automatic scoping) but includes locale fallback
      # and strict mode behavior.
      def translate(key, options={})
        ScopeTranslator::Translator.translate_with_scope([], key, options)
      end
  
      alias :t :translate
    end

    # When fallback mode is enabled if a key cannot be found in the set locale,
    # it uses the default locale. So, for example, if an app is mostly localized
    # to Spanish (:es), but a new page is added then Spanish users will continue
    # to see mostly Spanish content but the English version (assuming the <tt>default_locale</tt> is :en)
    # for the new page that has not yet been translated to Spanish.
    def self.fallback(enable = true)
      @@fallback_mode = enable
    end

    # If fallback mode is enabled
    def self.fallback?
      @@fallback_mode
    end

    # Toggle whether to true an exception on *all* +MissingTranslationData+ exceptions
    # Useful during testing to ensure all keys are found.
    # Passing +true+ enables strict mode, +false+ installs the default exception handler which
    # does not raise on +MissingTranslationData+
    def self.strict_mode(enable_strict = true)
      @@strict_mode = enable_strict
  
      if enable_strict
        # Switch to using contributed exception handler
        I18n.exception_handler = :strict_i18n_exception_handler
      else
        I18n.exception_handler = :default_exception_handler
      end
    end

    # Get if it is in strict mode
    def self.strict_mode?
      @@strict_mode
    end

    # Toggle a pseudo-translation mode that will prepend / append special text
    # to all fetched strings. This is useful during testing to view pages and visually
    # confirm that strings have been fully extracted into locale bundles.
    def self.pseudo_translate(enable = true)
      @@pseudo_translate = enable
    end

    # If pseudo-translated is enabled
    def self.pseudo_translate?
      @@pseudo_translate
    end

    # Pseudo-translation text to prepend to fetched strings.
    # Used as a visible marker. Default is "[["
    def self.pseudo_prepend
      @@pseudo_prepend
    end

    # Set the pseudo-translation text to prepend to fetched strings.
    # Used as a visible marker.
    def self.pseudo_prepend=(v)
      @@pseudo_prepend = v
    end

    # Pseudo-translation text to append to fetched strings.
    # Used as a visible marker. Default is "]]"
    def self.pseudo_append
      @@pseudo_append
    end

    # Set the pseudo-translation text to append to fetched strings.
    # Used as a visible marker.
    def self.pseudo_append=(v)
      @@pseudo_append = v
    end

    # Additions to TestUnit to make testing i18n easier
    module Assertions
  
      # Assert that within the block there are no missing translation keys.
      # This can be used in a more tailored way that the global +strict_mode+
      #
      # Example:
      #   assert_translated do
      #     str = "Test will fail for #{I18n.t('a_missing_key')}"
      #   end
      #
      def assert_translated(msg = nil, &block)
    
        # Enable strict mode to force raising of MissingTranslationData
        ScopeTranslator::Translator.strict_mode(true)
    
        msg ||= "Expected no missing translation keys"
    
        begin
          yield
          # Credit for running the assertion
          assert(true, msg)
        rescue I18n::MissingTranslationData => e
          # Fail!
          assert_block(build_message(msg, "Exception raised:\n?", e)) {false}
        ensure
          # uninstall strict exception handler
          ScopeTranslator::Translator.strict_mode(false)
        end
      
      end
    end

    module I18nExtensions
      # Add an strict exception handler for testing that will raise all exceptions
      def strict_i18n_exception_handler(exception, locale, key, options)
        # Raise *all* exceptions
        raise exception
      end
  
    end
  end
end

module ActionView #:nodoc:
  class Base
    # Redefine the +translate+ method in ActionView (contributed by TranslationHelper) that is
    # context-aware of what view (or partial) is being rendered. 
    # Initial scoping will be scoped to [:controller_name :view_name]
    def translate_with_context(key, options={})
      # The outer scope will typically be the controller name ("blog_posts")
      # but can also be a dir of shared partials ("shared").
      outer_scope = self.template.base_path
  
      # The template will be the view being rendered ("show.erb" or "_ad.erb")
      inner_scope = self.template.name
  
      # Partials template names start with underscore, which should be removed
      inner_scope.sub!(/^_/, '')
    
      # In the case of a missing translation, fall back to letting TranslationHelper
      # put in span tag for a translation_missing.
      begin
        ScopeTranslator::Translator.translate_with_scope([outer_scope, inner_scope], key, options.merge({:raise => true}))
      rescue ScopeTranslator::Translator::TranslatorError, I18n::MissingTranslationData => exc
        # Call the original translate method
        str = translate_without_context(key, options)
      
        # View helper adds the translation missing span like:
        # In strict mode, do not allow TranslationHelper to add "translation missing" span like:
        # <span class="translation_missing">en, missing_string</span>
        if str =~ /span class\=\"translation_missing\"/
          # In strict mode, do not allow TranslationHelper to add "translation missing"
          raise if ScopeTranslator::Translator.strict_mode?
        
          # Invoke callback if it is defined
          ScopeTranslator::Translator.missing_translation_callback(exc, key, options)
        end

        str
      end
    end

    alias_method_chain :translate, :context
    alias :t :translate
  end
end

module ActionController #:nodoc:
  class Base
  
    # Add a +translate+ (or +t+) method to ActionController that is context-aware of what controller and action
    # is being invoked. Initial scoping will be [:controller_name :action_name] when looking up keys. Example would be
    # +['posts' 'show']+ for the +PostsController+ and +show+ action.
    def translate_with_context(key, options={})
      ScopeTranslator::Translator.translate_with_scope([self.controller_name, self.action_name], key, options)
    end

    alias_method_chain :translate, :context
    alias :t :translate
  end
end

module ActiveRecord #:nodoc:
  class Base
    # Add a +translate+ (or +t+) method to ActiveRecord that is context-aware of what model is being invoked. 
    # Initial scoping of [:model_name] where model name is like 'blog_post' (singular - *not* the table name) 
    def translate(key, options={})
      begin
        ActiveRecord::Base.connection
        ScopeTranslator::Translator.translate_with_scope([self.class.name.underscore], key, options)
      rescue 
        options[:default] || '' 
      end
    end

    alias :t :translate  

    # Add translate as a class method as well so that it can be used in validate statements, etc.
    class << Base
  
      def translate(key, options={}) #:nodoc:
        begin
          ActiveRecord::Base.connection
          ScopeTranslator::Translator.translate_with_scope([self.name.underscore], key, options)
        rescue 
          options[:default] || '' 
        end
      end
  
      alias :t :translate
    end
  end
end

module ActionMailer #:nodoc:
  class Base

    # Add a +translate+ (or +t+) method to ActionMailer that is context-aware of what mailer and action
    # is being invoked. Initial scoping of [:mailer_name :action_name] where mailer_name is like 'comment_mailer' 
    # and action_name is 'comment_notification' (note: no "deliver_" or "create_")
    def translate(key, options={})
      ScopeTranslator::Translator.translate_with_scope([self.mailer_name, self.action_name], key, options)
    end

    alias :t :translate
  end
end

module I18n
  # Install the strict exception handler for testing
  extend ScopeTranslator::Translator::I18nExtensions
end

module Test # :nodoc: all
  module Unit
    class TestCase
      include ScopeTranslator::Translator::Assertions
    end
  end
end

# In test environment, enable strict exception handling for missing translations
if (defined? RAILS_ENV) && (RAILS_ENV == "test")
  ScopeTranslator::Translator.strict_mode(true)
end