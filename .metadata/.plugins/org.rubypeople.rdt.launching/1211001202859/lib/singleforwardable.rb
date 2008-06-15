=begin
----------------------------------------------- Class: SingleForwardable
     The SingleForwardable module provides delegation of specified
     methods to a designated object, using the methods #def_delegator
     and #def_delegators. This module is similar to Forwardable, but it
     works on objects themselves, instead of their defining classes.

     Also see the example at forwardable.rb.

------------------------------------------------------------------------


Instance methods:
-----------------
     def_delegator, def_delegators, def_singleton_delegator,
     def_singleton_delegators

=end
module SingleForwardable

  # ---------------------------------------- SingleForwardable#def_delegator
  #      def_delegator(accessor, method, ali = method)
  # ------------------------------------------------------------------------
  #      Alias for #def_singleton_delegator
  # 
  def def_delegator(arg0, arg1, arg2, arg3, *rest)
  end

  # ------------------------------ SingleForwardable#def_singleton_delegator
  #      def_singleton_delegator(accessor, method, ali = method)
  # ------------------------------------------------------------------------
  #      Defines a method _method_ which delegates to _obj_ (i.e. it calls
  #      the method of the same name in _obj_). If _new_name_ is provided,
  #      it is used as the name for the delegate method.
  # 
  #      See the example at forwardable.rb.
  # 
  # 
  #      (also known as def_delegator)
  def def_singleton_delegator(arg0, arg1, arg2, arg3, *rest)
  end

  # ----------------------------- SingleForwardable#def_singleton_delegators
  #      def_singleton_delegators(accessor, *methods)
  # ------------------------------------------------------------------------
  #      Shortcut for defining multiple delegator methods, but with no
  #      provision for using a different name. The following two code
  #      samples have the same effect:
  # 
  #        single_forwardable.def_delegators :@records, :size, :<<, :map
  #      
  #        single_forwardable.def_delegator :@records, :size
  #        single_forwardable.def_delegator :@records, :<<
  #        single_forwardable.def_delegator :@records, :map
  # 
  #      See the example at forwardable.rb.
  # 
  # 
  #      (also known as def_delegators)
  def def_singleton_delegators(arg0, arg1, arg2, *rest)
  end

  # --------------------------------------- SingleForwardable#def_delegators
  #      def_delegators(accessor, *methods)
  # ------------------------------------------------------------------------
  #      Alias for #def_singleton_delegators
  # 
  def def_delegators(arg0, arg1, arg2, *rest)
  end

end
