=begin
------------------------------------------------ Class: Fixnum < Integer
     A +Fixnum+ holds +Integer+ values that can be represented in a
     native machine word (minus 1 bit). If any operation on a +Fixnum+
     exceeds this range, the value is automatically converted to a
     +Bignum+.

     +Fixnum+ objects have immediate value. This means that when they
     are assigned or passed as parameters, the actual object is passed,
     rather than a reference to that object. Assignment does not alias
     +Fixnum+ objects. There is effectively only one +Fixnum+ object
     instance for any given integer value, so, for example, you cannot
     add a singleton method to a +Fixnum+.

------------------------------------------------------------------------
     Enhance the Fixnum class with a XML escaped character conversion.

------------------------------------------------------------------------


Includes:
---------
     Precision(prec, prec_f, prec_i)


Constants:
----------
     XChar: Builder::XChar if ! defined?(XChar)


Class methods:
--------------
     induced_from


Instance methods:
-----------------
     %, &, *, **, +, -, -@, /, <, <<, <=, <=>, ==, >, >=, >>, [], ^,
     abs, dclone, div, divmod, id2name, modulo, power!, quo, rdiv,
     rpower, size, to_f, to_s, to_sym, xchr, zero?, |, ~

=end
class Fixnum < Integer
  include Precision
  include Comparable

  # --------------------------------------------------- Fixnum::induced_from
  #      Fixnum.induced_from(obj)    =>  fixnum
  # ------------------------------------------------------------------------
  #      Convert +obj+ to a Fixnum. Works with numeric parameters. Also
  #      works with Symbols, but this is deprecated.
  # 
  def self.induced_from(arg0)
  end

  # -------------------------------------------------------------- Fixnum#**
  #      **(other)
  # ------------------------------------------------------------------------
  #      Alias for #rpower
  # 
  def **(arg0)
  end

  # --------------------------------------------------------------- Fixnum#-
  #      fix - numeric   =>  numeric_result
  # ------------------------------------------------------------------------
  #      Performs subtraction: the class of the resulting object depends on
  #      the class of +numeric+ and on the magnitude of the result.
  # 
  def -(arg0)
  end

  # ---------------------------------------------------------- Fixnum#divmod
  #      fix.divmod(numeric)    => array
  # ------------------------------------------------------------------------
  #      See +Numeric#divmod+.
  # 
  def divmod(arg0)
  end

  # ------------------------------------------------------------- Fixnum#<=>
  #      fix <=> numeric    => -1, 0, +1
  # ------------------------------------------------------------------------
  #      Comparison---Returns -1, 0, or +1 depending on whether _fix_ is
  #      less than, equal to, or greater than _numeric_. This is the basis
  #      for the tests in +Comparable+.
  # 
  def <=>(arg0)
  end

  # ------------------------------------------------------------ Fixnum#to_f
  #      fix.to_f -> float
  # ------------------------------------------------------------------------
  #      Converts _fix_ to a +Float+.
  # 
  def to_f
  end

  # ------------------------------------------------------------ Fixnum#to_s
  #      fix.to_s( base=10 ) -> aString
  # ------------------------------------------------------------------------
  #      Returns a string containing the representation of _fix_ radix
  #      _base_ (between 2 and 36).
  # 
  #         12345.to_s       #=> "12345"
  #         12345.to_s(2)    #=> "11000000111001"
  #         12345.to_s(8)    #=> "30071"
  #         12345.to_s(10)   #=> "12345"
  #         12345.to_s(16)   #=> "3039"
  #         12345.to_s(36)   #=> "9ix"
  # 
  def to_s(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- Fixnum#to_sym
  #      fix.to_sym -> aSymbol
  # ------------------------------------------------------------------------
  #      Returns the symbol whose integer value is _fix_. See also
  #      +Fixnum#id2name+.
  # 
  #         fred = :fred.to_i
  #         fred.id2name   #=> "fred"
  #         fred.to_sym    #=> :fred
  # 
  def to_sym
  end

  # -------------------------------------------------------------- Fixnum#==
  #      fix == other
  # ------------------------------------------------------------------------
  #      Return +true+ if +fix+ equals +other+ numerically.
  # 
  #        1 == 2      #=> false
  #        1 == 1.0    #=> true
  # 
  def ==(arg0)
  end

  # -------------------------------------------------------------- Fixnum#[]
  #      fix[n]     => 0, 1
  # ------------------------------------------------------------------------
  #      Bit Reference---Returns the _n_th bit in the binary representation
  #      of _fix_, where _fix_[0] is the least significant bit.
  # 
  #         a = 0b11001100101010
  #         30.downto(0) do |n| print a[n] end
  # 
  #      _produces:_
  # 
  #         0000000000000000011001100101010
  # 
  def [](arg0)
  end

  # ------------------------------------------------------------ Fixnum#size
  #      fix.size -> fixnum
  # ------------------------------------------------------------------------
  #      Returns the number of _bytes_ in the machine representation of a
  #      +Fixnum+.
  # 
  #         1.size            #=> 4
  #         -1.size           #=> 4
  #         2147483647.size   #=> 4
  # 
  def size
  end

  # ---------------------------------------------------------- Fixnum#rpower
  #      rpower(other)
  # ------------------------------------------------------------------------
  #      Returns a Rational number if the result is in fact rational (i.e.
  #      +other+ < 0).
  # 
  # 
  #      (also known as **)
  def rpower(arg0)
  end

  # --------------------------------------------------------------- Fixnum#/
  #      /(p1)
  # ------------------------------------------------------------------------
  #      Alias for #quo
  # 
  def /(arg0)
  end

  # ------------------------------------------------------------- Fixnum#abs
  #      fix.abs -> aFixnum
  # ------------------------------------------------------------------------
  #      Returns the absolute value of _fix_.
  # 
  #         -12345.abs   #=> 12345
  #         12345.abs    #=> 12345
  # 
  def abs
  end

  # --------------------------------------------------------------- Fixnum#|
  #      fix | other     => integer
  # ------------------------------------------------------------------------
  #      Bitwise OR.
  # 
  def |(arg0)
  end

  # ----------------------------------------------------------- Fixnum#zero?
  #      fix.zero?    => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _fix_ is zero.
  # 
  def zero?
  end

  # ------------------------------------------------------------- Fixnum#div
  #      fix / numeric      =>  numeric_result
  #      fix.div(numeric)   =>  numeric_result
  # ------------------------------------------------------------------------
  #      Performs division: the class of the resulting object depends on the
  #      class of +numeric+ and on the magnitude of the result.
  # 
  def div(arg0)
  end

  # --------------------------------------------------------------- Fixnum#%
  #      fix % other         => Numeric
  #      fix.modulo(other)   => Numeric
  # ------------------------------------------------------------------------
  #      Returns +fix+ modulo +other+. See +Numeric.divmod+ for more
  #      information.
  # 
  def %(arg0)
  end

  # -------------------------------------------------------------- Fixnum#<<
  #      fix << count     => integer
  # ------------------------------------------------------------------------
  #      Shifts _fix_ left _count_ positions (right if _count_ is negative).
  # 
  def <<(arg0)
  end

  # --------------------------------------------------------- Fixnum#id2name
  #      fix.id2name -> string or nil
  # ------------------------------------------------------------------------
  #      Returns the name of the object whose symbol id is _fix_. If there
  #      is no symbol in the symbol table with this value, returns +nil+.
  #      +id2name+ has nothing to do with the +Object.id+ method. See also
  #      +Fixnum#to_sym+, +String#intern+, and class +Symbol+.
  # 
  #         symbol = :@inst_var    #=> :@inst_var
  #         id     = symbol.to_i   #=> 9818
  #         id.id2name             #=> "@inst_var"
  # 
  def id2name
  end

  # -------------------------------------------------------------- Fixnum#>=
  #      fix >= other     => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the value of +fix+ is greater than or equal to
  #      that of +other+.
  # 
  def >=(arg0)
  end

  # --------------------------------------------------------------- Fixnum#<
  #      fix < other     => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the value of +fix+ is less than that of +other+.
  # 
  def <(arg0)
  end

  # --------------------------------------------------------------- Fixnum#~
  #      ~fix     => integer
  # ------------------------------------------------------------------------
  #      One's complement: returns a number where each bit is flipped.
  # 
  def ~
  end

  # --------------------------------------------------------------- Fixnum#&
  #      fix & other     => integer
  # ------------------------------------------------------------------------
  #      Bitwise AND.
  # 
  def &(arg0)
  end

  # -------------------------------------------------------------- Fixnum#>>
  #      fix >> count     => integer
  # ------------------------------------------------------------------------
  #      Shifts _fix_ right _count_ positions (left if _count_ is negative).
  # 
  def >>(arg0)
  end

  # ------------------------------------------------------------ Fixnum#rdiv
  #      rdiv(p1)
  # ------------------------------------------------------------------------
  #      Alias for #quo
  # 
  def rdiv(arg0)
  end

  # ---------------------------------------------------------- Fixnum#power!
  #      power!(p1)
  # ------------------------------------------------------------------------
  #      Alias for #**
  # 
  def power!(arg0)
  end

  # -------------------------------------------------------------- Fixnum#<=
  #      fix <= other     => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the value of +fix+ is less thanor equal to that
  #      of +other+.
  # 
  def <=(arg0)
  end

  # --------------------------------------------------------------- Fixnum#^
  #      fix ^ other     => integer
  # ------------------------------------------------------------------------
  #      Bitwise EXCLUSIVE OR.
  # 
  def ^(arg0)
  end

  # ------------------------------------------------------------- Fixnum#quo
  #      quo(other)
  # ------------------------------------------------------------------------
  #      If Rational is defined, returns a Rational number instead of a
  #      Fixnum.
  # 
  def quo(arg0)
  end

  # --------------------------------------------------------------- Fixnum#>
  #      fix > other     => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the value of +fix+ is greater than that of
  #      +other+.
  # 
  def >(arg0)
  end

  # --------------------------------------------------------------- Fixnum#*
  #      fix * numeric   =>  numeric_result
  # ------------------------------------------------------------------------
  #      Performs multiplication: the class of the resulting object depends
  #      on the class of +numeric+ and on the magnitude of the result.
  # 
  def *(arg0)
  end

  # ---------------------------------------------------------- Fixnum#modulo
  #      fix % other         => Numeric
  #      fix.modulo(other)   => Numeric
  # ------------------------------------------------------------------------
  #      Returns +fix+ modulo +other+. See +Numeric.divmod+ for more
  #      information.
  # 
  def modulo(arg0)
  end

  # -------------------------------------------------------------- Fixnum#-@
  #      -fix   =>  integer
  # ------------------------------------------------------------------------
  #      Negates +fix+ (which might return a Bignum).
  # 
  def -@
  end

  # --------------------------------------------------------------- Fixnum#+
  #      fix + numeric   =>  numeric_result
  # ------------------------------------------------------------------------
  #      Performs addition: the class of the resulting object depends on the
  #      class of +numeric+ and on the magnitude of the result.
  # 
  def +(arg0)
  end

end
