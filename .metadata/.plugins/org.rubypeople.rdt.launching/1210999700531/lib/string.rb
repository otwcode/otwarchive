=begin
---------------------------------------------------------- Class: String
     A +String+ object holds and manipulates an arbitrary sequence of
     bytes, typically representing characters. String objects may be
     created using +String::new+ or as literals.

     Because of aliasing issues, users of strings should be aware of the
     methods that modify the contents of a +String+ object. Typically,
     methods with names ending in ``!'' modify their receiver, while
     those without a ``!'' return a new +String+. However, there are
     exceptions, such as +String#[]=+.

------------------------------------------------------------------------
     Enhance the String class with a XML escaped character version of
     to_s.

------------------------------------------------------------------------
     User defined methods to be added to String.

------------------------------------------------------------------------


Includes:
---------
     Comparable(<, <=, ==, >, >=, between?), Enumerable(all?, any?,
     collect, detect, each_cons, each_slice, each_with_index, entries,
     enum_cons, enum_slice, enum_with_index, find, find_all, grep,
     group_by, include?, index_by, inject, map, max, member?, min,
     partition, reject, select, sort, sort_by, sum, to_a, to_set, zip)


Constants:
----------
     DeletePatternCache:  {}
     HashCache:           {}
     PATTERN_EUC:         '[\xa1-\xfe][\xa1-\xfe]'
     PATTERN_SJIS:        '[\x81-\x9f\xe0-\xef][\x40-\x7e\x80-\xfc]'
     PATTERN_UTF8:        '[\xc0-\xdf][\x80-\xbf]|[\xe0-\xef][\x80-\xbf]
                          [\x80-\xbf]'
     RE_EUC:              Regexp.new(PATTERN_EUC, 0, 'n')
     RE_SJIS:             Regexp.new(PATTERN_SJIS, 0, 'n')
     RE_UTF8:             Regexp.new(PATTERN_UTF8, 0, 'n')
     SUCC:                {}
     SqueezePatternCache: {}
     TrPatternCache:      {}


Class methods:
--------------
     new, yaml_new


Instance methods:
-----------------
     %, *, +, <<, <=>, ==, =~, [], []=, _expand_ch, _regex_quote,
     block_scanf, capitalize, capitalize!, casecmp, center, chomp,
     chomp!, chop, chop!, concat, count, crypt, delete, delete!,
     downcase, downcase!, dump, each, each_byte, each_char, each_line,
     empty?, end_regexp, eql?, expand_ch_hash, ext, gsub, gsub!, hash,
     hex, include?, index, initialize_copy, insert, inspect, intern,
     is_binary_data?, is_complex_yaml?, iseuc, issjis, isutf8, jcount,
     jlength, jsize, kconv, length, ljust, lstrip, lstrip!, match,
     mbchar?, next, next!, nstrip, oct, original_succ, original_succ!,
     pathmap, pathmap_explode, pathmap_partial, pathmap_replace, quote,
     replace, reverse, reverse!, rindex, rjust, rstrip, rstrip!, scan,
     scanf, size, slice, slice!, split, squeeze, squeeze!, strip,
     strip!, sub, sub!, succ, succ!, sum, swapcase, swapcase!, to_blob,
     to_f, to_i, to_s, to_str, to_sym, to_yaml, toeuc, tojis, tosjis,
     toutf16, toutf8, tr, tr!, tr_s, tr_s!, unpack, upcase, upcase!,
     upto

=end
class String < Object
  include Enumerable
  include Comparable

  # ------------------------------------------------------- String::yaml_new
  #      String::yaml_new( klass, tag, val )
  # ------------------------------------------------------------------------
  #      (no description...)
  def self.yaml_new(arg0, arg1, arg2)
  end

  def self.yaml_tag_subclasses?
  end

  # ----------------------------------------------------------- String#split
  #      str.split(pattern=$;, [limit])   => anArray
  # ------------------------------------------------------------------------
  #      Divides _str_ into substrings based on a delimiter, returning an
  #      array of these substrings.
  # 
  #      If _pattern_ is a +String+, then its contents are used as the
  #      delimiter when splitting _str_. If _pattern_ is a single space,
  #      _str_ is split on whitespace, with leading whitespace and runs of
  #      contiguous whitespace characters ignored.
  # 
  #      If _pattern_ is a +Regexp+, _str_ is divided where the pattern
  #      matches. Whenever the pattern matches a zero-length string, _str_
  #      is split into individual characters.
  # 
  #      If _pattern_ is omitted, the value of +$;+ is used. If +$;+ is
  #      +nil+ (which is the default), _str_ is split on whitespace as if `
  #      ' were specified.
  # 
  #      If the _limit_ parameter is omitted, trailing null fields are
  #      suppressed. If _limit_ is a positive number, at most that number of
  #      fields will be returned (if _limit_ is +1+, the entire string is
  #      returned as the only entry in an array). If negative, there is no
  #      limit to the number of fields returned, and trailing null fields
  #      are not suppressed.
  # 
  #         " now's  the time".split        #=> ["now's", "the", "time"]
  #         " now's  the time".split(' ')   #=> ["now's", "the", "time"]
  #         " now's  the time".split(/ /)   #=> ["", "now's", "", "the", "time"]
  #         "1, 2.34,56, 7".split(%r{,\s*}) #=> ["1", "2.34", "56", "7"]
  #         "hello".split(//)               #=> ["h", "e", "l", "l", "o"]
  #         "hello".split(//, 3)            #=> ["h", "e", "llo"]
  #         "hi mom".split(%r{\s*})         #=> ["h", "i", "m", "o", "m"]
  #      
  #         "mellow yellow".split("ello")   #=> ["m", "w y", "w"]
  #         "1,2,,3,4,,".split(',')         #=> ["1", "2", "", "3", "4"]
  #         "1,2,,3,4,,".split(',', 4)      #=> ["1", "2", "", "3,4,,"]
  #         "1,2,,3,4,,".split(',', -4)     #=> ["1", "2", "", "3", "4", "", ""]
  # 
  def split(arg0, arg1, *rest)
  end

  # --------------------------------------------------------- String#rstrip!
  #      str.rstrip!   => self or nil
  # ------------------------------------------------------------------------
  #      Removes trailing whitespace from _str_, returning +nil+ if no
  #      change was made. See also +String#lstrip!+ and +String#strip!+.
  # 
  #         "  hello  ".rstrip   #=> "  hello"
  #         "hello".rstrip!      #=> nil
  # 
  def rstrip!
  end

  # ---------------------------------------------------------- String#to_sym
  #      str.intern   => symbol
  #      str.to_sym   => symbol
  # ------------------------------------------------------------------------
  #      Returns the +Symbol+ corresponding to _str_, creating the symbol if
  #      it did not previously exist. See +Symbol#id2name+.
  # 
  #         "Koala".intern         #=> :Koala
  #         s = 'cat'.to_sym       #=> :cat
  #         s == :cat              #=> true
  #         s = '@cat'.to_sym      #=> :@cat
  #         s == :@cat             #=> true
  # 
  #      This can also be used to create symbols that cannot be represented
  #      using the +:xxx+ notation.
  # 
  #         'cat and dog'.to_sym   #=> :"cat and dog"
  # 
  def to_sym
  end

  # -------------------------------------------------------- String#swapcase
  #      str.swapcase   => new_str
  # ------------------------------------------------------------------------
  #      Returns a copy of _str_ with uppercase alphabetic characters
  #      converted to lowercase and lowercase characters converted to
  #      uppercase.
  # 
  #         "Hello".swapcase          #=> "hELLO"
  #         "cYbEr_PuNk11".swapcase   #=> "CyBeR_pUnK11"
  # 
  def swapcase
  end

  # ------------------------------------------------------------ String#chop
  #      str.chop   => new_str
  # ------------------------------------------------------------------------
  #      Returns a new +String+ with the last character removed. If the
  #      string ends with +\r\n+, both characters are removed. Applying
  #      +chop+ to an empty string returns an empty string. +String#chomp+
  #      is often a safer alternative, as it leaves the string unchanged if
  #      it doesn't end in a record separator.
  # 
  #         "string\r\n".chop   #=> "string"
  #         "string\n\r".chop   #=> "string\n"
  #         "string\n".chop     #=> "string"
  #         "string".chop       #=> "strin"
  #         "x".chop.chop       #=> ""
  # 
  def chop
  end

  # ---------------------------------------------------------- String#empty?
  #      str.empty?   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _str_ has a length of zero.
  # 
  #         "hello".empty?   #=> false
  #         "".empty?        #=> true
  # 
  def empty?
  end

  # ------------------------------------------------------- String#swapcase!
  #      str.swapcase!   => str or nil
  # ------------------------------------------------------------------------
  #      Equivalent to +String#swapcase+, but modifies the receiver in
  #      place, returning _str_, or +nil+ if no changes were made.
  # 
  def swapcase!
  end

  # ------------------------------------------------------------ String#to_f
  #      str.to_f   => float
  # ------------------------------------------------------------------------
  #      Returns the result of interpreting leading characters in _str_ as a
  #      floating point number. Extraneous characters past the end of a
  #      valid number are ignored. If there is not a valid number at the
  #      start of _str_, +0.0+ is returned. This method never raises an
  #      exception.
  # 
  #         "123.45e1".to_f        #=> 1234.5
  #         "45.67 degrees".to_f   #=> 45.67
  #         "thx1138".to_f         #=> 0.0
  # 
  def to_f
  end

  # --------------------------------------------------------- String#casecmp
  #      str.casecmp(other_str)   => -1, 0, +1
  # ------------------------------------------------------------------------
  #      Case-insensitive version of +String#<=>+.
  # 
  #         "abcdef".casecmp("abcde")     #=> 1
  #         "aBcDeF".casecmp("abcdef")    #=> 0
  #         "abcdef".casecmp("abcdefg")   #=> -1
  #         "abcdef".casecmp("ABCDEF")    #=> 0
  # 
  def casecmp(arg0)
  end

  # ---------------------------------------------------------- String#rindex
  #      str.rindex(substring [, fixnum])   => fixnum or nil
  #      str.rindex(fixnum [, fixnum])   => fixnum or nil
  #      str.rindex(regexp [, fixnum])   => fixnum or nil
  # ------------------------------------------------------------------------
  #      Returns the index of the last occurrence of the given _substring_,
  #      character (_fixnum_), or pattern (_regexp_) in _str_. Returns +nil+
  #      if not found. If the second parameter is present, it specifies the
  #      position in the string to end the search---characters beyond this
  #      point will not be considered.
  # 
  #         "hello".rindex('e')             #=> 1
  #         "hello".rindex('l')             #=> 3
  #         "hello".rindex('a')             #=> nil
  #         "hello".rindex(101)             #=> 1
  #         "hello".rindex(/[aeiou]/, -2)   #=> 1
  # 
  def rindex(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- String#intern
  #      str.intern   => symbol
  #      str.to_sym   => symbol
  # ------------------------------------------------------------------------
  #      Returns the +Symbol+ corresponding to _str_, creating the symbol if
  #      it did not previously exist. See +Symbol#id2name+.
  # 
  #         "Koala".intern         #=> :Koala
  #         s = 'cat'.to_sym       #=> :cat
  #         s == :cat              #=> true
  #         s = '@cat'.to_sym      #=> :@cat
  #         s == :@cat             #=> true
  # 
  #      This can also be used to create symbols that cannot be represented
  #      using the +:xxx+ notation.
  # 
  #         'cat and dog'.to_sym   #=> :"cat and dog"
  # 
  def intern
  end

  # -------------------------------------------------------------- String#tr
  #      tr(from, to)
  # ------------------------------------------------------------------------
  #      (no description...)
  def tr(arg0, arg1)
  end

  # ------------------------------------------------------------ String#to_s
  #      str.to_s     => str
  #      str.to_str   => str
  # ------------------------------------------------------------------------
  #      Returns the receiver.
  # 
  def to_s
  end

  # -------------------------------------------------------- String#reverse!
  #      str.reverse!   => str
  # ------------------------------------------------------------------------
  #      Reverses _str_ in place.
  # 
  def reverse!
  end

  # ---------------------------------------------------------- String#strip!
  #      str.strip!   => str or nil
  # ------------------------------------------------------------------------
  #      Removes leading and trailing whitespace from _str_. Returns +nil+
  #      if _str_ was not altered.
  # 
  def strip!
  end

  # ----------------------------------------------------------- String#match
  #      str.match(pattern)   => matchdata or nil
  # ------------------------------------------------------------------------
  #      Converts _pattern_ to a +Regexp+ (if it isn't already one), then
  #      invokes its +match+ method on _str_.
  # 
  #         'hello'.match('(.)\1')      #=> #<MatchData:0x401b3d30>
  #         'hello'.match('(.)\1')[0]   #=> "ll"
  #         'hello'.match(/(.)\1/)[0]   #=> "ll"
  #         'hello'.match('xx')         #=> nil
  # 
  def match(arg0)
  end

  # ---------------------------------------------------------- String#unpack
  #      str.unpack(format)   => anArray
  # ------------------------------------------------------------------------
  #      Decodes _str_ (which may contain binary data) according to the
  #      format string, returning an array of each value extracted. The
  #      format string consists of a sequence of single-character
  #      directives, summarized in the table at the end of this entry. Each
  #      directive may be followed by a number, indicating the number of
  #      times to repeat with this directive. An asterisk (``+*+'') will use
  #      up all remaining elements. The directives +sSiIlL+ may each be
  #      followed by an underscore (``+_+'') to use the underlying
  #      platform's native size for the specified type; otherwise, it uses a
  #      platform-independent consistent size. Spaces are ignored in the
  #      format string. See also +Array#pack+.
  # 
  #         "abc \0\0abc \0\0".unpack('A6Z6')   #=> ["abc", "abc "]
  #         "abc \0\0".unpack('a3a3')           #=> ["abc", " \000\000"]
  #         "abc \0abc \0".unpack('Z*Z*')       #=> ["abc ", "abc "]
  #         "aa".unpack('b8B8')                 #=> ["10000110", "01100001"]
  #         "aaa".unpack('h2H2c')               #=> ["16", "61", 97]
  #         "\xfe\xff\xfe\xff".unpack('sS')     #=> [-2, 65534]
  #         "now=20is".unpack('M*')             #=> ["now is"]
  #         "whole".unpack('xax2aX2aX1aX2a')    #=> ["h", "e", "l", "l", "o"]
  # 
  #      This table summarizes the various formats and the Ruby classes
  #      returned by each.
  # 
  #         Format | Returns | Function
  #         -------+---------+-----------------------------------------
  #           A    | String  | with trailing nulls and spaces removed
  #         -------+---------+-----------------------------------------
  #           a    | String  | string
  #         -------+---------+-----------------------------------------
  #           B    | String  | extract bits from each character (msb first)
  #         -------+---------+-----------------------------------------
  #           b    | String  | extract bits from each character (lsb first)
  #         -------+---------+-----------------------------------------
  #           C    | Fixnum  | extract a character as an unsigned integer
  #         -------+---------+-----------------------------------------
  #           c    | Fixnum  | extract a character as an integer
  #         -------+---------+-----------------------------------------
  #           d,D  | Float   | treat sizeof(double) characters as
  #                |         | a native double
  #         -------+---------+-----------------------------------------
  #           E    | Float   | treat sizeof(double) characters as
  #                |         | a double in little-endian byte order
  #         -------+---------+-----------------------------------------
  #           e    | Float   | treat sizeof(float) characters as
  #                |         | a float in little-endian byte order
  #         -------+---------+-----------------------------------------
  #           f,F  | Float   | treat sizeof(float) characters as
  #                |         | a native float
  #         -------+---------+-----------------------------------------
  #           G    | Float   | treat sizeof(double) characters as
  #                |         | a double in network byte order
  #         -------+---------+-----------------------------------------
  #           g    | Float   | treat sizeof(float) characters as a
  #                |         | float in network byte order
  #         -------+---------+-----------------------------------------
  #           H    | String  | extract hex nibbles from each character
  #                |         | (most significant first)
  #         -------+---------+-----------------------------------------
  #           h    | String  | extract hex nibbles from each character
  #                |         | (least significant first)
  #         -------+---------+-----------------------------------------
  #           I    | Integer | treat sizeof(int) (modified by _)
  #                |         | successive characters as an unsigned
  #                |         | native integer
  #         -------+---------+-----------------------------------------
  #           i    | Integer | treat sizeof(int) (modified by _)
  #                |         | successive characters as a signed
  #                |         | native integer
  #         -------+---------+-----------------------------------------
  #           L    | Integer | treat four (modified by _) successive
  #                |         | characters as an unsigned native
  #                |         | long integer
  #         -------+---------+-----------------------------------------
  #           l    | Integer | treat four (modified by _) successive
  #                |         | characters as a signed native
  #                |         | long integer
  #         -------+---------+-----------------------------------------
  #           M    | String  | quoted-printable
  #         -------+---------+-----------------------------------------
  #           m    | String  | base64-encoded
  #         -------+---------+-----------------------------------------
  #           N    | Integer | treat four characters as an unsigned
  #                |         | long in network byte order
  #         -------+---------+-----------------------------------------
  #           n    | Fixnum  | treat two characters as an unsigned
  #                |         | short in network byte order
  #         -------+---------+-----------------------------------------
  #           P    | String  | treat sizeof(char *) characters as a
  #                |         | pointer, and  return \emph{len} characters
  #                |         | from the referenced location
  #         -------+---------+-----------------------------------------
  #           p    | String  | treat sizeof(char *) characters as a
  #                |         | pointer to a  null-terminated string
  #         -------+---------+-----------------------------------------
  #           Q    | Integer | treat 8 characters as an unsigned
  #                |         | quad word (64 bits)
  #         -------+---------+-----------------------------------------
  #           q    | Integer | treat 8 characters as a signed
  #                |         | quad word (64 bits)
  #         -------+---------+-----------------------------------------
  #           S    | Fixnum  | treat two (different if _ used)
  #                |         | successive characters as an unsigned
  #                |         | short in native byte order
  #         -------+---------+-----------------------------------------
  #           s    | Fixnum  | Treat two (different if _ used)
  #                |         | successive characters as a signed short
  #                |         | in native byte order
  #         -------+---------+-----------------------------------------
  #           U    | Integer | UTF-8 characters as unsigned integers
  #         -------+---------+-----------------------------------------
  #           u    | String  | UU-encoded
  #         -------+---------+-----------------------------------------
  #           V    | Fixnum  | treat four characters as an unsigned
  #                |         | long in little-endian byte order
  #         -------+---------+-----------------------------------------
  #           v    | Fixnum  | treat two characters as an unsigned
  #                |         | short in little-endian byte order
  #         -------+---------+-----------------------------------------
  #           w    | Integer | BER-compressed integer (see Array.pack)
  #         -------+---------+-----------------------------------------
  #           X    | ---     | skip backward one character
  #         -------+---------+-----------------------------------------
  #           x    | ---     | skip forward one character
  #         -------+---------+-----------------------------------------
  #           Z    | String  | with trailing nulls removed
  #                |         | upto first null with *
  #         -------+---------+-----------------------------------------
  #           @    | ---     | skip to the offset given by the
  #                |         | length argument
  #         -------+---------+-----------------------------------------
  # 
  def unpack(arg0)
  end

  # ------------------------------------------------------------- String#hex
  #      str.hex   => integer
  # ------------------------------------------------------------------------
  #      Treats leading characters from _str_ as a string of hexadecimal
  #      digits (with an optional sign and an optional +0x+) and returns the
  #      corresponding number. Zero is returned on error.
  # 
  #         "0x0a".hex     #=> 10
  #         "-1234".hex    #=> -4660
  #         "0".hex        #=> 0
  #         "wombat".hex   #=> 0
  # 
  def hex
  end

  # ------------------------------------------------------------ String#each
  #      str.each(separator=$/) {|substr| block }        => str
  #      str.each_line(separator=$/) {|substr| block }   => str
  # ------------------------------------------------------------------------
  #      Splits _str_ using the supplied parameter as the record separator
  #      (+$/+ by default), passing each substring in turn to the supplied
  #      block. If a zero-length record separator is supplied, the string is
  #      split on +\n+ characters, except that multiple successive newlines
  #      are appended together.
  # 
  #         print "Example one\n"
  #         "hello\nworld".each {|s| p s}
  #         print "Example two\n"
  #         "hello\nworld".each('l') {|s| p s}
  #         print "Example three\n"
  #         "hello\n\n\nworld".each('') {|s| p s}
  # 
  #      _produces:_
  # 
  #         Example one
  #         "hello\n"
  #         "world"
  #         Example two
  #         "hel"
  #         "l"
  #         "o\nworl"
  #         "d"
  #         Example three
  #         "hello\n\n\n"
  #         "world"
  # 
  def each(arg0, arg1, *rest)
  end

  # -------------------------------------------------------- String#include?
  #      str.include? other_str   => true or false
  #      str.include? fixnum      => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _str_ contains the given string or character.
  # 
  #         "hello".include? "lo"   #=> true
  #         "hello".include? "ol"   #=> false
  #         "hello".include? ?h     #=> true
  # 
  def include?(arg0)
  end

  # ----------------------------------------------------------- String#slice
  #      str[fixnum]                 => fixnum or nil
  #      str[fixnum, fixnum]         => new_str or nil
  #      str[range]                  => new_str or nil
  #      str[regexp]                 => new_str or nil
  #      str[regexp, fixnum]         => new_str or nil
  #      str[other_str]              => new_str or nil
  #      str.slice(fixnum)           => fixnum or nil
  #      str.slice(fixnum, fixnum)   => new_str or nil
  #      str.slice(range)            => new_str or nil
  #      str.slice(regexp)           => new_str or nil
  #      str.slice(regexp, fixnum)   => new_str or nil
  #      str.slice(other_str)        => new_str or nil
  # ------------------------------------------------------------------------
  #      Element Reference---If passed a single +Fixnum+, returns the code
  #      of the character at that position. If passed two +Fixnum+ objects,
  #      returns a substring starting at the offset given by the first, and
  #      a length given by the second. If given a range, a substring
  #      containing characters at offsets given by the range is returned. In
  #      all three cases, if an offset is negative, it is counted from the
  #      end of _str_. Returns +nil+ if the initial offset falls outside the
  #      string, the length is negative, or the beginning of the range is
  #      greater than the end.
  # 
  #      If a +Regexp+ is supplied, the matching portion of _str_ is
  #      returned. If a numeric parameter follows the regular expression,
  #      that component of the +MatchData+ is returned instead. If a
  #      +String+ is given, that string is returned if it occurs in _str_.
  #      In both cases, +nil+ is returned if there is no match.
  # 
  #         a = "hello there"
  #         a[1]                   #=> 101
  #         a[1,3]                 #=> "ell"
  #         a[1..3]                #=> "ell"
  #         a[-3,2]                #=> "er"
  #         a[-4..-2]              #=> "her"
  #         a[12..-1]              #=> nil
  #         a[-2..-4]              #=> ""
  #         a[/[aeiou](.)\1/]      #=> "ell"
  #         a[/[aeiou](.)\1/, 0]   #=> "ell"
  #         a[/[aeiou](.)\1/, 1]   #=> "l"
  #         a[/[aeiou](.)\1/, 2]   #=> nil
  #         a["lo"]                #=> "lo"
  #         a["bye"]               #=> nil
  # 
  def slice(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- String#next!
  #      str.succ!   => str
  #      str.next!   => str
  # ------------------------------------------------------------------------
  #      Equivalent to +String#succ+, but modifies the receiver in place.
  # 
  def next!
  end

  # ------------------------------------------------ String#is_complex_yaml?
  #      is_complex_yaml?()
  # ------------------------------------------------------------------------
  #      (no description...)
  def is_complex_yaml?
  end

  # --------------------------------------------------------------- String#*
  #      str * integer   => new_str
  # ------------------------------------------------------------------------
  #      Copy---Returns a new +String+ containing _integer_ copies of the
  #      receiver.
  # 
  #         "Ho! " * 3   #=> "Ho! Ho! Ho! "
  # 
  def *(arg0)
  end

  # ------------------------------------------------------- String#downcase!
  #      str.downcase!   => str or nil
  # ------------------------------------------------------------------------
  #      Downcases the contents of _str_, returning +nil+ if no changes were
  #      made.
  # 
  def downcase!
  end

  # -------------------------------------------------------- String#downcase
  #      str.downcase   => new_str
  # ------------------------------------------------------------------------
  #      Returns a copy of _str_ with all uppercase letters replaced with
  #      their lowercase counterparts. The operation is locale
  #      insensitive---only characters ``A'' to ``Z'' are affected.
  # 
  #         "hEllO".downcase   #=> "hello"
  # 
  def downcase
  end

  # ------------------------------------------------------------- String#sub
  #      str.sub(pattern, replacement)         => new_str
  #      str.sub(pattern) {|match| block }     => new_str
  # ------------------------------------------------------------------------
  #      Returns a copy of _str_ with the _first_ occurrence of _pattern_
  #      replaced with either _replacement_ or the value of the block. The
  #      _pattern_ will typically be a +Regexp+; if it is a +String+ then no
  #      regular expression metacharacters will be interpreted (that is
  #      +/\d/+ will match a digit, but +'\d'+ will match a backslash
  #      followed by a 'd').
  # 
  #      If the method call specifies _replacement_, special variables such
  #      as +$&+ will not be useful, as substitution into the string occurs
  #      before the pattern match starts. However, the sequences +\1+, +\2+,
  #      etc., may be used.
  # 
  #      In the block form, the current match string is passed in as a
  #      parameter, and variables such as +$1+, +$2+, +$`+, +$&+, and +$'+
  #      will be set appropriately. The value returned by the block will be
  #      substituted for the match on each call.
  # 
  #      The result inherits any tainting in the original string or any
  #      supplied replacement string.
  # 
  #         "hello".sub(/[aeiou]/, '*')               #=> "h*llo"
  #         "hello".sub(/([aeiou])/, '<\1>')          #=> "h<e>llo"
  #         "hello".sub(/./) {|s| s[0].to_s + ' ' }   #=> "104 ello"
  # 
  def sub(arg0, arg1, *rest)
  end

  # --------------------------------------------------------------- String#+
  #      str + other_str   => new_str
  # ------------------------------------------------------------------------
  #      Concatenation---Returns a new +String+ containing _other_str_
  #      concatenated to _str_.
  # 
  #         "Hello from " + self.to_s   #=> "Hello from main"
  # 
  def +(arg0)
  end

  # -------------------------------------------------------------- String#=~
  #      str =~ obj   => fixnum or nil
  # ------------------------------------------------------------------------
  #      Match---If _obj_ is a +Regexp+, use it as a pattern to match
  #      against _str_,and returns the position the match starts, or +nil+
  #      if there is no match. Otherwise, invokes _obj.=~_, passing _str_ as
  #      an argument. The default +=~+ in +Object+ returns +false+.
  # 
  #         "cat o' 9 tails" =~ /\d/   #=> 7
  #         "cat o' 9 tails" =~ 9      #=> false
  # 
  def =~(arg0)
  end

  # ------------------------------------------------------------ String#upto
  #      str.upto(other_str) {|s| block }   => str
  # ------------------------------------------------------------------------
  #      Iterates through successive values, starting at _str_ and ending at
  #      _other_str_ inclusive, passing each value in turn to the block. The
  #      +String#succ+ method is used to generate each value.
  # 
  #         "a8".upto("b6") {|s| print s, ' ' }
  #         for s in "a8".."b6"
  #           print s, ' '
  #         end
  # 
  #      _produces:_
  # 
  #         a8 a9 b0 b1 b2 b3 b4 b5 b6
  #         a8 a9 b0 b1 b2 b3 b4 b5 b6
  # 
  def upto(arg0)
  end

  # ---------------------------------------------------------- String#concat
  #      str << fixnum        => str
  #      str.concat(fixnum)   => str
  #      str << obj           => str
  #      str.concat(obj)      => str
  # ------------------------------------------------------------------------
  #      Append---Concatenates the given object to _str_. If the object is a
  #      +Fixnum+ between 0 and 255, it is converted to a character before
  #      concatenation.
  # 
  #         a = "hello "
  #         a << "world"   #=> "hello world"
  #         a.concat(33)   #=> "hello world!"
  # 
  def concat(arg0)
  end

  # ---------------------------------------------------------- String#lstrip
  #      str.lstrip   => new_str
  # ------------------------------------------------------------------------
  #      Returns a copy of _str_ with leading whitespace removed. See also
  #      +String#rstrip+ and +String#strip+.
  # 
  #         "  hello  ".lstrip   #=> "hello  "
  #         "hello".lstrip       #=> "hello"
  # 
  def lstrip
  end

  # ------------------------------------------------------- String#each_byte
  #      str.each_byte {|fixnum| block }    => str
  # ------------------------------------------------------------------------
  #      Passes each byte in _str_ to the given block.
  # 
  #         "hello".each_byte {|c| print c, ' ' }
  # 
  #      _produces:_
  # 
  #         104 101 108 108 111
  # 
  def each_byte
  end

  # ----------------------------------------------------------- String#succ!
  #      str.succ!   => str
  #      str.next!   => str
  # ------------------------------------------------------------------------
  #      Equivalent to +String#succ+, but modifies the receiver in place.
  # 
  # 
  #      (also known as original_succ!)
  def succ!
  end

  # ----------------------------------------------------------- String#chop!
  #      chop!()
  # ------------------------------------------------------------------------
  #      (no description...)
  def chop!
  end

  # ------------------------------------------------------------ String#size
  #      str.length   => integer
  # ------------------------------------------------------------------------
  #      Returns the length of _str_.
  # 
  def size
  end

  def taguri
  end

  # ------------------------------------------------------------ String#dump
  #      str.dump   => new_str
  # ------------------------------------------------------------------------
  #      Produces a version of _str_ with all nonprinting characters
  #      replaced by +\nnn+ notation and all special characters escaped.
  # 
  def dump
  end

  # ----------------------------------------------------------- String#rjust
  #      str.rjust(integer, padstr=' ')   => new_str
  # ------------------------------------------------------------------------
  #      If _integer_ is greater than the length of _str_, returns a new
  #      +String+ of length _integer_ with _str_ right justified and padded
  #      with _padstr_; otherwise, returns _str_.
  # 
  #         "hello".rjust(4)            #=> "hello"
  #         "hello".rjust(20)           #=> "               hello"
  #         "hello".rjust(20, '1234')   #=> "123412341234123hello"
  # 
  def rjust(arg0, arg1, *rest)
  end

  # --------------------------------------------------------- String#squeeze
  #      str.squeeze([other_str]*)    => new_str
  # ------------------------------------------------------------------------
  #      Builds a set of characters from the _other_str_ parameter(s) using
  #      the procedure described for +String#count+. Returns a new string
  #      where runs of the same character that occur in this set are
  #      replaced by a single character. If no arguments are given, all runs
  #      of identical characters are replaced by a single character.
  # 
  #         "yellow moon".squeeze                  #=> "yelow mon"
  #         "  now   is  the".squeeze(" ")         #=> " now is the"
  #         "putters shoot balls".squeeze("m-z")   #=> "puters shot balls"
  # 
  def squeeze(arg0, arg1, *rest)
  end

  # --------------------------------------------------------- String#delete!
  #      str.delete!([other_str]+>)   => str or nil
  # ------------------------------------------------------------------------
  #      Performs a +delete+ operation in place, returning _str_, or +nil+
  #      if _str_ was not modified.
  # 
  def delete!(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ String#eql?
  #      str.eql?(other)   => true or false
  # ------------------------------------------------------------------------
  #      Two strings are equal if the have the same length and content.
  # 
  def eql?(arg0)
  end

  # ------------------------------------------------------------ String#next
  #      str.succ   => new_str
  #      str.next   => new_str
  # ------------------------------------------------------------------------
  #      Returns the successor to _str_. The successor is calculated by
  #      incrementing characters starting from the rightmost alphanumeric
  #      (or the rightmost character if there are no alphanumerics) in the
  #      string. Incrementing a digit always results in another digit, and
  #      incrementing a letter results in another letter of the same case.
  #      Incrementing nonalphanumerics uses the underlying character set's
  #      collating sequence.
  # 
  #      If the increment generates a ``carry,'' the character to the left
  #      of it is incremented. This process repeats until there is no carry,
  #      adding an additional character if necessary.
  # 
  #         "abcd".succ        #=> "abce"
  #         "THX1138".succ     #=> "THX1139"
  #         "<<koala>>".succ   #=> "<<koalb>>"
  #         "1999zzz".succ     #=> "2000aaa"
  #         "ZZZ9999".succ     #=> "AAAA0000"
  #         "***".succ         #=> "**+"
  # 
  def next
  end

  # --------------------------------------------------------- String#reverse
  #      str.reverse   => new_str
  # ------------------------------------------------------------------------
  #      Returns a new string with the characters from _str_ in reverse
  #      order.
  # 
  #         "stressed".reverse   #=> "desserts"
  # 
  def reverse
  end

  # ------------------------------------------------------------ String#sub!
  #      str.sub!(pattern, replacement)          => str or nil
  #      str.sub!(pattern) {|match| block }      => str or nil
  # ------------------------------------------------------------------------
  #      Performs the substitutions of +String#sub+ in place, returning
  #      _str_, or +nil+ if no substitutions were performed.
  # 
  def sub!(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- String#insert
  #      str.insert(index, other_str)   => str
  # ------------------------------------------------------------------------
  #      Inserts _other_str_ before the character at the given _index_,
  #      modifying _str_. Negative indices count from the end of the string,
  #      and insert _after_ the given character. The intent is insert
  #      _aString_ so that it starts at the given _index_.
  # 
  #         "abcd".insert(0, 'X')    #=> "Xabcd"
  #         "abcd".insert(3, 'X')    #=> "abcXd"
  #         "abcd".insert(4, 'X')    #=> "abcdX"
  #         "abcd".insert(-3, 'X')   #=> "abXcd"
  #         "abcd".insert(-1, 'X')   #=> "abcdX"
  # 
  def insert(arg0, arg1)
  end

  # ----------------------------------------------------------- String#chomp
  #      str.chomp(separator=$/)   => new_str
  # ------------------------------------------------------------------------
  #      Returns a new +String+ with the given record separator removed from
  #      the end of _str_ (if present). If +$/+ has not been changed from
  #      the default Ruby record separator, then +chomp+ also removes
  #      carriage return characters (that is it will remove +\n+, +\r+, and
  #      +\r\n+).
  # 
  #         "hello".chomp            #=> "hello"
  #         "hello\n".chomp          #=> "hello"
  #         "hello\r\n".chomp        #=> "hello"
  #         "hello\n\r".chomp        #=> "hello\n"
  #         "hello\r".chomp          #=> "hello"
  #         "hello \n there".chomp   #=> "hello \n there"
  #         "hello".chomp("llo")     #=> "he"
  # 
  def chomp(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- String#[]
  #      str[fixnum]                 => fixnum or nil
  #      str[fixnum, fixnum]         => new_str or nil
  #      str[range]                  => new_str or nil
  #      str[regexp]                 => new_str or nil
  #      str[regexp, fixnum]         => new_str or nil
  #      str[other_str]              => new_str or nil
  #      str.slice(fixnum)           => fixnum or nil
  #      str.slice(fixnum, fixnum)   => new_str or nil
  #      str.slice(range)            => new_str or nil
  #      str.slice(regexp)           => new_str or nil
  #      str.slice(regexp, fixnum)   => new_str or nil
  #      str.slice(other_str)        => new_str or nil
  # ------------------------------------------------------------------------
  #      Element Reference---If passed a single +Fixnum+, returns the code
  #      of the character at that position. If passed two +Fixnum+ objects,
  #      returns a substring starting at the offset given by the first, and
  #      a length given by the second. If given a range, a substring
  #      containing characters at offsets given by the range is returned. In
  #      all three cases, if an offset is negative, it is counted from the
  #      end of _str_. Returns +nil+ if the initial offset falls outside the
  #      string, the length is negative, or the beginning of the range is
  #      greater than the end.
  # 
  #      If a +Regexp+ is supplied, the matching portion of _str_ is
  #      returned. If a numeric parameter follows the regular expression,
  #      that component of the +MatchData+ is returned instead. If a
  #      +String+ is given, that string is returned if it occurs in _str_.
  #      In both cases, +nil+ is returned if there is no match.
  # 
  #         a = "hello there"
  #         a[1]                   #=> 101
  #         a[1,3]                 #=> "ell"
  #         a[1..3]                #=> "ell"
  #         a[-3,2]                #=> "er"
  #         a[-4..-2]              #=> "her"
  #         a[12..-1]              #=> nil
  #         a[-2..-4]              #=> ""
  #         a[/[aeiou](.)\1/]      #=> "ell"
  #         a[/[aeiou](.)\1/, 0]   #=> "ell"
  #         a[/[aeiou](.)\1/, 1]   #=> "l"
  #         a[/[aeiou](.)\1/, 2]   #=> nil
  #         a["lo"]                #=> "lo"
  #         a["bye"]               #=> nil
  # 
  def [](arg0, arg1, *rest)
  end

  # --------------------------------------------------------- String#inspect
  #      str.inspect   => string
  # ------------------------------------------------------------------------
  #      Returns a printable version of _str_, with special characters
  #      escaped.
  # 
  #         str = "hello"
  #         str[3] = 8
  #         str.inspect       #=> "hel\010o"
  # 
  def inspect
  end

  # ------------------------------------------------------------- String#tr!
  #      tr!(from, to)
  # ------------------------------------------------------------------------
  #      (no description...)
  def tr!(arg0, arg1)
  end

  # --------------------------------------------------------- String#replace
  #      str.replace(other_str)   => str
  # ------------------------------------------------------------------------
  #      Replaces the contents and taintedness of _str_ with the
  #      corresponding values in _other_str_.
  # 
  #         s = "hello"         #=> "hello"
  #         s.replace "world"   #=> "world"
  # 
  def replace(arg0)
  end

  # ------------------------------------------------------------- String#[]=
  #      str[fixnum] = fixnum
  #      str[fixnum] = new_str
  #      str[fixnum, fixnum] = new_str
  #      str[range] = aString
  #      str[regexp] = new_str
  #      str[regexp, fixnum] = new_str
  #      str[other_str] = new_str
  # ------------------------------------------------------------------------
  #      Element Assignment---Replaces some or all of the content of _str_.
  #      The portion of the string affected is determined using the same
  #      criteria as +String#[]+. If the replacement string is not the same
  #      length as the text it is replacing, the string will be adjusted
  #      accordingly. If the regular expression or string is used as the
  #      index doesn't match a position in the string, +IndexError+ is
  #      raised. If the regular expression form is used, the optional second
  #      +Fixnum+ allows you to specify which portion of the match to
  #      replace (effectively using the +MatchData+ indexing rules. The
  #      forms that take a +Fixnum+ will raise an +IndexError+ if the value
  #      is out of range; the +Range+ form will raise a +RangeError+, and
  #      the +Regexp+ and +String+ forms will silently ignore the
  #      assignment.
  # 
  def []=(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ String#scan
  #      str.scan(pattern)                         => array
  #      str.scan(pattern) {|match, ...| block }   => str
  # ------------------------------------------------------------------------
  #      Both forms iterate through _str_, matching the pattern (which may
  #      be a +Regexp+ or a +String+). For each match, a result is generated
  #      and either added to the result array or passed to the block. If the
  #      pattern contains no groups, each individual result consists of the
  #      matched string, +$&+. If the pattern contains groups, each
  #      individual result is itself an array containing one entry per
  #      group.
  # 
  #         a = "cruel world"
  #         a.scan(/\w+/)        #=> ["cruel", "world"]
  #         a.scan(/.../)        #=> ["cru", "el ", "wor"]
  #         a.scan(/(...)/)      #=> [["cru"], ["el "], ["wor"]]
  #         a.scan(/(..)(..)/)   #=> [["cr", "ue"], ["l ", "wo"]]
  # 
  #      And the block form:
  # 
  #         a.scan(/\w+/) {|w| print "<<#{w}>> " }
  #         print "\n"
  #         a.scan(/(.)(.)/) {|x,y| print y, x }
  #         print "\n"
  # 
  #      _produces:_
  # 
  #         <<cruel>> <<world>>
  #         rceu lowlr
  # 
  def scan(arg0)
  end

  def taguri=(arg0)
  end

  # ------------------------------------------------------------ String#tr_s
  #      str.tr_s(from_str, to_str)   => new_str
  # ------------------------------------------------------------------------
  #      Processes a copy of _str_ as described under +String#tr+, then
  #      removes duplicate characters in regions that were affected by the
  #      translation.
  # 
  #         "hello".tr_s('l', 'r')     #=> "hero"
  #         "hello".tr_s('el', '*')    #=> "h*o"
  #         "hello".tr_s('el', 'hx')   #=> "hhxo"
  # 
  def tr_s(arg0, arg1)
  end

  # --------------------------------------------------------- String#lstrip!
  #      str.lstrip!   => self or nil
  # ------------------------------------------------------------------------
  #      Removes leading whitespace from _str_, returning +nil+ if no change
  #      was made. See also +String#rstrip!+ and +String#strip!+.
  # 
  #         "  hello  ".lstrip   #=> "hello  "
  #         "hello".lstrip!      #=> nil
  # 
  def lstrip!
  end

  # ------------------------------------------------------------ String#succ
  #      str.succ   => new_str
  #      str.next   => new_str
  # ------------------------------------------------------------------------
  #      Returns the successor to _str_. The successor is calculated by
  #      incrementing characters starting from the rightmost alphanumeric
  #      (or the rightmost character if there are no alphanumerics) in the
  #      string. Incrementing a digit always results in another digit, and
  #      incrementing a letter results in another letter of the same case.
  #      Incrementing nonalphanumerics uses the underlying character set's
  #      collating sequence.
  # 
  #      If the increment generates a ``carry,'' the character to the left
  #      of it is incremented. This process repeats until there is no carry,
  #      adding an additional character if necessary.
  # 
  #         "abcd".succ        #=> "abce"
  #         "THX1138".succ     #=> "THX1139"
  #         "<<koala>>".succ   #=> "<<koalb>>"
  #         "1999zzz".succ     #=> "2000aaa"
  #         "ZZZ9999".succ     #=> "AAAA0000"
  #         "***".succ         #=> "**+"
  # 
  # 
  #      (also known as original_succ)
  def succ
  end

  # -------------------------------------------------------------- String#<<
  #      str << fixnum        => str
  #      str.concat(fixnum)   => str
  #      str << obj           => str
  #      str.concat(obj)      => str
  # ------------------------------------------------------------------------
  #      Append---Concatenates the given object to _str_. If the object is a
  #      +Fixnum+ between 0 and 255, it is converted to a character before
  #      concatenation.
  # 
  #         a = "hello "
  #         a << "world"   #=> "hello world"
  #         a.concat(33)   #=> "hello world!"
  # 
  def <<(arg0)
  end

  # ------------------------------------------------------------- String#oct
  #      str.oct   => integer
  # ------------------------------------------------------------------------
  #      Treats leading characters of _str_ as a string of octal digits
  #      (with an optional sign) and returns the corresponding number.
  #      Returns 0 if the conversion fails.
  # 
  #         "123".oct       #=> 83
  #         "-377".oct      #=> -255
  #         "bad".oct       #=> 0
  #         "0377bad".oct   #=> 255
  # 
  def oct
  end

  # --------------------------------------------------------- String#to_yaml
  #      to_yaml( opts = {} )
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ String#gsub
  #      str.gsub(pattern, replacement)       => new_str
  #      str.gsub(pattern) {|match| block }   => new_str
  # ------------------------------------------------------------------------
  #      Returns a copy of _str_ with _all_ occurrences of _pattern_
  #      replaced with either _replacement_ or the value of the block. The
  #      _pattern_ will typically be a +Regexp+; if it is a +String+ then no
  #      regular expression metacharacters will be interpreted (that is
  #      +/\d/+ will match a digit, but +'\d'+ will match a backslash
  #      followed by a 'd').
  # 
  #      If a string is used as the replacement, special variables from the
  #      match (such as +$&+ and +$1+) cannot be substituted into it, as
  #      substitution into the string occurs before the pattern match
  #      starts. However, the sequences +\1+, +\2+, and so on may be used to
  #      interpolate successive groups in the match.
  # 
  #      In the block form, the current match string is passed in as a
  #      parameter, and variables such as +$1+, +$2+, +$`+, +$&+, and +$'+
  #      will be set appropriately. The value returned by the block will be
  #      substituted for the match on each call.
  # 
  #      The result inherits any tainting in the original string or any
  #      supplied replacement string.
  # 
  #         "hello".gsub(/[aeiou]/, '*')              #=> "h*ll*"
  #         "hello".gsub(/([aeiou])/, '<\1>')         #=> "h<e>ll<o>"
  #         "hello".gsub(/./) {|s| s[0].to_s + ' '}   #=> "104 101 108 108 111 "
  # 
  def gsub(arg0, arg1, *rest)
  end

  # ------------------------------------------------- String#is_binary_data?
  #      is_binary_data?()
  # ------------------------------------------------------------------------
  #      (no description...)
  def is_binary_data?
  end

  # ----------------------------------------------------- String#capitalize!
  #      str.capitalize!   => str or nil
  # ------------------------------------------------------------------------
  #      Modifies _str_ by converting the first character to uppercase and
  #      the remainder to lowercase. Returns +nil+ if no changes are made.
  # 
  #         a = "hello"
  #         a.capitalize!   #=> "Hello"
  #         a               #=> "Hello"
  #         a.capitalize!   #=> nil
  # 
  def capitalize!
  end

  # ------------------------------------------------------------ String#to_i
  #      str.to_i(base=10)   => integer
  # ------------------------------------------------------------------------
  #      Returns the result of interpreting leading characters in _str_ as
  #      an integer base _base_ (2, 8, 10, or 16). Extraneous characters
  #      past the end of a valid number are ignored. If there is not a valid
  #      number at the start of _str_, +0+ is returned. This method never
  #      raises an exception.
  # 
  #         "12345".to_i             #=> 12345
  #         "99 red balloons".to_i   #=> 99
  #         "0a".to_i                #=> 0
  #         "0a".to_i(16)            #=> 10
  #         "hello".to_i             #=> 0
  #         "1100101".to_i(2)        #=> 101
  #         "1100101".to_i(8)        #=> 294977
  #         "1100101".to_i(10)       #=> 1100101
  #         "1100101".to_i(16)       #=> 17826049
  # 
  def to_i(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ String#hash
  #      str.hash   => fixnum
  # ------------------------------------------------------------------------
  #      Return a hash based on the string's length and content.
  # 
  def hash
  end

  # ------------------------------------------------------ String#capitalize
  #      str.capitalize   => new_str
  # ------------------------------------------------------------------------
  #      Returns a copy of _str_ with the first character converted to
  #      uppercase and the remainder to lowercase.
  # 
  #         "hello".capitalize    #=> "Hello"
  #         "HELLO".capitalize    #=> "Hello"
  #         "123ABC".capitalize   #=> "123abc"
  # 
  def capitalize
  end

  # ----------------------------------------------------------- String#index
  #      str.index(substring [, offset])   => fixnum or nil
  #      str.index(fixnum [, offset])      => fixnum or nil
  #      str.index(regexp [, offset])      => fixnum or nil
  # ------------------------------------------------------------------------
  #      Returns the index of the first occurrence of the given _substring_,
  #      character (_fixnum_), or pattern (_regexp_) in _str_. Returns +nil+
  #      if not found. If the second parameter is present, it specifies the
  #      position in the string to begin the search.
  # 
  #         "hello".index('e')             #=> 1
  #         "hello".index('lo')            #=> 3
  #         "hello".index('a')             #=> nil
  #         "hello".index(101)             #=> 1
  #         "hello".index(/[aeiou]/, -3)   #=> 4
  # 
  def index(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- String#crypt
  #      str.crypt(other_str)   => new_str
  # ------------------------------------------------------------------------
  #      Applies a one-way cryptographic hash to _str_ by invoking the
  #      standard library function +crypt+. The argument is the salt string,
  #      which should be two characters long, each character drawn from
  #      +[a-zA-Z0-9./]+.
  # 
  def crypt(arg0)
  end

  # ---------------------------------------------------------- String#chomp!
  #      str.chomp!(separator=$/)   => str or nil
  # ------------------------------------------------------------------------
  #      Modifies _str_ in place as described for +String#chomp+, returning
  #      _str_, or +nil+ if no modifications were made.
  # 
  def chomp!(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- String#rstrip
  #      str.rstrip   => new_str
  # ------------------------------------------------------------------------
  #      Returns a copy of _str_ with trailing whitespace removed. See also
  #      +String#lstrip+ and +String#strip+.
  # 
  #         "  hello  ".rstrip   #=> "  hello"
  #         "hello".rstrip       #=> "hello"
  # 
  def rstrip
  end

  # ------------------------------------------------------------- String#sum
  #      str.sum(n=16)   => integer
  # ------------------------------------------------------------------------
  #      Returns a basic _n_-bit checksum of the characters in _str_, where
  #      _n_ is the optional +Fixnum+ parameter, defaulting to 16. The
  #      result is simply the sum of the binary value of each character in
  #      _str_ modulo +2n - 1+. This is not a particularly good checksum.
  # 
  def sum(arg0, arg1, *rest)
  end

  # --------------------------------------------------------- String#upcase!
  #      str.upcase!   => str or nil
  # ------------------------------------------------------------------------
  #      Upcases the contents of _str_, returning +nil+ if no changes were
  #      made.
  # 
  def upcase!
  end

  # ---------------------------------------------------------- String#center
  #      str.center(integer, padstr)   => new_str
  # ------------------------------------------------------------------------
  #      If _integer_ is greater than the length of _str_, returns a new
  #      +String+ of length _integer_ with _str_ centered and padded with
  #      _padstr_; otherwise, returns _str_.
  # 
  #         "hello".center(4)         #=> "hello"
  #         "hello".center(20)        #=> "       hello        "
  #         "hello".center(20, '123') #=> "1231231hello12312312"
  # 
  def center(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- String#upcase
  #      str.upcase   => new_str
  # ------------------------------------------------------------------------
  #      Returns a copy of _str_ with all lowercase letters replaced with
  #      their uppercase counterparts. The operation is locale
  #      insensitive---only characters ``a'' to ``z'' are affected.
  # 
  #         "hEllO".upcase   #=> "HELLO"
  # 
  def upcase
  end

  # ----------------------------------------------------------- String#count
  #      str.count([other_str]+)   => fixnum
  # ------------------------------------------------------------------------
  #      Each _other_str_ parameter defines a set of characters to count.
  #      The intersection of these sets defines the characters to count in
  #      _str_. Any _other_str_ that starts with a caret (^) is negated. The
  #      sequence c1--c2 means all characters between c1 and c2.
  # 
  #         a = "hello world"
  #         a.count "lo"            #=> 5
  #         a.count "lo", "o"       #=> 2
  #         a.count "hello", "^l"   #=> 4
  #         a.count "ej-m"          #=> 4
  # 
  def count(arg0, arg1, *rest)
  end

  # -------------------------------------------------------- String#squeeze!
  #      squeeze!(del=nil)
  # ------------------------------------------------------------------------
  #      (no description...)
  def squeeze!(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------- String#<=>
  #      str <=> other_str   => -1, 0, +1
  # ------------------------------------------------------------------------
  #      Comparison---Returns -1 if _other_str_ is less than, 0 if
  #      _other_str_ is equal to, and +1 if _other_str_ is greater than
  #      _str_. If the strings are of different lengths, and the strings are
  #      equal when compared up to the shortest length, then the longer
  #      string is considered greater than the shorter one. If the variable
  #      +$=+ is +false+, the comparison is based on comparing the binary
  #      values of each character in the string. In older versions of Ruby,
  #      setting +$=+ allowed case-insensitive comparisons; this is now
  #      deprecated in favor of using +String#casecmp+.
  # 
  #      +<=>+ is the basis for the methods +<+, +<=+, +>+, +>=+, and
  #      +between?+, included from module +Comparable+. The method
  #      +String#==+ does not use +Comparable#==+.
  # 
  #         "abcdef" <=> "abcde"     #=> 1
  #         "abcdef" <=> "abcdef"    #=> 0
  #         "abcdef" <=> "abcdefg"   #=> -1
  #         "abcdef" <=> "ABCDEF"    #=> 1
  # 
  def <=>(arg0)
  end

  # ----------------------------------------------------------- String#strip
  #      str.strip   => new_str
  # ------------------------------------------------------------------------
  #      Returns a copy of _str_ with leading and trailing whitespace
  #      removed.
  # 
  #         "    hello    ".strip   #=> "hello"
  #         "\tgoodbye\r\n".strip   #=> "goodbye"
  # 
  def strip
  end

  # -------------------------------------------------------------- String#==
  #      str == obj   => true or false
  # ------------------------------------------------------------------------
  #      Equality---If _obj_ is not a +String+, returns +false+. Otherwise,
  #      returns +true+ if _str_ +<=>+ _obj_ returns zero.
  # 
  def ==(arg0)
  end

  # ---------------------------------------------------------- String#length
  #      str.length   => integer
  # ------------------------------------------------------------------------
  #      Returns the length of _str_.
  # 
  def length
  end

  # ----------------------------------------------------------- String#gsub!
  #      str.gsub!(pattern, replacement)        => str or nil
  #      str.gsub!(pattern) {|match| block }    => str or nil
  # ------------------------------------------------------------------------
  #      Performs the substitutions of +String#gsub+ in place, returning
  #      _str_, or +nil+ if no substitutions were performed.
  # 
  def gsub!(arg0, arg1, *rest)
  end

  # ------------------------------------------------------- String#each_line
  #      str.each(separator=$/) {|substr| block }        => str
  #      str.each_line(separator=$/) {|substr| block }   => str
  # ------------------------------------------------------------------------
  #      Splits _str_ using the supplied parameter as the record separator
  #      (+$/+ by default), passing each substring in turn to the supplied
  #      block. If a zero-length record separator is supplied, the string is
  #      split on +\n+ characters, except that multiple successive newlines
  #      are appended together.
  # 
  #         print "Example one\n"
  #         "hello\nworld".each {|s| p s}
  #         print "Example two\n"
  #         "hello\nworld".each('l') {|s| p s}
  #         print "Example three\n"
  #         "hello\n\n\nworld".each('') {|s| p s}
  # 
  #      _produces:_
  # 
  #         Example one
  #         "hello\n"
  #         "world"
  #         Example two
  #         "hel"
  #         "l"
  #         "o\nworl"
  #         "d"
  #         Example three
  #         "hello\n\n\n"
  #         "world"
  # 
  def each_line(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- String#slice!
  #      str.slice!(fixnum)           => fixnum or nil
  #      str.slice!(fixnum, fixnum)   => new_str or nil
  #      str.slice!(range)            => new_str or nil
  #      str.slice!(regexp)           => new_str or nil
  #      str.slice!(other_str)        => new_str or nil
  # ------------------------------------------------------------------------
  #      Deletes the specified portion from _str_, and returns the portion
  #      deleted. The forms that take a +Fixnum+ will raise an +IndexError+
  #      if the value is out of range; the +Range+ form will raise a
  #      +RangeError+, and the +Regexp+ and +String+ forms will silently
  #      ignore the assignment.
  # 
  #         string = "this is a string"
  #         string.slice!(2)        #=> 105
  #         string.slice!(3..6)     #=> " is "
  #         string.slice!(/s.*t/)   #=> "sa st"
  #         string.slice!("r")      #=> "r"
  #         string                  #=> "thing"
  # 
  def slice!(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- String#ljust
  #      str.ljust(integer, padstr=' ')   => new_str
  # ------------------------------------------------------------------------
  #      If _integer_ is greater than the length of _str_, returns a new
  #      +String+ of length _integer_ with _str_ left justified and padded
  #      with _padstr_; otherwise, returns _str_.
  # 
  #         "hello".ljust(4)            #=> "hello"
  #         "hello".ljust(20)           #=> "hello               "
  #         "hello".ljust(20, '1234')   #=> "hello123412341234123"
  # 
  def ljust(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- String#to_str
  #      str.to_s     => str
  #      str.to_str   => str
  # ------------------------------------------------------------------------
  #      Returns the receiver.
  # 
  def to_str
  end

  # --------------------------------------------------------------- String#%
  #      str % arg   => new_str
  # ------------------------------------------------------------------------
  #      Format---Uses _str_ as a format specification, and returns the
  #      result of applying it to _arg_. If the format specification
  #      contains more than one substitution, then _arg_ must be an +Array+
  #      containing the values to be substituted. See +Kernel::sprintf+ for
  #      details of the format string.
  # 
  #         "%05d" % 123                       #=> "00123"
  #         "%-5s: %08x" % [ "ID", self.id ]   #=> "ID   : 200e14d6"
  # 
  def %(arg0)
  end

  # ---------------------------------------------------------- String#delete
  #      str.delete([other_str]+)   => new_str
  # ------------------------------------------------------------------------
  #      Returns a copy of _str_ with all characters in the intersection of
  #      its arguments deleted. Uses the same rules for building the set of
  #      characters as +String#count+.
  # 
  #         "hello".delete "l","lo"        #=> "heo"
  #         "hello".delete "lo"            #=> "he"
  #         "hello".delete "aeiou", "^e"   #=> "hell"
  #         "hello".delete "ej-m"          #=> "ho"
  # 
  def delete(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- String#tr_s!
  #      tr_s!(from, to)
  # ------------------------------------------------------------------------
  #      (no description...)
  def tr_s!(arg0, arg1)
  end

end
