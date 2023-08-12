class NotForbiddenNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    return unless ArchiveConfig.FORBIDDEN_USERNAMES.include?(value.downcase)

    record.errors.add(attribute, options[:message] || I18n.t("validators.forbidden_name", value: value))
  end
end
