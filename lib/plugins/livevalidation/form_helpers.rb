module ActionView
  
  mattr_accessor :live_validations
  ActionView::live_validations = true
  
  module Helpers
    module FormHelper
      [ :text_field, :text_area, :password_field ].each do |field_type|
        define_method "#{field_type}_with_live_validations" do |object_name, method, options|
          live = options.delete(:live)
          live = ActionView::live_validations if live.nil?
          send("#{field_type}_without_live_validations", object_name, method, options) +
          ( live ? live_validations_for(object_name, method) : '' )
        end
        alias_method_chain field_type, :live_validations
      end

      def live_validations_for(object_name, method)
        script_tags(live_validation(object_name, method))
      end
      
      private
      
      def live_validation(object_name, method)
        if validations = self.instance_variable_get("@#{object_name.to_s}").class.live_validations[method.to_sym] rescue false
          field_name = "#{object_name}_#{method}"
          initialize_validator(field_name) +
          validations.map do |type, configuration|
            live_validation_code(field_name, type, configuration)
          end.join(';')
        else
          ''
        end
      end
      
      def initialize_validator(field_name)
        "var #{field_name} = new LiveValidation('#{field_name}');".html_safe
      end
      
      def live_validation_code(field_name, type, configuration)
        ("#{field_name}.add(#{ActiveModel::Validations::VALIDATION_METHODS[type]}" + ( configuration ? ", #{configuration.to_json}" : '') + ')').html_safe
      end
      
      def script_tags(js_code = '')
         ( js_code.blank? ? '' : "<script>#{js_code}</script>".html_safe )
      end
    end
  end
end
