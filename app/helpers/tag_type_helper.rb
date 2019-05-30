module TagTypeHelper

  # Tag Type labels e.g "Warnings", "Categories", "Fandoms"
  def tag_type_label_name(tag_type)
    if tag_type.underscore == 'archive_warning'
      ArchiveWarning.label_name
    else
      tag_type.humanize.titleize.pluralize
    end
  end
end
