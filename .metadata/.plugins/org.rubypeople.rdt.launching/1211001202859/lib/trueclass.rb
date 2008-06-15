=begin
------------------------------------------------------- Class: TrueClass
     The global value +true+ is the only instance of class +TrueClass+
     and represents a logically true value in boolean expressions. The
     class provides operators allowing +true+ to be used in logical
     expressions.

------------------------------------------------------------------------


Instance methods:
-----------------
     &, ^, to_param, to_s, to_yaml, |

=end
class TrueClass < Object

  def self.yaml_tag_subclasses?
  end

  # --------------------------------------------------------- TrueClass#to_s
  #      true.to_s   =>  "true"
  # ------------------------------------------------------------------------
  #      The string representation of +true+ is "true".
  # 
  def to_s
  end

  def taguri=(arg0)
  end

  # ------------------------------------------------------------ TrueClass#|
  #      true | obj   => true
  # ------------------------------------------------------------------------
  #      Or---Returns +true+. As _anObject_ is an argument to a method call,
  #      it is always evaluated; there is no short-circuit evaluation in
  #      this case.
  # 
  #         true |  puts("or")
  #         true || puts("logical or")
  # 
  #      _produces:_
  # 
  #         or
  # 
  def |(arg0)
  end

  # ------------------------------------------------------------ TrueClass#&
  #      true & obj    => true or false
  # ------------------------------------------------------------------------
  #      And---Returns +false+ if _obj_ is +nil+ or +false+, +true+
  #      otherwise.
  # 
  def &(arg0)
  end

  # ------------------------------------------------------------ TrueClass#^
  #      true ^ obj   => !obj
  # ------------------------------------------------------------------------
  #      Exclusive Or---Returns +true+ if _obj_ is +nil+ or +false+, +false+
  #      otherwise.
  # 
  def ^(arg0)
  end

  def taguri
  end

  # ------------------------------------------------------ TrueClass#to_yaml
  #      to_yaml( opts = {} )
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml(arg0, arg1, *rest)
  end

end
