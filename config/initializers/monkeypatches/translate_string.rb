module I18n
  class << self
    # A shorthand for translation that takes a string as its first argument, which
    # will be the default string, and automatically generates a key based on the 
    # current controller/action and the string itself. 
    #
    # If you pass anything other than a string as the first argument it will behave exactly 
    # like the ordinary I18n.translate. 
    def translate_string(*args)
      if args.first.is_a?(String)
        options = args.last.is_a?(Hash) ? args.pop : {}
        default_string = args.shift
        key = "#{self.class.name}."
        if options.has_key?(:key)
           key = options[:key] + "."
        end
        key += default_string[0..15].gsub(/[^a-zA-Z0-9]/, '')
        #Rails.logger.info "XXXXXXXXXXXX #{key.to_sym} XXXXXXXXXXXX #{default_string} XXXXXXXXXXXX"
        # add the default string as an option, and hand off to translate.
        options.merge!(:default => default_string)
        translate(key.to_sym, options)
      else
        translate(args)
      end
    end
    alias :ts :translate_string
  end
end

module AbstractController
  module Translation
    def translate_string(*args)
      I18n.translate_string(*args)
    end
    alias :ts :translate_string
  end
end


module ActiveRecord #:nodoc:
  class Base
    def translate_string(*args)
      begin
        ActiveRecord::Base.connection
        I18n.translate_string(*args)
      rescue 
        args.first || '' 
      end      
    end

    alias :ts :translate_string

    class << Base
  
      def translate_string(*args)
        begin
          ActiveRecord::Base.connection
          I18n.translate_string(*args)
        rescue 
          args.first || '' 
        end      
      end

      alias :ts :translate_string
    end
  end
end

module ActionMailer #:nodoc:
  class Base
    def translate_string(*args)
      begin
        ActiveRecord::Base.connection
        I18n.translate_string(*args)
      rescue 
        args.first || '' 
      end      
    end

    alias :ts :translate_string
  end
end

# Note: we define this separately for ActionView so that we get the controller/action name
# in the key, and use the added scoping for translate in TranslationHelper.
module ActionView
  module Helpers
    module TranslationHelper
      def translate_string(*args)
        if args.first.is_a?(String)
          options = args.last.is_a?(Hash) ? args.pop : {}
          default_string = args.shift
          key = ""
          if defined? controller
            if defined? controller.controller_name
              key = "#{controller.controller_name}.#{controller.action_name}."
            else
              key = "#{controller.class.name.underscore}."
            end
          else
            key = "#{self.class.name}."
          end
          if options.has_key?(:key)
            key = options[:key] + "."
          end
          key += default_string[0..15].gsub(/[^a-zA-Z0-9]/, '')
          #Rails.logger.info "XXXXXXXXXXXX #{key.to_sym} XXXXXXXXXXXX #{default_string} XXXXXXXXXXXX"
          # add the default string as an option, and hand off to translate.
          options.merge!(:default => default_string)
          translate(key.to_sym, options)
        else
          translate(args)
        end
      end
      alias :ts :translate_string
    end
  end
end
