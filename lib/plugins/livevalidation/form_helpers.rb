[:text_field, :text_area, :password_field ].each do |field_type|
  ActiveSupport.class_eval <<RUBY
    module #{field_type.to_s.camelize}WithLiveValidations
      def #{field_type}(object_name, method, options)
        live = options.delete(:live)
        live = ActionView::live_validations if live.nil?
        send(super, object_name, method, options) +
          ( live ? live_validations_for(object_name, method) : '' )
      end
    end
RUBY
end

module ActionView

  mattr_accessor :live_validations
  ActionView::live_validations = true

  module Helpers
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

  [ 'TextField', 'TextArea', 'PasswordField' ].each do |field_type|
    Helpers.prepend "ActiveSupport::#{field_type}WithLiveValidations".constantize
  end
end
