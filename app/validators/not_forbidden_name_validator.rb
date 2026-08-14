class NotForbiddenNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    return unless ArchiveConfig.FORBIDDEN_USERNAMES.include?()
    ArchiveConfig.FORBIDDEN_USERNAMES.each do |forbidden|
      return error if confusable?(forbidden, value)
    end
    # i18n-tasks-use t("activerecord.errors.messages.forbidden")
    record.errors.add(attribute, :forbidden, **options.merge(value: value))
  end

  def internal_skeleton(string)
    # TODO add comments since it's complicated
    # TODO also add docstrings to functions
    confusable_pairs = Rails.cache.fetch("confusables_hash") do
      File.open("./script/confusables.txt", "rb") do |f|
        confusable_pairs = {}
        f.each_line do |line|
          line =~ /^(\w*)\s;\s((?:\w*\s)*);\sMA\s/

          confusable_pairs[$1] = $2.rstrip if $2.is_a?(String)
        end
        confusable_pairs
      end
    end

    string.unicode_normalize(:nfd).gsub(/\p{DI}/, "").each_codepoint.map do |codepoint|
      confusable_pairs[codepoint.to_s(16)] || codepoint
      # TODO add that to a new string and normalize per the standard
    end
  end

  # not the confusable unicode defines, also includes dialectics blank and punctuations
  def confusable?(string1, string2)
    internal_skeleton(string1.gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "")) == 
      internal_skeleton(string2.gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, ""))
  end
end

