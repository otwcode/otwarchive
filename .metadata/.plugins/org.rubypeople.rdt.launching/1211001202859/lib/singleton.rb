=begin
------------------------------------------------------- Class: Singleton
     The Singleton module implements the Singleton pattern.

     Usage:

        class Klass
           include Singleton
           # ...
        end

     *   this ensures that only one instance of Klass lets call it ``the
         instance'' can be created.

     a,b = Klass.instance, Klass.instance a == b # => true a.new #
     NoMethodError - new is private ...

     *   ``The instance'' is created at instantiation time, in other
         words the first call of Klass.instance(), thus

       class OtherKlass
         include Singleton
         # ...
       end
       ObjectSpace.each_object(OtherKlass){} # => 0.

     *   This behavior is preserved under inheritance and cloning.

     This is achieved by marking

     *   Klass.new and Klass.allocate - as private

     Providing (or modifying) the class methods

     *   Klass.inherited(sub_klass) and Klass.clone() - to ensure that
         the Singleton pattern is properly inherited and cloned.

     *   Klass.instance() - returning ``the instance''. After a
         successful self modifying (normally the first) call the method
         body is a simple:

        def Klass.instance()
          return @<em>instance</em>
        end

     *   Klass._load(str) - calling Klass.instance()

     *   Klass._instantiate?() - returning ``the instance'' or nil. This
         hook method puts a second (or nth) thread calling
         Klass.instance() on a waiting loop. The return value signifies
         the successful completion or premature termination of the
         first, or more generally, current "instantiation thread".

     The instance method of Singleton are

     *   clone and dup - raising TypeErrors to prevent cloning or duping

     *   _dump(depth) - returning the empty string. Marshalling strips
         by default all state information, e.g. instance variables and
         taint state, from ``the instance''. Providing custom _load(str)
         and _dump(depth) hooks allows the (partially) resurrections of
         a previous state of ``the instance''.

------------------------------------------------------------------------


Instance methods:
-----------------
     _dump, clone, dup

=end
module Singleton

  def self.__init__(arg0)
  end

  # ---------------------------------------------------------- Singleton#dup
  #      dup()
  # ------------------------------------------------------------------------
  #      (no description...)
  def dup
  end

  # -------------------------------------------------------- Singleton#clone
  #      clone()
  # ------------------------------------------------------------------------
  #      disable build-in copying methods
  # 
  def clone
  end

end
