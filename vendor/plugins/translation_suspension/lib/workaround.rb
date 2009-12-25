module ActiveRecord #:nodoc:
  class Base
    def translate(key, options={})
      begin
        ActiveRecord::Base.connection
        I18n.backend.translate('en-US', key, options)
      rescue 
        options[:default] || '' 
      end      
    end

    alias :t :translate

    class << Base
  
      def translate(key, options={})
        begin
          ActiveRecord::Base.connection
          I18n.backend.translate('en-US', key, options)
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
    def translate(key, options={})
      begin
        ActiveRecord::Base.connection
        I18n.backend.translate('en-US', key, options)
      rescue 
        options[:default] || '' 
      end      
    end

    alias :t :translate
  end
end
