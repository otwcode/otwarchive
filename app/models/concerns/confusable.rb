module Confusable
  extend ActiveSupport::Concern

  # This is stricter than the confusable Unicode defines, it's case-insensitive
  # and also includes dialectics, blank and punctuations.
  def confusable?(string1, string2)
    internal_skeleton(string1).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "").upcase ==
      internal_skeleton(string2).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "").upcase ||
      internal_skeleton(string1.upcase).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "").upcase ==
        internal_skeleton(string2.upcase).gsub(/\p{Dia}|\p{Blank}|\p{Punct}/, "").upcase
  end

  private

  # Internal skeleton that Unicode defines in Technical Standard #39
  #
  # Check the cache for confusables hashmap, if it doesn't exist create it by
  # processing each line, capturing the parts before and after the first ";",
  # pushing an array into array (since right part of the confusable can be
  # more than one codepoint) and finally converting to decimal integer from
  # hexadecimal string since that's easier to use in Ruby.
  #
  # Because the hashmap gives an array as the prototype for each source
  # character, join each of those arrays (or codepoint of source character if
  # it's not confusable) after converting them to a string. Also normalize
  # before and after as described by the standard.
  def internal_skeleton(string)
    confusable_pairs = Rails.cache.fetch("v1/confusables_hash") do
      File.foreach(Rails.root.join("config/confusables.txt"))
        .filter_map { it.match(/^(\h+)\s+;\s+([\h\s]+);\s*MA/) }
        .to_h { [it[1].to_i(16), it[2].scan(/\h+/).map { |x| x.to_i(16) }] }
    end

    string.unicode_normalize(:nfd).gsub(/\p{DI}/, "").each_codepoint.map do |codepoint|
      (confusable_pairs[codepoint] || [codepoint]).pack("U*")
    end.join.unicode_normalize(:nfd)
  end
end
