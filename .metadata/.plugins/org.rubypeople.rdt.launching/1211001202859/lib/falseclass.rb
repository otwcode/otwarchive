=begin
------------------------------------------------------ Class: FalseClass
     The global value +false+ is the only instance of class +FalseClass+
     and represents a logically false value in boolean expressions. The
     class provides operators allowing +false+ to participate correctly
     in logical expressions.

------------------------------------------------------------------------


Instance methods:
-----------------
     &, ^, to_param, to_s, to_yaml, |

=end
class FalseClass < Object

  def self.yaml_tag_subclasses?
  end

  # -------------------------------------------------------- FalseClass#to_s
  #      false.to_s   =>  "false"
  # ------------------------------------------------------------------------
  #      'nuf said...
  # 
  def to_s
  end

  def taguri=(arg0)
  end

  # ----------------------------------------------------------- FalseClass#|
  #      false | obj   =>   true or false
  #      nil   | obj   =>   true or false
  # ------------------------------------------------------------------------
  #      Or---Returns +false+ if _obj_ is +nil+ or +false+; +true+
  #      otherwise.
  # 
  def |(arg0)
  end

  # ----------------------------------------------------------- FalseClass#&
  #      false & obj   => false
  #      nil & obj     => false
  # ------------------------------------------------------------------------
  #      And---Returns +false+. _obj_ is always evaluated as it is the
  #      argument to a method call---there is no short-circuit evaluation in
  #      this case.
  # 
  def &(arg0)
  end

  # ----------------------------------------------------------- FalseClass#^
  #      false ^ obj    => true or false
  #      nil   ^ obj    => true or false
  # ------------------------------------------------------------------------
  #      Exclusive Or---If _obj_ is +nil+ or +false+, returns +false+;
  #      otherwise, returns +true+.
  # 
  def ^(arg0)
  end

  def taguri
  end

  # ----------------------------------------------------- FalseClass#to_yaml
  #      to_yaml( opts = {} )
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml(arg0, arg1, *rest)
  end

end
