=begin
-------------------------------------------------------- Class: Rational
     Rational implements a rational class for numbers.

     _A rational number is a number that can be expressed as a fraction
     p/q where p and q are integers and q != 0. A rational number p/q is
     said to have numerator p and denominator q. Numbers that are not
     rational are called irrational numbers._
     (http://mathworld.wolfram.com/RationalNumber.html)

     To create a Rational Number:

       Rational(a,b)             # -> a/b
       Rational.new!(a,b)        # -> a/b

     Examples:

       Rational(5,6)             # -> 5/6
       Rational(5)               # -> 5/1

     Rational numbers are reduced to their lowest terms:

       Rational(6,10)            # -> 3/5

     But not if you use the unusual method "new!":

       Rational.new!(6,10)       # -> 6/10

     Division by zero is obviously not allowed:

       Rational(3,0)             # -> ZeroDivisionError

------------------------------------------------------------------------


Constants:
----------
     Unify: true


Class methods:
--------------
     new, new!, reduce


Instance methods:
-----------------
     %, *, **, **, +, -, /, <=>, ==, abs, coerce, divmod, hash, inspect,
     inspect, power2, to_f, to_i, to_r, to_s

Attributes:
     denominator, numerator

=end
class Rational < Numeric
  include Comparable

  # ------------------------------------------------------- Rational::reduce
  #      Rational::reduce(num, den = 1)
  # ------------------------------------------------------------------------
  #      Reduces the given numerator and denominator to their lowest terms.
  #      Use Rational() instead.
  # 
  def self.reduce(arg0, arg1, arg2, *rest)
  end

  # --------------------------------------------------------- Rational::new!
  #      Rational::new!(num, den = 1)
  # ------------------------------------------------------------------------
  #      Implements the constructor. This method does not reduce to lowest
  #      terms or check for division by zero. Therefore #Rational() should
  #      be preferred in normal use.
  # 
  def self.new!(arg0, arg1, arg2, *rest)
  end

  # ------------------------------------------------------------ Rational#**
  #      **(other)
  # ------------------------------------------------------------------------
  #      Returns this value raised to the given power.
  # 
  #      Examples:
  # 
  #        r = Rational(3,4)    # -> Rational(3,4)
  #        r ** 2               # -> Rational(9,16)
  #        r ** 2.0             # -> 0.5625
  #        r ** Rational(1,2)   # -> 0.866025403784439
  # 
  def **
  end

  # ------------------------------------------------------------- Rational#-
  #      -(a)
  # ------------------------------------------------------------------------
  #      Returns the difference of this value and +a+. subtracted.
  # 
  #      Examples:
  # 
  #        r = Rational(3,4)    # -> Rational(3,4)
  #        r - 1                # -> Rational(-1,4)
  #        r - 0.5              # -> 0.25
  # 
  def -
  end

  # -------------------------------------------------------- Rational#divmod
  #      divmod(other)
  # ------------------------------------------------------------------------
  #      Returns the quotient _and_ remainder.
  # 
  #      Examples:
  # 
  #        r = Rational(7,4)        # -> Rational(7,4)
  #        r.divmod Rational(1,2)   # -> [3, Rational(1,4)]
  # 
  def divmod
  end

  # ----------------------------------------------------------- Rational#<=>
  #      <=>(other)
  # ------------------------------------------------------------------------
  #      Standard comparison operator.
  # 
  def <=>
  end

  # ---------------------------------------------------------- Rational#to_f
  #      to_f()
  # ------------------------------------------------------------------------
  #      Converts the rational to a Float.
  # 
  def to_f
  end

  # ------------------------------------------------------------ Rational#==
  #      ==(other)
  # ------------------------------------------------------------------------
  #      Returns +true+ iff this value is numerically equal to +other+.
  # 
  #      But beware:
  # 
  #        Rational(1,2) == Rational(4,8)          # -> true
  #        Rational(1,2) == Rational.new!(4,8)     # -> false
  # 
  #      Don't use Rational.new!
  # 
  def ==
  end

  # ---------------------------------------------------------- Rational#to_s
  #      to_s()
  # ------------------------------------------------------------------------
  #      Returns a string representation of the rational number.
  # 
  #      Example:
  # 
  #        Rational(3,4).to_s          #  "3/4"
  #        Rational(8).to_s            #  "8"
  # 
  def to_s
  end

  # ------------------------------------------------------------- Rational#/
  #      /(a)
  # ------------------------------------------------------------------------
  #      Returns the quotient of this value and +a+.
  # 
  #        r = Rational(3,4)    # -> Rational(3,4)
  #        r / 2                # -> Rational(3,8)
  #        r / 2.0              # -> 0.375
  #        r / Rational(1,2)    # -> Rational(3,2)
  # 
  def /
  end

  # ----------------------------------------------------------- Rational#abs
  #      abs()
  # ------------------------------------------------------------------------
  #      Returns the absolute value.
  # 
  def abs
  end

  # ---------------------------------------------------------- Rational#hash
  #      hash()
  # ------------------------------------------------------------------------
  #      Returns a hash code for the object.
  # 
  def hash
  end

  def numerator
  end

  # ------------------------------------------------------------- Rational#%
  #      %(other)
  # ------------------------------------------------------------------------
  #      Returns the remainder when this value is divided by +other+.
  # 
  #      Examples:
  # 
  #        r = Rational(7,4)    # -> Rational(7,4)
  #        r % Rational(1,2)    # -> Rational(1,4)
  #        r % 1                # -> Rational(3,4)
  #        r % Rational(1,7)    # -> Rational(1,28)
  #        r % 0.26             # -> 0.19
  # 
  def %
  end

  # ---------------------------------------------------------- Rational#to_i
  #      to_i()
  # ------------------------------------------------------------------------
  #      Converts the rational to an Integer. Not the _nearest_ integer, the
  #      truncated integer. Study the following example carefully:
  # 
  #        Rational(+7,4).to_i             # -> 1
  #        Rational(-7,4).to_i             # -> -2
  #        (-1.75).to_i                    # -> -1
  # 
  #      In other words:
  # 
  #        Rational(-7,4) == -1.75                 # -> true
  #        Rational(-7,4).to_i == (-1.75).to_i     # false
  # 
  def to_i
  end

  # ---------------------------------------------------------- Rational#to_r
  #      to_r()
  # ------------------------------------------------------------------------
  #      Returns +self+.
  # 
  def to_r
  end

  # -------------------------------------------------------- Rational#coerce
  #      coerce(other)
  # ------------------------------------------------------------------------
  #      (no description...)
  def coerce
  end

  # ------------------------------------------------------------- Rational#*
  #      *(a)
  # ------------------------------------------------------------------------
  #      Returns the product of this value and +a+.
  # 
  #      Examples:
  # 
  #        r = Rational(3,4)    # -> Rational(3,4)
  #        r * 2                # -> Rational(3,2)
  #        r * 4                # -> Rational(3,1)
  #        r * 0.5              # -> 0.375
  #        r * Rational(1,2)    # -> Rational(3,8)
  # 
  def *
  end

  def denominator
  end

  # ------------------------------------------------------------- Rational#+
  #      +(a)
  # ------------------------------------------------------------------------
  #      Returns the addition of this value and +a+.
  # 
  #      Examples:
  # 
  #        r = Rational(3,4)      # -> Rational(3,4)
  #        r + 1                  # -> Rational(7,4)
  #        r + 0.5                # -> 1.25
  # 
  def +
  end

  # ------------------------------------------------------- Rational#inspect
  #      inspect()
  # ------------------------------------------------------------------------
  #      Returns a reconstructable string representation:
  # 
  #        Rational(5,8).inspect     # -> "Rational(5, 8)"
  # 
  def inspect
  end

end
