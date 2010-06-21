module Tolk
  module ApplicationHelper
    def format_i18n_value(value)
      h(yaml_value(value)).gsub(/\n/, '<br />')
    end

    def format_i18n_text_area_value(value)
      yaml_value(value)
    end

    def yaml_value(value)
      if value.present?
        unless value.is_a?(String)
          value = value.respond_to?(:ya2yaml) ? value.ya2yaml(:syck_compatible => true) : value.to_yaml
        end
      end
      
      value
    end


    def tolk_locale_selection
      existing_locale_names = Tolk::Locale.all.map(&:name)
      pairs = Tolk::Locale::MAPPING.to_a.map(&:reverse)
      pairs = pairs.sort_by(&:last)
      pairs.reject do |pair|
        existing_locale_names.include? pair.last
      end
    end
  end
end
