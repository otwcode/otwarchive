class NotForbiddenNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    ArchiveConfig.FORBIDDEN_USERNAMES.each do |forbidden|
      # i18n-tasks-use t("activerecord.errors.messages.forbidden")
      return record.errors.add(attribute, :forbidden, **options.merge(value: value)) if self.confusable?(forbidden, value)
    end
  end

  # the confusable that unicode defines in 39
  def self.internal_skeleton(string)
    # TODO add comments since it's complicated
    # TODO also add docstrings to functions
    confusable_pairs = Rails.cache.fetch("confusables_hash") do
      File.open("./script/confusables.txt", "rb") do |f|
        confusable_pairs = {}
        f.each_line do |line|
          line =~ /^(\w*)\s;\s((?:\w*\s)*);\sMA\s/

          # pushing an array into array since right part of the confusable can be more than one codepoint
          # TODO maybe add an example and show what it becomes at each step
          # we're also converting to decimal from hexadecimal since that's easier to use in ruby
          confusable_pairs[$1.to_i(16)] = $2.split(" ").map{ |x| x.to_i(16)} if $2.is_a?(String)
        end
        confusable_pairs
      end
    end

    # TODO maaybe find a way to not using this array or simplifying it
    final_arr = Array.new
    string.unicode_normalize(:nfd).gsub(/\p{DI}/, "").each_codepoint.map do |codepoint|
      (confusable_pairs[codepoint] || [codepoint]).each do |integer_codepoint|
        final_arr.push([integer_codepoint.to_s(16).hex].pack("U"))
      end
    end

    # convert to string characters and add that to a new array
    # flattening is because the array can have an array as an element
    # finally, normalize as described by the standard
    final_arr.join.unicode_normalize(:nfd)
  end

  # not the confusable Unicode defines, also makes it uppercase and includes dialectics, blank and punctuations
  def self.confusable?(string1, string2)
    internal_skeleton(string1).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "").upcase ==
      internal_skeleton(string2).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "").upcase
  end
end

