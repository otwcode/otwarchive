# ClickToGlobalize
module Globalize # :nodoc:
  class Locale # :nodoc:
    class << self
      alias_method :__translate, :translate
      def translate(key, default = nil, arg = nil, namespace = nil) # :nodoc:
        result = __translate(key, default, arg, namespace)
        notify_observers(key, result)
        result
      end
      
      # Returns the active <tt>Locale</tt> or create a new one, checking the choosen base language.
      # To easily plug-in this code I need always a ready Locale.
      def active
        @@active ||= Locale.set(@@base_language_code.locale)
      end
      
      # Check if the the class has a current active <tt>Locale</tt>, calling the homonymous method.
      # To easily plug-in this code I need always a ready <tt>Locale</tt>.
      def active?
        !active.nil?
      end
      
      def notify_observers(key, result) # :nodoc:
        observers.each { |observer| observer.update(key, result) }
      end
      
      def add_observer(observer) # :nodoc:
        observers << observer
      end
      
      def remove_observer(observer) # :nodoc:
        observers.delete(observer)
      end
      
      def observers # :nodoc:
        @observers ||= Set.new
      end
      
      def formatting # :nodoc:
        @formatting
      end
      
      # Sets the current formatting style.
      #
      # The options available are:
      #   * textile (RedCloth gem)
      #   * markdown (BlueCloth gem)
      def formatting=(formatting)
        @formatting = case formatting.to_sym
                        when :textile  then textile?  ? :textile  : nil
                        when :markdown then markdown? ? :markdown : nil
                        else           raise ArgumentError
                      end
      end

      # Returns the method for the current formatting style.
      #
      # The available methods are:
      #   * textilize_without_paragraph (textile)
      #   * markdown (markdown)
      def formatting_method
        case @formatting
          when :textile  then :textilize_without_paragraph
          when :markdown then :markdown
        end
      end

      # Checks if the RedCloth gem is installed and already required.
      def textile?
        @textile ||= Object.const_defined?(:RedCloth)
      end
      
      # Checks if the BlueCloth gem is installed and already required.
      def markdown?
        @markdown ||= Object.const_defined?(:BlueCloth)
      end
    end
  end 

  # Implements the Observer Pattern, when <tt>Locale#translate</tt> is called,
  # it notify <tt>LocaleObserver</tt>, passing the translation key and the result for
  # the current locale.
  class LocaleObserver
    attr_reader :translations
    
    def initialize # :nodoc:
      @translations = {}
    end
    
    def update(key, result) # :nodoc:
      @translations = @translations.merge({key, result})
    end
  end
  
  module Helper # :nodoc:
    @@partial = 'shared/_click_to_globalize'
    
    # Render +app/views/shared/_click_to_globalize.html.erb+.
    def click_to_globalize
      # Note: controller.class.globalize? is deprecated.
      return unless controller.globalize? && controller.class.globalize?
      render @@partial
    end
    
    # Returns the user defined languages in <tt>ApplicationController</tt>.
    def languages
      controller.class.languages
    end
    
    # Creates the HTML markup for the languages picker menu.
    #
    # Example:
    #
    #   class ApplicationController < ActionController::Base
    #     self.languages :english => 'en-US', :italian => 'it-IT'
    #   end
    #
    #   <%= languages_menu %>
    #
    #   returns:
    #   <ul>
    #     <li><a href="/locale/set/en-US" title="* English [en-US]">* English</a></li> |
    #     <li><a href="/locale/set/it-IT" title="Italian [it-IT]">Italian</a></li>
    #   </ul>
    def languages_menu
      returning result = '<ul>' do
        result << languages.map do |language, locale|
          language = language.to_s.titleize
          language = "* #{language}" if locale == Locale.active.code
          "<li>#{link_to language, {:controller => 'locale', :action => 'set', :id => locale}, {:title => "#{language} [#{locale}]"}}</li>"
        end * ' | '
      end
      result << '</ul>'
    end
  end
  
  module Controller # :nodoc:
    module InstanceMethods # :nodoc:
      # This is the <b>on/off</b> switch for the Click to Globalize features.
      # Override this method in your controllers for custom conditions.
      #
      # Example:
      #
      #   def globalize?
      #     current_user.admin?
      #   end
      def globalize?
        true
      end
      
      private
      # It's used as around_filter method, to add a <tt>LocaleObserver</tt> while the
      # request is processed.
      # <tt>LocaleObserver</tt> catches all translations and pass them to the session.
      def observe_locale
        locale_observer = LocaleObserver.new
        Globalize::Locale.add_observer(locale_observer)
        yield
        Globalize::Locale.remove_observer(locale_observer)
        if false #logged_in? && current_user.translation_mode_active
          session[:__globalize_translations] = if Locale.formatting
                                                 locale_observer.translations.each{|key, translation| locale_observer.translations[key] = strip_tags(self.send(Locale.formatting_method, translation)) }
                                               else
                                                 locale_observer.translations
                                               end
        else
          session[:__globalize_translations] = nil
        end
      end
    end
    
    module SingletonMethods      
      # Checks if the application is in globalization mode.
      #
      # Override this method in your controllers for custom conditions.
      #
      # Example:
      #
      #   def self.globalize?
      #     current_user.admin?
      #   end
      #
      # Note: this method is deprecated in favor of globalize?.
      def globalize?
        true
      end

      # Sets the current formatting style.
      #
      # The options available are:
      #   * textile (RedCloth gem)
      #   * markdown (BlueCloth gem)
      #
      # Example:
      #
      #   class ApplicationController < ActionController::Base
      #     self.formatting :textile
      #   end
      def formatting(formatting)
        Locale.formatting = formatting
      end

      def languages #:nodoc:
        @@languages ||= {Locale.active.language.to_s.downcase.to_sym =>  Locale.active.code}
      end
      
      # Set the application languages.
      #
      # Example:
      #
      #   class ApplicationController < ActionController::Base
      #     self.languages = { :english => 'en-US, :italian => 'it-IT' }
      #   end
      def languages=(languages_hash)
        base_language = Locale.active.language.nil? ? {} : { Locale.active.language.to_s.downcase.to_sym => Locale.active.code }
        @@languages = languages_hash.merge(base_language) unless languages_hash.nil?
        @@languages
      end
    end
  end
end

module ApplicationHelper # :nodoc:
  include Globalize::Helper
end

ActionController::Base.class_eval do # :nodoc:
  extend Globalize::Controller::SingletonMethods
  include Globalize::Controller::InstanceMethods
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  # Note: self.globalize? is deprecated.
  around_filter :observe_locale, :except => { :controller => :locale }, :if => globalize? && self.globalize?
end