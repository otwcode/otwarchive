=begin
------------------------------------------------- Class: Float < Numeric
     +Float+ objects represent real numbers using the native
     architecture's double-precision floating point representation.

------------------------------------------------------------------------


Includes:
---------
     Precision(prec, prec_f, prec_i)


Constants:
----------
     DIG:        INT2FIX(DBL_DIG)
     EPSILON:    rb_float_new(DBL_EPSILON)
     MANT_DIG:   INT2FIX(DBL_MANT_DIG)
     MAX:        rb_float_new(DBL_MAX)
     MAX_10_EXP: INT2FIX(DBL_MAX_10_EXP)
     MAX_EXP:    INT2FIX(DBL_MAX_EXP)
     MIN:        rb_float_new(DBL_MIN)
     MIN_10_EXP: INT2FIX(DBL_MIN_10_EXP)
     MIN_EXP:    INT2FIX(DBL_MIN_EXP)
     RADIX:      INT2FIX(FLT_RADIX)
     ROUNDS:     INT2FIX(FLT_ROUNDS)


Class methods:
--------------
     induced_from


Instance methods:
-----------------
     %, *, **, +, -, -@, /, <, <=, <=>, ==, >, >=, abs, ceil, coerce,
     dclone, divmod, eql?, finite?, floor, hash, infinite?, modulo,
     nan?, round, to_f, to_i, to_int, to_s, to_yaml, truncate, zero?

=end
class Float < Numeric
  include Precision
  include Comparable

  # ---------------------------------------------------- Float::induced_from
  #      Float.induced_from(obj)    =>  float
  # ------------------------------------------------------------------------
  #      Convert +obj+ to a float.
  # 
  def self.induced_from(arg0)
  end

  def self.yaml_tag_subclasses?
  end

  # --------------------------------------------------------------- Float#**
  # ------------------------------------------------------------------------
  #       flt ** other   => float
  # 
  #      Raises +float+ the +other+ power.
  # 
  def **(arg0)
  end

  # ------------------------------------------------------------- Float#eql?
  #      flt.eql?(obj)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ only if _obj_ is a +Float+ with the same value as
  #      _flt_. Contrast this with +Float#==+, which performs type
  #      conversions.
  # 
  #         1.0.eql?(1)   #=> false
  # 
  def eql?(arg0)
  end

  # -------------------------------------------------------- Float#infinite?
  #      flt.infinite? -> nil, -1, +1
  # ------------------------------------------------------------------------
  #      Returns +nil+, -1, or +1 depending on whether _flt_ is finite,
  #      -infinity, or +infinity.
  # 
  #         (0.0).infinite?        #=> nil
  #         (-1.0/0.0).infinite?   #=> -1
  #         (+1.0/0.0).infinite?   #=> 1
  # 
  def infinite?
  end

  # ---------------------------------------------------------------- Float#-
  #      float + other   => float
  # ------------------------------------------------------------------------
  #      Returns a new float which is the difference of +float+ and +other+.
  # 
  def -(arg0)
  end

  # ----------------------------------------------------------- Float#divmod
  #      flt.divmod(numeric)    => array
  # ------------------------------------------------------------------------
  #      See +Numeric#divmod+.
  # 
  def divmod(arg0)
  end

  # -------------------------------------------------------------- Float#<=>
  #      flt <=> numeric   => -1, 0, +1
  # ------------------------------------------------------------------------
  #      Returns -1, 0, or +1 depending on whether _flt_ is less than, equal
  #      to, or greater than _numeric_. This is the basis for the tests in
  #      +Comparable+.
  # 
  def <=>(arg0)
  end

  # ------------------------------------------------------------- Float#to_f
  #      flt.to_f   => flt
  # ------------------------------------------------------------------------
  #      As +flt+ is already a float, returns _self_.
  # 
  def to_f
  end

  # ------------------------------------------------------------- Float#to_s
  #      flt.to_s    => string
  # ------------------------------------------------------------------------
  #      Returns a string containing a representation of self. As well as a
  #      fixed or exponential form of the number, the call may return
  #      ``+NaN+'', ``+Infinity+'', and ``+-Infinity+''.
  # 
  def to_s
  end

  # --------------------------------------------------------------- Float#==
  #      flt == obj   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ only if _obj_ has the same value as _flt_. Contrast
  #      this with +Float#eql?+, which requires _obj_ to be a +Float+.
  # 
  #         1.0 == 1   #=> true
  # 
  def ==(arg0)
  end

  # ------------------------------------------------------------ Float#floor
  #      flt.floor   => integer
  # ------------------------------------------------------------------------
  #      Returns the largest integer less than or equal to _flt_.
  # 
  #         1.2.floor      #=> 1
  #         2.0.floor      #=> 2
  #         (-1.2).floor   #=> -2
  #         (-2.0).floor   #=> -2
  # 
  def floor
  end

  def taguri=(arg0)
  end

  # ---------------------------------------------------------------- Float#/
  #      float / other   => float
  # ------------------------------------------------------------------------
  #      Returns a new float which is the result of dividing +float+ by
  #      +other+.
  # 
  def /(arg0)
  end

  # ------------------------------------------------------------- Float#hash
  #      flt.hash   => integer
  # ------------------------------------------------------------------------
  #      Returns a hash code for this float.
  # 
  def hash
  end

  # -------------------------------------------------------------- Float#abs
  #      flt.abs    => float
  # ------------------------------------------------------------------------
  #      Returns the absolute value of _flt_.
  # 
  #         (-34.56).abs   #=> 34.56
  #         -34.56.abs     #=> 34.56
  # 
  def abs
  end

  # ------------------------------------------------------------ Float#zero?
  #      flt.zero? -> true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _flt_ is 0.0.
  # 
  def zero?
  end

  # ------------------------------------------------------------- Float#nan?
  #      flt.nan? -> true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _flt_ is an invalid IEEE floating point number.
  # 
  #         a = -1.0      #=> -1.0
  #         a.nan?        #=> false
  #         a = 0.0/0.0   #=> NaN
  #         a.nan?        #=> true
  # 
  def nan?
  end

  # ---------------------------------------------------------------- Float#%
  #      flt % other         => float
  #      flt.modulo(other)   => float
  # ------------------------------------------------------------------------
  #      Return the modulo after division of +flt+ by +other+.
  # 
  #         6543.21.modulo(137)      #=> 104.21
  #         6543.21.modulo(137.24)   #=> 92.9299999999996
  # 
  def %(arg0)
  end

  # ------------------------------------------------------------- Float#to_i
  #      flt.to_i       => integer
  #      flt.to_int     => integer
  #      flt.truncate   => integer
  # ------------------------------------------------------------------------
  #      Returns _flt_ truncated to an +Integer+.
  # 
  def to_i
  end

  # --------------------------------------------------------- Float#truncate
  #      flt.to_i       => integer
  #      flt.to_int     => integer
  #      flt.truncate   => integer
  # ------------------------------------------------------------------------
  #      Returns _flt_ truncated to an +Integer+.
  # 
  def truncate
  end

  # --------------------------------------------------------------- Float#>=
  #      flt >= other    =>  true or false
  # ------------------------------------------------------------------------
  #      +true+ if +flt+ is greater than or equal to +other+.
  # 
  def >=(arg0)
  end

  # ---------------------------------------------------------------- Float#<
  #      flt < other    =>  true or false
  # ------------------------------------------------------------------------
  #      +true+ if +flt+ is less than +other+.
  # 
  def <(arg0)
  end

  # --------------------------------------------------------------- Float#<=
  #      flt <= other    =>  true or false
  # ------------------------------------------------------------------------
  #      +true+ if +flt+ is less than or equal to +other+.
  # 
  def <=(arg0)
  end

  # ---------------------------------------------------------------- Float#>
  #      flt > other    =>  true or false
  # ------------------------------------------------------------------------
  #      +true+ if +flt+ is greater than +other+.
  # 
  def >(arg0)
  end

  # ------------------------------------------------------------ Float#round
  #      flt.round   => integer
  # ------------------------------------------------------------------------
  #      Rounds _flt_ to the nearest integer. Equivalent to:
  # 
  #         def round
  #           return (self+0.5).floor if self > 0.0
  #           return (self-0.5).ceil  if self < 0.0
  #           return 0
  #         end
  #      
  #         1.5.round      #=> 2
  #         (-1.5).round   #=> -2
  # 
  def round
  end

  # ----------------------------------------------------------- Float#coerce
  #      coerce(p1)
  # ------------------------------------------------------------------------
  #      MISSING: documentation
  # 
  def coerce(arg0)
  end

  # ----------------------------------------------------------- Float#to_int
  #      flt.to_i       => integer
  #      flt.to_int     => integer
  #      flt.truncate   => integer
  # ------------------------------------------------------------------------
  #      Returns _flt_ truncated to an +Integer+.
  # 
  def to_int
  end

  # ---------------------------------------------------------- Float#finite?
  #      flt.finite? -> true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _flt_ is a valid IEEE floating point number (it
  #      is not infinite, and +nan?+ is +false+).
  # 
  def finite?
  end

  # ---------------------------------------------------------------- Float#*
  #      float * other   => float
  # ------------------------------------------------------------------------
  #      Returns a new float which is the product of +float+ and +other+.
  # 
  def *(arg0)
  end

  # ----------------------------------------------------------- Float#modulo
  #      flt % other         => float
  #      flt.modulo(other)   => float
  # ------------------------------------------------------------------------
  #      Return the modulo after division of +flt+ by +other+.
  # 
  #         6543.21.modulo(137)      #=> 104.21
  #         6543.21.modulo(137.24)   #=> 92.9299999999996
  # 
  def modulo(arg0)
  end

  # --------------------------------------------------------------- Float#-@
  #      -float   => float
  # ------------------------------------------------------------------------
  #      Returns float, negated.
  # 
  def -@
  end

  # ---------------------------------------------------------------- Float#+
  #      float + other   => float
  # ------------------------------------------------------------------------
  #      Returns a new float which is the sum of +float+ and +other+.
  # 
  def +(arg0)
  end

  # ------------------------------------------------------------- Float#ceil
  #      flt.ceil    => integer
  # ------------------------------------------------------------------------
  #      Returns the smallest +Integer+ greater than or equal to _flt_.
  # 
  #         1.2.ceil      #=> 2
  #         2.0.ceil      #=> 2
  #         (-1.2).ceil   #=> -1
  #         (-2.0).ceil   #=> -2
  # 
  def ceil
  end

  def taguri
  end

  # ---------------------------------------------------------- Float#to_yaml
  #      to_yaml( opts = {} )
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml(arg0, arg1, *rest)
  end

end
