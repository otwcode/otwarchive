# frozen_string_literal: true

# Custom validator to ensure that a field using ActiveStorage
# * matches the given formats, specified with regex or by a list (leave empty to allow any)
# * is less than the given maximum (if none is given, the default is 500kb)
class AttachmentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value&.attached?

    allowed_formats = options[:allowed_formats]
    maximum_size = options[:maximum_size] || 500.kilobytes

    case allowed_formats
    when Regexp
      record.errors.add(attribute, :invalid_format) unless allowed_formats.match?(value.content_type)
    when Array
      record.errors.add(attribute, :invalid_format) unless allowed_formats.include?(value.content_type)
    end

    record.errors.add(attribute, :too_large, maximum_size: maximum_size.to_fs(:human_size)) unless value.blob.byte_size < maximum_size

    value.purge if record.errors[attribute].any?
  end
end
