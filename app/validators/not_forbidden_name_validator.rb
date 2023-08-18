class NotForbiddenNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    return unless ArchiveConfig.FORBIDDEN_USERNAMES.include?(value.downcase)

    record.errors.add(attribute, :forbidden, **options.merge(value: value))
  end
end
