module ActiveModel
  module Validations
    LIVE_VALIDATIONS_OPTIONS = {
      :failureMessage => :message,
      :pattern => :with,
      :onlyInteger => :only_integer
    }
    # more complicated mappings in map_configuration method

    VALIDATION_METHODS = {
      :presence => { :method => "Validate.Presence", 
  		  :messages => { 
  			  :failureMessage => "live_validation.presence.failure" 
  			} 
  		},
      :numericality =>  { :method => "Validate.Numericality",
		    :messages => { 
    			:notANumberMessage => "live_validation.numericality.not_a_number", 
    			:notAnIntegerMessage => "live_validation.numericality.not_an_integer",
    			:wrongNumberMessage => "live_validation.numericality.wrong_number",
    			:tooLowMessage => "live_validation.numericality.too_low",
    			:tooHighMessage => "live_validation.numericality.too_high"
    		} 
		  },
      :format => { :method => "Validate.Format",
    		:messages => { 
    			:failureMessage => "live_validation.format.failure"
    		} 
    	},
      :length => { :method => "Validate.Length",
    		:messages => { 
    			:wrongLengthMessage => "live_validation.length.wrong_length", 
    			:tooShortMessage => "live_validation.length.too_short",
    			:tooLongMessage => "live_validation.length.too_long" 
    		}
    	},
      :acceptance => { :method => "Validate.Acceptance",
    		:messages => { 
    			:failureMessage => "live_validation.acceptance.failure"
    		}
    	},
      :confirmation => { :method => "Validate.Confirmation",
    		:messages => { 
    			:failureMessage => "live_validation.confirmation.failure"
    		} 
    	}
    }


    module HelperMethods

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
        end
        if type == :confirmation
          configuration[:match] = self.to_s.underscore + '_' + attr_name.to_s + '_confirmation'
        end
#        configuration[:validMessage] ||= ''
        configuration.reject {|k, v| v.nil? }
      end
    end
  end
end
