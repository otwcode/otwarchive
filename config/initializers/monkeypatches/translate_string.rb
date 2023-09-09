module I18n
  class << self
    # Formats a string. Used to mark strings that should eventually be
    # translated with I18n, but aren't at the moment.
    #
    # Deprecated.
    def translate_string(str, **options)
      str % options
    end

    alias :ts :translate_string
  end
end

module AbstractController
  module Translation
    def translate_string(str, **options)
      I18n.translate_string(str, **options)
    end
    alias :ts :translate_string
  end
end


module ActiveRecord #:nodoc:
  class Base
    def translate_string(str, **options)
      begin
        ActiveRecord::Base.connection
        I18n.translate_string(str, **options)
      rescue StandardError
        str || ""
      end
    end

    alias :ts :translate_string

    class << Base
      def translate_string(str, **options)
        begin
          ActiveRecord::Base.connection
          I18n.translate_string(str, **options)
        rescue StandardError
          str || ""
        end
      end

      alias :ts :translate_string
    end
  end
end

module ActionMailer #:nodoc:
  class Base
    def translate_string(str, **options)
      begin
        ActiveRecord::Base.connection
        I18n.translate_string(str, **options)
      rescue StandardError
        str || ""
      end
    end

    alias :ts :translate_string
  end
end

module ActionView
  module Helpers
    module TranslationHelper
      def translate_string(str, **options)
        str % options
      end

      alias :ts :translate_string
    end
  end
end
