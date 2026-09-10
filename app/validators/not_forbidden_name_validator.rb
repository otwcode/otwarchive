class NotForbiddenNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    ArchiveConfig.FORBIDDEN_USERNAMES.each do |forbidden|
      if Confusable.confusable?(forbidden, value)
        # i18n-tasks-use t("activerecord.errors.messages.forbidden")
        return record.errors.add(attribute, :forbidden, **options.merge(value: value))
      end
    end
  end
end
