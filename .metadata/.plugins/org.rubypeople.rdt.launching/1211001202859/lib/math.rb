=begin
------------------------------------------------------------ Class: Math
     The +Math+ module contains module functions for basic trigonometric
     and transcendental functions. See class +Float+ for a list of
     constants that define Ruby's floating point accuracy.

------------------------------------------------------------------------


Constants:
----------
     PI: rb_float_new(M_PI)
     PI: rb_float_new(atan(1.0)*4.0)
     E:  rb_float_new(M_E)
     E:  rb_float_new(exp(1.0))


Class methods:
--------------
     acos, acosh, asin, asinh, atan, atan2, atanh, cos, cosh, erf, erfc,
     exp, frexp, hypot, ldexp, log, log10, sin, sinh, sqrt, tan, tanh


Instance methods:
-----------------
     acos, acosh, asin, asinh, atan, atan2, atanh, cos, cosh, exp, log,
     log10, rsqrt, sin, sinh, sqrt, sqrt, tan, tanh

=end
module Math

  # ------------------------------------------------------------- Math::atan
  #      Math.atan(x)    => float
  # ------------------------------------------------------------------------
  #      Computes the arc tangent of _x_. Returns -{PI/2} .. {PI/2}.
  # 
  def self.atan(arg0)
  end

  # ------------------------------------------------------------ Math::frexp
  #      Math.frexp(numeric)    => [ fraction, exponent ]
  # ------------------------------------------------------------------------
  #      Returns a two-element array containing the normalized fraction (a
  #      +Float+) and exponent (a +Fixnum+) of _numeric_.
  # 
  #         fraction, exponent = Math.frexp(1234)   #=> [0.6025390625, 11]
  #         fraction * 2**exponent                  #=> 1234.0
  # 
  def self.frexp(arg0)
  end

  # -------------------------------------------------------------- Math::sin
  #      Math.sin(x)    => float
  # ------------------------------------------------------------------------
  #      Computes the sine of _x_ (expressed in radians). Returns -1..1.
  # 
  def self.sin(arg0)
  end

  # -------------------------------------------------------------- Math::exp
  #      Math.exp(x)    => float
  # ------------------------------------------------------------------------
  #      Returns e**x.
  # 
  def self.exp(arg0)
  end

  # ------------------------------------------------------------- Math::tanh
  #      Math.tanh()    => float
  # ------------------------------------------------------------------------
  #      Computes the hyperbolic tangent of _x_ (expressed in radians).
  # 
  def self.tanh(arg0)
  end

  # -------------------------------------------------------------- Math::erf
  #      Math.erf(x)  => float
  # ------------------------------------------------------------------------
  #      Calculates the error function of x.
  # 
  def self.erf(arg0)
  end

  # ------------------------------------------------------------- Math::asin
  #      Math.asin(x)    => float
  # ------------------------------------------------------------------------
  #      Computes the arc sine of _x_. Returns 0..PI.
  # 
  def self.asin(arg0)
  end

  # ------------------------------------------------------------- Math::sqrt
  #      Math.sqrt(numeric)    => float
  # ------------------------------------------------------------------------
  #      Returns the non-negative square root of _numeric_.
  # 
  def self.sqrt(arg0)
  end

  # -------------------------------------------------------------- Math::cos
  #      Math.cos(x)    => float
  # ------------------------------------------------------------------------
  #      Computes the cosine of _x_ (expressed in radians). Returns -1..1.
  # 
  def self.cos(arg0)
  end

  # ------------------------------------------------------------ Math::atanh
  #      Math.atanh(x)    => float
  # ------------------------------------------------------------------------
  #      Computes the inverse hyperbolic tangent of _x_.
  # 
  def self.atanh(arg0)
  end

  # ------------------------------------------------------------- Math::sinh
  #      Math.sinh(x)    => float
  # ------------------------------------------------------------------------
  #      Computes the hyperbolic sine of _x_ (expressed in radians).
  # 
  def self.sinh(arg0)
  end

  # ------------------------------------------------------------ Math::hypot
  #      Math.hypot(x, y)    => float
  # ------------------------------------------------------------------------
  #      Returns sqrt(x**2 + y**2), the hypotenuse of a right-angled
  #      triangle with sides _x_ and _y_.
  # 
  #         Math.hypot(3, 4)   #=> 5.0
  # 
  def self.hypot(arg0, arg1)
  end

  # ------------------------------------------------------------- Math::acos
  #      Math.acos(x)    => float
  # ------------------------------------------------------------------------
  #      Computes the arc cosine of _x_. Returns 0..PI.
  # 
  def self.acos(arg0)
  end

  # ------------------------------------------------------------ Math::log10
  #      Math.log10(numeric)    => float
  # ------------------------------------------------------------------------
  #      Returns the base 10 logarithm of _numeric_.
  # 
  def self.log10(arg0)
  end

  # ------------------------------------------------------------ Math::atan2
  #      Math.atan2(y, x)  => float
  # ------------------------------------------------------------------------
  #      Computes the arc tangent given _y_ and _x_. Returns -PI..PI.
  # 
  def self.atan2(arg0, arg1)
  end

  # ------------------------------------------------------------ Math::asinh
  #      Math.asinh(x)    => float
  # ------------------------------------------------------------------------
  #      Computes the inverse hyperbolic sine of _x_.
  # 
  def self.asinh(arg0)
  end

  # ------------------------------------------------------------- Math::cosh
  #      Math.cosh(x)    => float
  # ------------------------------------------------------------------------
  #      Computes the hyperbolic cosine of _x_ (expressed in radians).
  # 
  def self.cosh(arg0)
  end

  # ------------------------------------------------------------ Math::ldexp
  #      Math.ldexp(flt, int) -> float
  # ------------------------------------------------------------------------
  #      Returns the value of _flt_*(2**_int_).
  # 
  #         fraction, exponent = Math.frexp(1234)
  #         Math.ldexp(fraction, exponent)   #=> 1234.0
  # 
  def self.ldexp(arg0, arg1)
  end

  # -------------------------------------------------------------- Math::tan
  #      Math.tan(x)    => float
  # ------------------------------------------------------------------------
  #      Returns the tangent of _x_ (expressed in radians).
  # 
  def self.tan(arg0)
  end

  # -------------------------------------------------------------- Math::log
  #      Math.log(numeric)    => float
  # ------------------------------------------------------------------------
  #      Returns the natural logarithm of _numeric_.
  # 
  def self.log(arg0)
  end

  # ------------------------------------------------------------ Math::acosh
  #      Math.acosh(x)    => float
  # ------------------------------------------------------------------------
  #      Computes the inverse hyperbolic cosine of _x_.
  # 
  def self.acosh(arg0)
  end

  # ------------------------------------------------------------- Math::erfc
  #      Math.erfc(x)  => float
  # ------------------------------------------------------------------------
  #      Calculates the complementary error function of x.
  # 
  def self.erfc(arg0)
  end

end
