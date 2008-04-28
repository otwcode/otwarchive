module ActiveRecord
  module Validations
    LIVE_VALIDATIONS_OPTIONS = {
      :failureMessage => :message,
      :validMessage => :valid_message,
      :pattern => :with,
      :onlyInteger => :only_integer
    }
    # more complicated mappings in map_configuration method

    VALIDATION_METHODS = {
      :presence => "Validate.Presence",
      :numericality => "Validate.Numericality",
      :format => "Validate.Format",
      :length => "Validate.Length",
      :acceptance => "Validate.Acceptance",
      :confirmation => "Validate.Confirmation"
    }


    module ClassMethods

      VALIDATION_METHODS.keys.each do |type|
        define_method "validates_#{type}_of_with_live_validations".to_sym do |*attr_names|
          send "validates_#{type}_of_without_live_validations".to_sym, *attr_names
          define_validations(type, attr_names)
        end
        alias_method_chain "validates_#{type}_of".to_sym, :live_validations
      end

      def live_validations
        @live_validations ||= {}
      end

      private

      def define_validations(validation_type, attr_names)
        conf = (attr_names.last.is_a?(Hash) ? attr_names.pop : {})
        attr_names.each do |attr_name|
          configuration = map_configuration(conf.dup, validation_type, attr_name)
          add_live_validation(attr_name, validation_type, configuration)
        end
      end

      def add_live_validation(attr_name, type, configuration = {})
        @live_validations ||= {}
        @live_validations[attr_name] ||= {}
        @live_validations[attr_name][type] = configuration
      end

      def map_configuration(configuration, type = nil, attr_name = '')
        LIVE_VALIDATIONS_OPTIONS.each do |live, rails|
          configuration[live] = configuration.delete(rails)
        end
        if type == :numericality
          if configuration[:onlyInteger]
            configuration[:notAnIntegerMessage] = configuration.delete(:failureMessage)
          else
            configuration[:notANumberMessage] = configuration.delete(:failureMessage)
          end
        end
        if type == :length and range = ( configuration.delete(:in) || configuration.delete(:within) )
          configuration[:minimum] = range.begin
          configuration[:maximum] = range.end
          configuration[:tooShortMessage] = configuration.delete(:failureMessage)
          configuration[:tooLongMessage] = configuration[:tooShortMessage]
        end
        if type == :confirmation
          configuration[:match] = self.to_s.underscore + '_' + attr_name.to_s + '_confirmation'
        end
        configuration[:validMessage] ||= ''
        configuration.reject {|k, v| v.nil? }
      end
    end
  end
end
