class NotForbiddenNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    return unless ArchiveConfig.FORBIDDEN_USERNAMES.include?()
    ArchiveConfig.FORBIDDEN_USERNAMES.each do |forbidden|
      return error if bidi_confusable?(value.gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, ""), forbidden.gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, ""))
    end
    # i18n-tasks-use t("activerecord.errors.messages.forbidden")
    record.errors.add(attribute, :forbidden, **options.merge(value: value))
  end

  def internal_skeleton(string)
    string.unicode_normalize(:nfd).gsub(/\p{DI}/, "").each_codepoint.map do |codepoint|
      confusable(codepoint) || codepoint
    end
  end

  def bidi_skeleton(string)

  end

  def bidi_confusable?(string1, string2)
    bidi_skeleton(string1) == bidi_skeleton(string2)
  end
end

