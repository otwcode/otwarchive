=begin
----------------------------------------------- Class: Integer < Numeric
     +Integer+ is the basis for the two concrete classes that hold whole
     numbers, +Bignum+ and +Fixnum+.

------------------------------------------------------------------------


Includes:
---------
     Precision(prec, prec_f, prec_i)


Class methods:
--------------
     from_prime_division, induced_from


Instance methods:
-----------------
     ceil, chr, denominator, downto, floor, gcd, gcd2, gcdlcm, integer?,
     lcm, next, numerator, prime_division, round, succ, times, to_i,
     to_int, to_r, to_yaml, truncate, upto

=end
class Integer < Numeric
  include Precision
  include Comparable

  # -------------------------------------------------- Integer::induced_from
  #      Integer.induced_from(obj)    =>  fixnum, bignum
  # ------------------------------------------------------------------------
  #      Convert +obj+ to an Integer.
  # 
  def self.induced_from(arg0)
  end

  def self.yaml_tag_subclasses?
  end

  # ------------------------------------------------------------ Integer#lcm
  #      lcm(other)
  # ------------------------------------------------------------------------
  #      Returns the _lowest common multiple_ (LCM) of the two arguments
  #      (+self+ and +other+).
  # 
  #      Examples:
  # 
  #        6.lcm 7        # -> 42
  #        6.lcm 9        # -> 18
  # 
  def lcm(arg0)
  end

  # ---------------------------------------------------------- Integer#floor
  #      int.to_i      => int
  #      int.to_int    => int
  #      int.floor     => int
  #      int.ceil      => int
  #      int.round     => int
  #      int.truncate  => int
  # ------------------------------------------------------------------------
  #      As _int_ is already an +Integer+, all these methods simply return
  #      the receiver.
  # 
  def floor
  end

  def taguri=(arg0)
  end

  def to_bn
  end

  # ----------------------------------------------------------- Integer#upto
  #      int.upto(limit) {|i| block }     => int
  # ------------------------------------------------------------------------
  #      Iterates _block_, passing in integer values from _int_ up to and
  #      including _limit_.
  # 
  #         5.upto(10) { |i| print i, " " }
  # 
  #      _produces:_
  # 
  #         5 6 7 8 9 10
  # 
  def upto(arg0)
  end

  # ------------------------------------------------------------ Integer#chr
  #      int.chr    => string
  # ------------------------------------------------------------------------
  #      Returns a string containing the ASCII character represented by the
  #      receiver's value.
  # 
  #         65.chr    #=> "A"
  #         ?a.chr    #=> "a"
  #         230.chr   #=> "\346"
  # 
  def chr
  end

  # ------------------------------------------------------ Integer#numerator
  #      numerator()
  # ------------------------------------------------------------------------
  #      In an integer, the value _is_ the numerator of its rational
  #      equivalent. Therefore, this method returns +self+.
  # 
  def numerator
  end

  # ----------------------------------------------------------- Integer#succ
  #      int.next    => integer
  #      int.succ    => integer
  # ------------------------------------------------------------------------
  #      Returns the +Integer+ equal to _int_ + 1.
  # 
  #         1.next      #=> 2
  #         (-1).next   #=> 0
  # 
  def succ
  end

  # ----------------------------------------------------------- Integer#to_i
  #      int.to_i      => int
  #      int.to_int    => int
  #      int.floor     => int
  #      int.ceil      => int
  #      int.round     => int
  #      int.truncate  => int
  # ------------------------------------------------------------------------
  #      As _int_ is already an +Integer+, all these methods simply return
  #      the receiver.
  # 
  def to_i
  end

  # ------------------------------------------------------- Integer#truncate
  #      int.to_i      => int
  #      int.to_int    => int
  #      int.floor     => int
  #      int.ceil      => int
  #      int.round     => int
  #      int.truncate  => int
  # ------------------------------------------------------------------------
  #      As _int_ is already an +Integer+, all these methods simply return
  #      the receiver.
  # 
  def truncate
  end

  # ------------------------------------------------------- Integer#integer?
  #      int.integer? -> true
  # ------------------------------------------------------------------------
  #      Always returns +true+.
  # 
  def integer?
  end

  # ---------------------------------------------------------- Integer#times
  #      int.times {|i| block }     => int
  # ------------------------------------------------------------------------
  #      Iterates block _int_ times, passing in values from zero to _int_ -
  #      1.
  # 
  #         5.times do |i|
  #           print i, " "
  #         end
  # 
  #      _produces:_
  # 
  #         0 1 2 3 4
  # 
  def times
  end

  # ---------------------------------------------------------- Integer#round
  #      int.to_i      => int
  #      int.to_int    => int
  #      int.floor     => int
  #      int.ceil      => int
  #      int.round     => int
  #      int.truncate  => int
  # ------------------------------------------------------------------------
  #      As _int_ is already an +Integer+, all these methods simply return
  #      the receiver.
  # 
  def round
  end

  # ----------------------------------------------------------- Integer#to_r
  #      to_r()
  # ------------------------------------------------------------------------
  #      Returns a Rational representation of this integer.
  # 
  def to_r
  end

  # --------------------------------------------------------- Integer#to_int
  #      int.to_i      => int
  #      int.to_int    => int
  #      int.floor     => int
  #      int.ceil      => int
  #      int.round     => int
  #      int.truncate  => int
  # ------------------------------------------------------------------------
  #      As _int_ is already an +Integer+, all these methods simply return
  #      the receiver.
  # 
  def to_int
  end

  # --------------------------------------------------------- Integer#gcdlcm
  #      gcdlcm(other)
  # ------------------------------------------------------------------------
  #      Returns the GCD _and_ the LCM (see #gcd and #lcm) of the two
  #      arguments (+self+ and +other+). This is more efficient than
  #      calculating them separately.
  # 
  #      Example:
  # 
  #        6.gcdlcm 9     # -> [3, 18]
  # 
  def gcdlcm(arg0)
  end

  # --------------------------------------------------------- Integer#downto
  #      int.downto(limit) {|i| block }     => int
  # ------------------------------------------------------------------------
  #      Iterates _block_, passing decreasing values from _int_ down to and
  #      including _limit_.
  # 
  #         5.downto(1) { |n| print n, ".. " }
  #         print "  Liftoff!\n"
  # 
  #      _produces:_
  # 
  #         5.. 4.. 3.. 2.. 1..   Liftoff!
  # 
  def downto(arg0)
  end

  # ----------------------------------------------------------- Integer#next
  #      int.next    => integer
  #      int.succ    => integer
  # ------------------------------------------------------------------------
  #      Returns the +Integer+ equal to _int_ + 1.
  # 
  #         1.next      #=> 2
  #         (-1).next   #=> 0
  # 
  def next
  end

  # ---------------------------------------------------- Integer#denominator
  #      denominator()
  # ------------------------------------------------------------------------
  #      In an integer, the denominator is 1. Therefore, this method returns
  #      1.
  # 
  def denominator
  end

  # ----------------------------------------------------------- Integer#ceil
  #      int.to_i      => int
  #      int.to_int    => int
  #      int.floor     => int
  #      int.ceil      => int
  #      int.round     => int
  #      int.truncate  => int
  # ------------------------------------------------------------------------
  #      As _int_ is already an +Integer+, all these methods simply return
  #      the receiver.
  # 
  def ceil
  end

  # ------------------------------------------------------------ Integer#gcd
  #      gcd(other)
  # ------------------------------------------------------------------------
  #      Returns the _greatest common denominator_ of the two numbers
  #      (+self+ and +n+).
  # 
  #      Examples:
  # 
  #        72.gcd 168           # -> 24
  #        19.gcd 36            # -> 1
  # 
  #      The result is positive, no matter the sign of the arguments.
  # 
  def gcd(arg0)
  end

  def taguri
  end

  # -------------------------------------------------------- Integer#to_yaml
  #      to_yaml( opts = {} )
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml(arg0, arg1, *rest)
  end

end
