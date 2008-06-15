=begin
--------------------------------------------------------- Class: Numeric
     Numeric is a built-in class on which Fixnum, Bignum, etc., are
     based. Here some methods are added so that all number types can be
     treated to some extent as Complex numbers.

------------------------------------------------------------------------


Includes:
---------
     Comparable(<, <=, ==, >, >=, between?)


Instance methods:
-----------------
     +@, -@, <=>, abs, angle, arg, ceil, coerce, conj, conjugate, div,
     divmod, eql?, floor, im, imag, image, integer?, modulo, nonzero?,
     polar, quo, real, remainder, round, singleton_method_added, step,
     to_int, truncate, zero?

=end
class Numeric < Object
  include Comparable

  # ----------------------------------------------------------- Numeric#eql?
  #      num.eql?(numeric)    => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _num_ and _numeric_ are the same type and have
  #      equal values.
  # 
  #         1 == 1.0          #=> true
  #         1.eql?(1.0)       #=> false
  #         (1.0).eql?(1.0)   #=> true
  # 
  def eql?(arg0)
  end

  # ------------------------------------------------------- Numeric#nonzero?
  #      num.nonzero?    => num or nil
  # ------------------------------------------------------------------------
  #      Returns _num_ if _num_ is not zero, +nil+ otherwise. This behavior
  #      is useful when chaining comparisons:
  # 
  #         a = %w( z Bb bB bb BB a aA Aa AA A )
  #         b = a.sort {|a,b| (a.downcase <=> b.downcase).nonzero? || a <=> b }
  #         b   #=> ["A", "a", "AA", "Aa", "aA", "BB", "Bb", "bB", "bb", "z"]
  # 
  def nonzero?
  end

  # ----------------------------------------- Numeric#singleton_method_added
  #      singleton_method_added(p1)
  # ------------------------------------------------------------------------
  #      Trap attempts to add methods to +Numeric+ objects. Always raises a
  #      +TypeError+
  # 
  def singleton_method_added(arg0)
  end

  # ------------------------------------------------------------ Numeric#<=>
  #      num <=> other -> 0 or nil
  # ------------------------------------------------------------------------
  #      Returns zero if _num_ equals _other_, +nil+ otherwise.
  # 
  def <=>(arg0)
  end

  # --------------------------------------------------------- Numeric#divmod
  #      num.divmod( aNumeric ) -> anArray
  # ------------------------------------------------------------------------
  #      Returns an array containing the quotient and modulus obtained by
  #      dividing _num_ by _aNumeric_. If +q, r = x.divmod(y)+, then
  # 
  #          q = floor(float(x)/float(y))
  #          x = q*y + r
  # 
  #      The quotient is rounded toward -infinity, as shown in the following
  #      table:
  # 
  #         a    |  b  |  a.divmod(b)  |   a/b   | a.modulo(b) | a.remainder(b)
  #        ------+-----+---------------+---------+-------------+---------------
  #         13   |  4  |   3,    1     |   3     |    1        |     1
  #        ------+-----+---------------+---------+-------------+---------------
  #         13   | -4  |  -4,   -3     |  -3     |   -3        |     1
  #        ------+-----+---------------+---------+-------------+---------------
  #        -13   |  4  |  -4,    3     |  -4     |    3        |    -1
  #        ------+-----+---------------+---------+-------------+---------------
  #        -13   | -4  |   3,   -1     |   3     |   -1        |    -1
  #        ------+-----+---------------+---------+-------------+---------------
  #         11.5 |  4  |   2,    3.5   |   2.875 |    3.5      |     3.5
  #        ------+-----+---------------+---------+-------------+---------------
  #         11.5 | -4  |  -3,   -0.5   |  -2.875 |   -0.5      |     3.5
  #        ------+-----+---------------+---------+-------------+---------------
  #        -11.5 |  4  |  -3,    0.5   |  -2.875 |    0.5      |    -3.5
  #        ------+-----+---------------+---------+-------------+---------------
  #        -11.5 | -4  |   2    -3.5   |   2.875 |   -3.5      |    -3.5
  # 
  #      Examples
  # 
  #         11.divmod(3)         #=> [3, 2]
  #         11.divmod(-3)        #=> [-4, -1]
  #         11.divmod(3.5)       #=> [3, 0.5]
  #         (-11).divmod(3.5)    #=> [-4, 3.0]
  #         (11.5).divmod(3.5)   #=> [3, 1.0]
  # 
  def divmod(arg0)
  end

  # ----------------------------------------------------------- Numeric#step
  #      num.step(limit, step ) {|i| block }     => num
  # ------------------------------------------------------------------------
  #      Invokes _block_ with the sequence of numbers starting at _num_,
  #      incremented by _step_ on each call. The loop finishes when the
  #      value to be passed to the block is greater than _limit_ (if _step_
  #      is positive) or less than _limit_ (if _step_ is negative). If all
  #      the arguments are integers, the loop operates using an integer
  #      counter. If any of the arguments are floating point numbers, all
  #      are converted to floats, and the loop is executed _floor(n +
  #      n*epsilon)+ 1_ times, where _n = (limit - num)/step_. Otherwise,
  #      the loop starts at _num_, uses either the +<+ or +>+ operator to
  #      compare the counter against _limit_, and increments itself using
  #      the +++ operator.
  # 
  #         1.step(10, 2) { |i| print i, " " }
  #         Math::E.step(Math::PI, 0.2) { |f| print f, " " }
  # 
  #      _produces:_
  # 
  #         1 3 5 7 9
  #         2.71828182845905 2.91828182845905 3.11828182845905
  # 
  def step(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- Numeric#floor
  #      num.floor    => integer
  # ------------------------------------------------------------------------
  #      Returns the largest integer less than or equal to _num_. +Numeric+
  #      implements this by converting _anInteger_ to a +Float+ and invoking
  #      +Float#floor+.
  # 
  #         1.floor      #=> 1
  #         (-1).floor   #=> -1
  # 
  def floor
  end

  # ------------------------------------------------------------ Numeric#abs
  #      num.abs   => num or numeric
  # ------------------------------------------------------------------------
  #      Returns the absolute value of _num_.
  # 
  #         12.abs         #=> 12
  #         (-34.56).abs   #=> 34.56
  #         -34.56.abs     #=> 34.56
  # 
  def abs
  end

  # ---------------------------------------------------------- Numeric#zero?
  #      num.zero?    => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _num_ has a zero value.
  # 
  def zero?
  end

  # ------------------------------------------------------------ Numeric#div
  #      num.div(numeric)    => integer
  # ------------------------------------------------------------------------
  #      Uses +/+ to perform division, then converts the result to an
  #      integer. +Numeric+ does not define the +/+ operator; this is left
  #      to subclasses.
  # 
  def div(arg0)
  end

  # ------------------------------------------------------- Numeric#truncate
  #      num.truncate    => integer
  # ------------------------------------------------------------------------
  #      Returns _num_ truncated to an integer. +Numeric+ implements this by
  #      converting its value to a float and invoking +Float#truncate+.
  # 
  def truncate
  end

  # ------------------------------------------------------ Numeric#remainder
  #      num.remainder(numeric)    => result
  # ------------------------------------------------------------------------
  #      If _num_ and _numeric_ have different signs, returns
  #      _mod_-_numeric_; otherwise, returns _mod_. In both cases _mod_ is
  #      the value _num_.+modulo(+_numeric_+)+. The differences between
  #      +remainder+ and modulo (+%+) are shown in the table under
  #      +Numeric#divmod+.
  # 
  def remainder(arg0)
  end

  # ------------------------------------------------------- Numeric#integer?
  #      num.integer? -> true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _num_ is an +Integer+ (including +Fixnum+ and
  #      +Bignum+).
  # 
  def integer?
  end

  # ------------------------------------------------------------ Numeric#quo
  #      num.quo(numeric)    =>   result
  # ------------------------------------------------------------------------
  #      Equivalent to +Numeric#/+, but overridden in subclasses.
  # 
  def quo(arg0)
  end

  # ---------------------------------------------------------- Numeric#round
  #      num.round    => integer
  # ------------------------------------------------------------------------
  #      Rounds _num_ to the nearest integer. +Numeric+ implements this by
  #      converting itself to a +Float+ and invoking +Float#round+.
  # 
  def round
  end

  # --------------------------------------------------------- Numeric#coerce
  #      num.coerce(numeric)   => array
  # ------------------------------------------------------------------------
  #      If _aNumeric_ is the same type as _num_, returns an array
  #      containing _aNumeric_ and _num_. Otherwise, returns an array with
  #      both _aNumeric_ and _num_ represented as +Float+ objects. This
  #      coercion mechanism is used by Ruby to handle mixed-type numeric
  #      operations: it is intended to find a compatible common type between
  #      the two operands of the operator.
  # 
  #         1.coerce(2.5)   #=> [2.5, 1.0]
  #         1.2.coerce(3)   #=> [3.0, 1.2]
  #         1.coerce(2)     #=> [2, 1]
  # 
  def coerce(arg0)
  end

  # --------------------------------------------------------- Numeric#to_int
  #      num.to_int    => integer
  # ------------------------------------------------------------------------
  #      Invokes the child class's +to_i+ method to convert _num_ to an
  #      integer.
  # 
  def to_int
  end

  # ------------------------------------------------------------- Numeric#+@
  #      +num    => num
  # ------------------------------------------------------------------------
  #      Unary Plus---Returns the receiver's value.
  # 
  def +@
  end

  # --------------------------------------------------------- Numeric#modulo
  #      num.modulo(numeric)    => result
  # ------------------------------------------------------------------------
  #      Equivalent to _num_.+divmod(+_aNumeric_+)[1]+.
  # 
  def modulo(arg0)
  end

  # ------------------------------------------------------------- Numeric#-@
  #      -num    => numeric
  # ------------------------------------------------------------------------
  #      Unary Minus---Returns the receiver's value, negated.
  # 
  def -@
  end

  # ----------------------------------------------------------- Numeric#ceil
  #      num.ceil    => integer
  # ------------------------------------------------------------------------
  #      Returns the smallest +Integer+ greater than or equal to _num_.
  #      Class +Numeric+ achieves this by converting itself to a +Float+
  #      then invoking +Float#ceil+.
  # 
  #         1.ceil        #=> 1
  #         1.2.ceil      #=> 2
  #         (-1.2).ceil   #=> -1
  #         (-1.0).ceil   #=> -1
  # 
  def ceil
  end

end
