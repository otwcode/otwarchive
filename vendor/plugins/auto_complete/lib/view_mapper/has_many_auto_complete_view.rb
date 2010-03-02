module ViewMapper
  module HasManyAutoCompleteView

    def self.extended(base)
      base.extend(ViewMapper::HasManyChildModels)
    end

    def self.source_root
      File.expand_path(File.dirname(__FILE__) + "/templates")
    end

    def source_roots_for_view
      [
        HasManyAutoCompleteView.source_root,
        HasManyView.source_root,
        File.expand_path(source_root),
        File.expand_path(File.join(self.class.lookup('model').path, 'templates'))
      ]
    end

    def manifest
      m = super.edit do |action|
        action unless is_child_model_action?(action)
      end
      add_child_models_manifest(m)
      add_auto_complete_manifest(m)
      m
    end

    def add_auto_complete_manifest(m)
      if valid
        auto_complete_attributes.each do |attrib|
          add_auto_complete_route(m, attrib[:model_name], attrib[:text_field])
        end
      end
    end

    def add_auto_complete_route(manifest, model_name, text_field)
      manifest.route :name       => 'connect',
                     :path       => auto_complete_for_method(model_name, text_field),
                     :controller => controller_file_name,
                     :action     => auto_complete_for_method(model_name, text_field)
    end

    def auto_complete_for_method(model_name, text_field)
      "auto_complete_for_#{model_name}_#{text_field}"
    end

    def auto_complete_attributes
      @auto_complete_attributes = find_auto_complete_attributes
    end

    def find_auto_complete_attributes
      attribs = []
      if view_only?
        attribs << auto_complete_attributes_for_model(model)
      else
        attribs << auto_complete_attributes_from_command_line
      end
      attribs << child_models.collect { |child| auto_complete_attributes_for_model(child) }
      attribs.flatten
    end

    def auto_complete_attributes_for_model(model_info)
      model_info.text_fields.collect do |text_field|
        { :model_name => model_info.name.downcase, :text_field => text_field }
      end
    end

    def auto_complete_attributes_from_command_line
      attributes.reject do |cmd_line_attrib|
        !ViewMapper::ModelInfo.is_text_field_attrib_type? cmd_line_attrib.type
      end.collect do |cmd_line_attrib|
        { :model_name => singular_name, :text_field => cmd_line_attrib.name }
      end
    end

    def is_auto_complete_attribute?(model_name, text_field)
      !auto_complete_attributes.detect { |attrib| attrib[:model_name] == model_name && attrib[:text_field] == text_field }.nil?
    end

    def validate
      super
      @valid &&= validate_child_models
    end

  end
end
