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
  def self.internal_skeleton(string)
    # TODO add comments since it's complicated
    # TODO also add docstrings to functions
    confusable_pairs = Rails.cache.fetch("confusables_hash") do
      File.open("./script/confusables.txt", "rb") do |f|
        confusable_pairs = {}
        f.each_line do |line|
          # Process each line, capture the part before and after the first ";" # NOTSURE if it is a line that contains confusable data.
          line =~ /^(\w*)\s;\s((?:\w*\s)*);\sMA\s/

          # pushing an array into array since right part of the confusable can be more than one codepoint
          # TODO maybe add an example and show what it becomes at each step
          # we're also converting to decimal integer from hexadecimal string since that's easier to use in ruby
          confusable_pairs[$1.to_i(16)] = $2.split(" ").map{ |x| x.to_i(16)} if $2.is_a?(String)
        end
        confusable_pairs
      end
    end

    # because this gives an array for each codepoint of the initial string, we
    # join each of those arrays (or original codepoint if it's not confusable)
    # after converting them to a string. We also normalize before and after as
    # described by the standard
    string.unicode_normalize(:nfd).gsub(/\p{DI}/, '').each_codepoint.map { |codepoint|
      (confusable_pairs[codepoint] || [codepoint]).pack('U*')
    }.join.unicode_normalize(:nfd)
  end

  # This is not the confusable Unicode defines, also makes it uppercase and
  # includes dialectics, blank and punctuations.
  # A problem with making it uppercase after all that is "I" becomes "l" but "i" doesn't
  # Problem with making it uppercase before is "m" doesn't become "rn"
  # Workaround I found is using it both after and before
  # TODO find another workaround
  def self.confusable?(string1, string2)
    internal_skeleton(string1).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "").upcase ==
      internal_skeleton(string2).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "").upcase ||
      internal_skeleton(string1.upcase).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "") ==
        internal_skeleton(string2.upcase).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "")
  end
end

