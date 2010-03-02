module AutoCompleteFormBuilderHelper

  def class_name
    if @object
      "#{@object.class.to_s.underscore}"
    else
      "#{@object_name.to_s.underscore}"
    end
  end

  def sanitized_object_name
    @object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
  end

  def is_used_as_nested_attribute?
    /\[#{class_name.pluralize}_attributes\]\[[0-9]+\]/.match @object_name.to_s
  end
  
  def text_field_with_auto_complete(method, tag_options = {}, completion_options = {})
    if completion_options[:child_index]
      unique_object_name = "#{class_name}_#{completion_options[:child_index]}"
    elsif @options[:child_index]
      unique_object_name = "#{class_name}_#{@options[:child_index]}"
    elsif is_used_as_nested_attribute?
      unique_object_name = sanitized_object_name
    elsif !(@object_name.to_s =~ /\[\]$/)
      unique_object_name = sanitized_object_name
    else
      unique_object_name = "#{class_name}_#{Object.new.object_id.abs}"
    end
    completion_options_for_class_name = {
      :url => { :action => "auto_complete_for_#{class_name}_#{method}" },
      :param_name => "#{class_name}[#{method}]"
    }.update(completion_options)
    @template.auto_complete_field_with_style_and_script(unique_object_name,
                                                        method,
                                                        tag_options,
                                                        completion_options_for_class_name
                                                       ) do
      text_field(method, { :id => "#{unique_object_name}_#{method}" }.update(tag_options))
    end
  end

end
