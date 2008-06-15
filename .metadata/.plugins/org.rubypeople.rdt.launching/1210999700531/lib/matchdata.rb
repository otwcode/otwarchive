=begin
------------------------------------------------------- Class: MatchData
     +MatchData+ is the type of the special variable +$~+, and is the
     type of the object returned by +Regexp#match+ and
     +Regexp#last_match+. It encapsulates all the results of a pattern
     match, results normally accessed through the special variables
     +$&+, +$'+, +$`+, +$1+, +$2+, and so on. +Matchdata+ is also known
     as +MatchingData+.

------------------------------------------------------------------------


Instance methods:
-----------------
     [], begin, captures, end, inspect, length, offset, post_match,
     pre_match, pretty_print, select, size, string, to_a, to_s,
     values_at

=end
class MatchData < Object

  # ------------------------------------------------------- MatchData#string
  #      mtch.string   => str
  # ------------------------------------------------------------------------
  #      Returns a frozen copy of the string passed in to +match+.
  # 
  #         m = /(.)(.)(\d+)(\d)/.match("THX1138.")
  #         m.string   #=> "THX1138."
  # 
  def string
  end

  # --------------------------------------------------------- MatchData#size
  #      mtch.length   => integer
  #      mtch.size     => integer
  # ------------------------------------------------------------------------
  #      Returns the number of elements in the match array.
  # 
  #         m = /(.)(.)(\d+)(\d)/.match("THX1138.")
  #         m.length   #=> 5
  #         m.size     #=> 5
  # 
  def size
  end

  # ---------------------------------------------------------- MatchData#end
  #      mtch.end(n)   => integer
  # ------------------------------------------------------------------------
  #      Returns the offset of the character immediately following the end
  #      of the _n_th element of the match array in the string.
  # 
  #         m = /(.)(.)(\d+)(\d)/.match("THX1138.")
  #         m.end(0)   #=> 7
  #         m.end(2)   #=> 3
  # 
  def end(arg0)
  end

  # ----------------------------------------------------------- MatchData#[]
  #      mtch[i]               => obj
  #      mtch[start, length]   => array
  #      mtch[range]           => array
  # ------------------------------------------------------------------------
  #      Match Reference---+MatchData+ acts as an array, and may be accessed
  #      using the normal array indexing techniques. _mtch_[0] is equivalent
  #      to the special variable +$&+, and returns the entire matched
  #      string. _mtch_[1], _mtch_[2], and so on return the values of the
  #      matched backreferences (portions of the pattern between
  #      parentheses).
  # 
  #         m = /(.)(.)(\d+)(\d)/.match("THX1138.")
  #         m[0]       #=> "HX1138"
  #         m[1, 2]    #=> ["H", "X"]
  #         m[1..3]    #=> ["H", "X", "113"]
  #         m[-3, 2]   #=> ["X", "113"]
  # 
  def [](arg0, arg1, *rest)
  end

  # --------------------------------------------------------- MatchData#to_s
  #      mtch.to_s   => str
  # ------------------------------------------------------------------------
  #      Returns the entire matched string.
  # 
  #         m = /(.)(.)(\d+)(\d)/.match("THX1138.")
  #         m.to_s   #=> "HX1138"
  # 
  def to_s
  end

  # ---------------------------------------------------- MatchData#values_at
  #      mtch.select([index]*)   => array
  # ------------------------------------------------------------------------
  #      Uses each _index_ to access the matching values, returning an array
  #      of the corresponding matches.
  # 
  #         m = /(.)(.)(\d+)(\d)/.match("THX1138: The Movie")
  #         m.to_a               #=> ["HX1138", "H", "X", "113", "8"]
  #         m.select(0, 2, -2)   #=> ["HX1138", "X", "113"]
  # 
  def values_at(arg0, arg1, *rest)
  end

  # --------------------------------------------------- MatchData#post_match
  #      mtch.post_match   => str
  # ------------------------------------------------------------------------
  #      Returns the portion of the original string after the current match.
  #      Equivalent to the special variable +$'+.
  # 
  #         m = /(.)(.)(\d+)(\d)/.match("THX1138: The Movie")
  #         m.post_match   #=> ": The Movie"
  # 
  def post_match
  end

  # ------------------------------------------------------- MatchData#length
  #      mtch.length   => integer
  #      mtch.size     => integer
  # ------------------------------------------------------------------------
  #      Returns the number of elements in the match array.
  # 
  #         m = /(.)(.)(\d+)(\d)/.match("THX1138.")
  #         m.length   #=> 5
  #         m.size     #=> 5
  # 
  def length
  end

  # -------------------------------------------------------- MatchData#begin
  #      mtch.begin(n)   => integer
  # ------------------------------------------------------------------------
  #      Returns the offset of the start of the _n_th element of the match
  #      array in the string.
  # 
  #         m = /(.)(.)(\d+)(\d)/.match("THX1138.")
  #         m.begin(0)   #=> 1
  #         m.begin(2)   #=> 2
  # 
  def begin(arg0)
  end

  # --------------------------------------------------------- MatchData#to_a
  #      mtch.to_a   => anArray
  # ------------------------------------------------------------------------
  #      Returns the array of matches.
  # 
  #         m = /(.)(.)(\d+)(\d)/.match("THX1138.")
  #         m.to_a   #=> ["HX1138", "H", "X", "113", "8"]
  # 
  #      Because +to_a+ is called when expanding +*+_variable_, there's a
  #      useful assignment shortcut for extracting matched fields. This is
  #      slightly slower than accessing the fields directly (as an
  #      intermediate array is generated).
  # 
  #         all,f1,f2,f3 = *(/(.)(.)(\d+)(\d)/.match("THX1138."))
  #         all   #=> "HX1138"
  #         f1    #=> "H"
  #         f2    #=> "X"
  #         f3    #=> "113"
  # 
  def to_a
  end

  # ---------------------------------------------------- MatchData#pre_match
  #      mtch.pre_match   => str
  # ------------------------------------------------------------------------
  #      Returns the portion of the original string before the current
  #      match. Equivalent to the special variable +$`+.
  # 
  #         m = /(.)(.)(\d+)(\d)/.match("THX1138.")
  #         m.pre_match   #=> "T"
  # 
  def pre_match
  end

  # ------------------------------------------------------- MatchData#offset
  #      mtch.offset(n)   => array
  # ------------------------------------------------------------------------
  #      Returns a two-element array containing the beginning and ending
  #      offsets of the _n_th match.
  # 
  #         m = /(.)(.)(\d+)(\d)/.match("THX1138.")
  #         m.offset(0)   #=> [1, 7]
  #         m.offset(4)   #=> [6, 7]
  # 
  def offset(arg0)
  end

  # ------------------------------------------------------- MatchData#select
  #      mtch.select([index]*)   => array
  # ------------------------------------------------------------------------
  #      Uses each _index_ to access the matching values, returning an array
  #      of the corresponding matches.
  # 
  #         m = /(.)(.)(\d+)(\d)/.match("THX1138: The Movie")
  #         m.to_a               #=> ["HX1138", "H", "X", "113", "8"]
  #         m.select(0, 2, -2)   #=> ["HX1138", "X", "113"]
  # 
  def select(arg0, arg1, *rest)
  end

  # ----------------------------------------------------- MatchData#captures
  #      mtch.captures   => array
  # ------------------------------------------------------------------------
  #      Returns the array of captures; equivalent to +mtch.to_a[1..-1]+.
  # 
  #         f1,f2,f3,f4 = /(.)(.)(\d+)(\d)/.match("THX1138.").captures
  #         f1    #=> "H"
  #         f2    #=> "X"
  #         f3    #=> "113"
  #         f4    #=> "8"
  # 
  def captures
  end

  # ------------------------------------------------------ MatchData#inspect
  #      obj.to_s    => string
  # ------------------------------------------------------------------------
  #      Returns a string representing _obj_. The default +to_s+ prints the
  #      object's class and an encoding of the object id. As a special case,
  #      the top-level object that is the initial execution context of Ruby
  #      programs returns ``main.''
  # 
  def inspect
  end

end
