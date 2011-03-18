# coding: utf-8

module Delayed
  module Mailer
    
    def self.included(base)
      base.class_eval do
        class << self
          alias_method :orig_method_missing, :method_missing
          
          def method_missing(method_symbol, *params)
            
            if ::Delayed::Mailer.excluded_environments &&
              ::Delayed::Mailer.excluded_environments.include?(::RAILS_ENV.to_sym)
              return orig_method_missing(method_symbol, *params)
            end
            
            case method_symbol.id2name
            when /^deliver_([_a-z]\w*)\!/ then orig_method_missing(method_symbol, *params)
            when /^deliver_([_a-z]\w*)/ then self.send_later("#{method_symbol}!", *params)
            else orig_method_missing(method_symbol, *params)
            end
          end
        end
      end
      
      def self.excluded_environments=(*environments)
        @@excluded_environments = environments && environments.flatten.collect! { |env| env.to_sym }
      end
      
      def self.excluded_environments
        @@excluded_environments ||= []
      end
    end
    
  end
end
