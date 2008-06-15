=begin
------------------------------------------------------ Class: Comparable
     The +Comparable+ mixin is used by classes whose objects may be
     ordered. The class must define the +<=>+ operator, which compares
     the receiver against another object, returning -1, 0, or +1
     depending on whether the receiver is less than, equal to, or
     greater than the other object. +Comparable+ uses +<=>+ to implement
     the conventional comparison operators (+<+, +<=+, +==+, +>=+, and
     +>+) and the method +between?+.

        class SizeMatters
          include Comparable
          attr :str
          def <=>(anOther)
            str.size <=> anOther.str.size
          end
          def initialize(str)
            @str = str
          end
          def inspect
            @str
          end
        end
     
        s1 = SizeMatters.new("Z")
        s2 = SizeMatters.new("YY")
        s3 = SizeMatters.new("XXX")
        s4 = SizeMatters.new("WWWW")
        s5 = SizeMatters.new("VVVVV")
     
        s1 < s2                       #=> true
        s4.between?(s1, s3)           #=> false
        s4.between?(s3, s5)           #=> true
        [ s3, s2, s5, s4, s1 ].sort   #=> [Z, YY, XXX, WWWW, VVVVV]

------------------------------------------------------------------------


Instance methods:
-----------------
     <, <=, ==, >, >=, between?

=end
module Comparable

  # ---------------------------------------------------------- Comparable#==
  #      obj == other    => true or false
  # ------------------------------------------------------------------------
  #      Compares two objects based on the receiver's +<=>+ method,
  #      returning true if it returns 0. Also returns true if _obj_ and
  #      _other_ are the same object.
  # 
  def ==(arg0)
  end

  # ---------------------------------------------------------- Comparable#>=
  #      obj >= other    => true or false
  # ------------------------------------------------------------------------
  #      Compares two objects based on the receiver's +<=>+ method,
  #      returning true if it returns 0 or 1.
  # 
  def >=(arg0)
  end

  # ----------------------------------------------------------- Comparable#<
  #      obj < other    => true or false
  # ------------------------------------------------------------------------
  #      Compares two objects based on the receiver's +<=>+ method,
  #      returning true if it returns -1.
  # 
  def <(arg0)
  end

  # ---------------------------------------------------------- Comparable#<=
  #      obj <= other    => true or false
  # ------------------------------------------------------------------------
  #      Compares two objects based on the receiver's +<=>+ method,
  #      returning true if it returns -1 or 0.
  # 
  def <=(arg0)
  end

  # ----------------------------------------------------------- Comparable#>
  #      obj > other    => true or false
  # ------------------------------------------------------------------------
  #      Compares two objects based on the receiver's +<=>+ method,
  #      returning true if it returns 1.
  # 
  def >(arg0)
  end

  # ---------------------------------------------------- Comparable#between?
  #      obj.between?(min, max)    => true or false
  # ------------------------------------------------------------------------
  #      Returns +false+ if _obj_ +<=>+ _min_ is less than zero or if
  #      _anObject_ +<=>+ _max_ is greater than zero, +true+ otherwise.
  # 
  #         3.between?(1, 5)               #=> true
  #         6.between?(1, 5)               #=> false
  #         'cat'.between?('ant', 'dog')   #=> true
  #         'gnu'.between?('ant', 'dog')   #=> false
  # 
  def between?(arg0, arg1)
  end

end
