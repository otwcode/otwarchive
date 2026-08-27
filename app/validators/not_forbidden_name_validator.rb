class NotForbiddenNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    ArchiveConfig.FORBIDDEN_USERNAMES.each do |forbidden|
      if NotForbiddenNameValidator.confusable?(forbidden, value)
        # i18n-tasks-use t("activerecord.errors.messages.forbidden")
        return record.errors.add(attribute, :forbidden, **options.merge(value: value))
      end
    end
  end

  # Internal skeleton that Unicode defines in Technical Standard #39
  #
  # Check the cache for confusables hashmap, if it doesn't exist (for the first
  # time it works and when it's updated) create it by processing each line,
  # capturing the parts before and after the first ";", pushing an array into
  # array (since right part of the confusable can be more than one codepoint)
  # and finally converting to decimal integer from hexadecimal string since
  # that's easier to use in ruby
  #
  # Because the hashmap gives an array for each codepoint of the initial
  # string, join each of those arrays (or original codepoint if it's not
  # confusable) after converting them to a string. Also normalize before and
  # after as described by the standard.
  def self.internal_skeleton(string)
    confusable_pairs = Rails.cache.fetch("v1/confusables_hash") do
      File.foreach('./script/confusables.txt')
        .filter_map { it.match(/^(\h+)\s+;\s+([\h\s]+);\s*MA/)&.captures }
        .to_h { [_1.to_i(16), _2.scan(/\h+/).map { it.to_i(16) }] }
    end

    string.unicode_normalize(:nfd).gsub(/\p{DI}/, '').each_codepoint.map { |codepoint|
      (confusable_pairs[codepoint] || [codepoint]).pack('U*')
    }.join.unicode_normalize(:nfd)
  end

  # This is not the confusable Unicode defines, also makes it uppercase and
  # includes dialectics, blank and punctuations.
  # A problem with making it uppercase or lowercase after all that is "I" becomes "l" but "i" doesn't
  # Problem with making it uppercase before is "m" doesn't become "rn"
  # Problem with making it downcase before is "I" doesn't become "l"
  # Workaround I found is using it both after and before
  # TODO find another workaround
  def self.confusable?(string1, string2)
    internal_skeleton(string1).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "").upcase ==
      internal_skeleton(string2).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "").upcase ||
      internal_skeleton(string1.upcase).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "") ==
        internal_skeleton(string2.upcase).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "")
  end
end
