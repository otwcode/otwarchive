=begin
------------------------------------------------ Class: Bignum < Integer
     Bignum objects hold integers outside the range of Fixnum. Bignum
     objects are created automatically when integer calculations would
     otherwise overflow a Fixnum. When a calculation involving Bignum
     objects returns a result that will fit in a Fixnum, the result is
     automatically converted.

     For the purposes of the bitwise operations and +[]+, a Bignum is
     treated as if it were an infinite-length bitstring with 2's
     complement representation.

     While Fixnum values are immediate, Bignum objects are
     not---assignment and parameter passing work with references to
     objects, not the objects themselves.

------------------------------------------------------------------------


Instance methods:
-----------------
     %, &, *, **, **, +, -, -@, /, /, <<, <=>, ==, >>, [], ^, abs,
     coerce, div, divmod, eql?, hash, modulo, power!, quo, quo, rdiv,
     remainder, rpower, size, to_f, to_s, |, ~

=end
class Bignum < Integer
  include Precision
  include Comparable

  # -------------------------------------------------------------- Bignum#**
  #      big ** exponent   #=> numeric
  # ------------------------------------------------------------------------
  #      Raises _big_ to the _exponent_ power (which may be an integer,
  #      float, or anything that will coerce to a number). The result may be
  #      a Fixnum, Bignum, or Float
  # 
  #        123456789 ** 2      #=> 15241578750190521
  #        123456789 ** 1.2    #=> 5126464716.09932
  #        123456789 ** -2     #=> 6.5610001194102e-17
  # 
  # 
  #      (also known as power!)
  def **(arg0)
  end

  # ------------------------------------------------------------ Bignum#eql?
  #      big.eql?(obj)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ only if _obj_ is a +Bignum+ with the same value as
  #      _big_. Contrast this with +Bignum#==+, which performs type
  #      conversions.
  # 
  #         68719476736.eql?(68719476736.0)   #=> false
  # 
  def eql?(arg0)
  end

  # --------------------------------------------------------------- Bignum#-
  #      big - other  => Numeric
  # ------------------------------------------------------------------------
  #      Subtracts other from big, returning the result.
  # 
  def -(arg0)
  end

  # ---------------------------------------------------------- Bignum#divmod
  #      big.divmod(numeric)   => array
  # ------------------------------------------------------------------------
  #      See +Numeric#divmod+.
  # 
  def divmod(arg0)
  end

  # ------------------------------------------------------------- Bignum#<=>
  #      big <=> numeric   => -1, 0, +1
  # ------------------------------------------------------------------------
  #      Comparison---Returns -1, 0, or +1 depending on whether _big_ is
  #      less than, equal to, or greater than _numeric_. This is the basis
  #      for the tests in +Comparable+.
  # 
  def <=>(arg0)
  end

  # ------------------------------------------------------------ Bignum#to_f
  #      big.to_f -> float
  # ------------------------------------------------------------------------
  #      Converts _big_ to a +Float+. If _big_ doesn't fit in a +Float+, the
  #      result is infinity.
  # 
  def to_f
  end

  # ------------------------------------------------------------ Bignum#to_s
  #      big.to_s(base=10)   =>  string
  # ------------------------------------------------------------------------
  #      Returns a string containing the representation of _big_ radix
  #      _base_ (2 through 36).
  # 
  #         12345654321.to_s         #=> "12345654321"
  #         12345654321.to_s(2)      #=> "1011011111110110111011110000110001"
  #         12345654321.to_s(8)      #=> "133766736061"
  #         12345654321.to_s(16)     #=> "2dfdbbc31"
  #         78546939656932.to_s(36)  #=> "rubyrules"
  # 
  def to_s(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- Bignum#[]
  #      big[n] -> 0, 1
  # ------------------------------------------------------------------------
  #      Bit Reference---Returns the _n_th bit in the (assumed) binary
  #      representation of _big_, where _big_[0] is the least significant
  #      bit.
  # 
  #         a = 9**15
  #         50.downto(0) do |n|
  #           print a[n]
  #         end
  # 
  #      _produces:_
  # 
  #         000101110110100000111000011110010100111100010111001
  # 
  def [](arg0)
  end

  # -------------------------------------------------------------- Bignum#==
  #      big == obj  => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ only if _obj_ has the same value as _big_. Contrast
  #      this with +Bignum#eql?+, which requires _obj_ to be a +Bignum+.
  # 
  #         68719476736 == 68719476736.0   #=> true
  # 
  def ==(arg0)
  end

  # ------------------------------------------------------------ Bignum#size
  #      big.size -> integer
  # ------------------------------------------------------------------------
  #      Returns the number of bytes in the machine representation of _big_.
  # 
  #         (256**10 - 1).size   #=> 12
  #         (256**20 - 1).size   #=> 20
  #         (256**40 - 1).size   #=> 40
  # 
  def size
  end

  # ---------------------------------------------------------- Bignum#rpower
  #      rpower(other)
  # ------------------------------------------------------------------------
  #      Returns a Rational number if the result is in fact rational (i.e.
  #      +other+ < 0).
  # 
  # 
  #      (also known as **)
  def rpower(arg0)
  end

  # --------------------------------------------------------------- Bignum#/
  #      /(p1)
  # ------------------------------------------------------------------------
  #      Alias for #quo
  # 
  def /(arg0)
  end

  # --------------------------------------------------------------- Bignum#|
  #      big | numeric   =>  integer
  # ------------------------------------------------------------------------
  #      Performs bitwise +or+ between _big_ and _numeric_.
  # 
  def |(arg0)
  end

  # ------------------------------------------------------------ Bignum#hash
  #      big.hash   => fixnum
  # ------------------------------------------------------------------------
  #      Compute a hash based on the value of _big_.
  # 
  def hash
  end

  # ------------------------------------------------------------- Bignum#abs
  #      big.abs -> aBignum
  # ------------------------------------------------------------------------
  #      Returns the absolute value of _big_.
  # 
  #         -1234567890987654321.abs   #=> 1234567890987654321
  # 
  def abs
  end

  # --------------------------------------------------------------- Bignum#%
  #      big % other         => Numeric
  #      big.modulo(other)   => Numeric
  # ------------------------------------------------------------------------
  #      Returns big modulo other. See Numeric.divmod for more information.
  # 
  def %(arg0)
  end

  # ------------------------------------------------------------- Bignum#div
  #      big / other     => Numeric
  #      big.div(other)  => Numeric
  # ------------------------------------------------------------------------
  #      Divides big by other, returning the result.
  # 
  def div(arg0)
  end

  # -------------------------------------------------------------- Bignum#<<
  #      big << numeric   =>  integer
  # ------------------------------------------------------------------------
  #      Shifts big left _numeric_ positions (right if _numeric_ is
  #      negative).
  # 
  def <<(arg0)
  end

  # --------------------------------------------------------------- Bignum#&
  #      big & numeric   =>  integer
  # ------------------------------------------------------------------------
  #      Performs bitwise +and+ between _big_ and _numeric_.
  # 
  def &(arg0)
  end

  # --------------------------------------------------------------- Bignum#~
  #      ~big  =>  integer
  # ------------------------------------------------------------------------
  #      Inverts the bits in big. As Bignums are conceptually infinite
  #      length, the result acts as if it had an infinite number of one bits
  #      to the left. In hex representations, this is displayed as two
  #      periods to the left of the digits.
  # 
  #        sprintf("%X", ~0x1122334455)    #=> "..FEEDDCCBBAA"
  # 
  def ~
  end

  # -------------------------------------------------------------- Bignum#>>
  #      big >> numeric   =>  integer
  # ------------------------------------------------------------------------
  #      Shifts big right _numeric_ positions (left if _numeric_ is
  #      negative).
  # 
  def >>(arg0)
  end

  # ---------------------------------------------------------- Bignum#power!
  #      power!(p1)
  # ------------------------------------------------------------------------
  #      Alias for #**
  # 
  def power!(arg0)
  end

  # ------------------------------------------------------------ Bignum#rdiv
  #      rdiv(p1)
  # ------------------------------------------------------------------------
  #      Alias for #quo
  # 
  def rdiv(arg0)
  end

  # ------------------------------------------------------- Bignum#remainder
  #      big.remainder(numeric)    => number
  # ------------------------------------------------------------------------
  #      Returns the remainder after dividing _big_ by _numeric_.
  # 
  #         -1234567890987654321.remainder(13731)      #=> -6966
  #         -1234567890987654321.remainder(13731.24)   #=> -9906.22531493148
  # 
  def remainder(arg0)
  end

  # --------------------------------------------------------------- Bignum#^
  #      big ^ numeric   =>  integer
  # ------------------------------------------------------------------------
  #      Performs bitwise +exclusive or+ between _big_ and _numeric_.
  # 
  def ^(arg0)
  end

  # ------------------------------------------------------------- Bignum#quo
  #      quo(other)
  # ------------------------------------------------------------------------
  #      If Rational is defined, returns a Rational number instead of a
  #      Bignum.
  # 
  def quo(arg0)
  end

  # ---------------------------------------------------------- Bignum#coerce
  #      coerce(p1)
  # ------------------------------------------------------------------------
  #      MISSING: documentation
  # 
  def coerce(arg0)
  end

  # --------------------------------------------------------------- Bignum#*
  #      big * other  => Numeric
  # ------------------------------------------------------------------------
  #      Multiplies big and other, returning the result.
  # 
  def *(arg0)
  end

  # ---------------------------------------------------------- Bignum#modulo
  #      big % other         => Numeric
  #      big.modulo(other)   => Numeric
  # ------------------------------------------------------------------------
  #      Returns big modulo other. See Numeric.divmod for more information.
  # 
  def modulo(arg0)
  end

  # -------------------------------------------------------------- Bignum#-@
  #      -big   =>  other_big
  # ------------------------------------------------------------------------
  #      Unary minus (returns a new Bignum whose value is 0-big)
  # 
  def -@
  end

  # --------------------------------------------------------------- Bignum#+
  #      big + other  => Numeric
  # ------------------------------------------------------------------------
  #      Adds big and other, returning the result.
  # 
  def +(arg0)
  end

end
