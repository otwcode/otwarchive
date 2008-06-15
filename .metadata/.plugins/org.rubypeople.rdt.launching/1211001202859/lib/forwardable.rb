=begin
----------------------------------------------------- Class: Forwardable
     The Forwardable module provides delegation of specified methods to
     a designated object, using the methods #def_delegator and
     #def_delegators.

     For example, say you have a class RecordCollection which contains
     an array +@records+. You could provide the lookup method
     #record_number(), which simply calls #[] on the +@records+ array,
     like this:

       class RecordCollection
         extend Forwardable
         def_delegator :@records, :[], :record_number
       end

     Further, if you wish to provide the methods #size, #<<, and #map,
     all of which delegate to @records, this is how you can do it:

       class RecordCollection
         # extend Forwardable, but we did that above
         def_delegators :@records, :size, :<<, :map
       end

     Also see the example at forwardable.rb.

------------------------------------------------------------------------


Instance methods:
-----------------
     def_delegator, def_delegators, def_instance_delegator,
     def_instance_delegators

Attributes:
     debug

=end
module Forwardable

  def self.debug
  end

  def self.debug=(arg0)
  end

  # ---------------------------------------------- Forwardable#def_delegator
  #      def_delegator(accessor, method, ali = method)
  # ------------------------------------------------------------------------
  #      Alias for #def_instance_delegator
  # 
  def def_delegator(arg0, arg1, arg2, arg3, *rest)
  end

  # ------------------------------------ Forwardable#def_instance_delegators
  #      def_instance_delegators(accessor, *methods)
  # ------------------------------------------------------------------------
  #      Shortcut for defining multiple delegator methods, but with no
  #      provision for using a different name. The following two code
  #      samples have the same effect:
  # 
  #        def_delegators :@records, :size, :<<, :map
  #      
  #        def_delegator :@records, :size
  #        def_delegator :@records, :<<
  #        def_delegator :@records, :map
  # 
  #      See the examples at Forwardable and forwardable.rb.
  # 
  # 
  #      (also known as def_delegators)
  def def_instance_delegators(arg0, arg1, arg2, *rest)
  end

  # --------------------------------------------- Forwardable#def_delegators
  #      def_delegators(accessor, *methods)
  # ------------------------------------------------------------------------
  #      Alias for #def_instance_delegators
  # 
  def def_delegators(arg0, arg1, arg2, *rest)
  end

  # ------------------------------------- Forwardable#def_instance_delegator
  #      def_instance_delegator(accessor, method, ali = method)
  # ------------------------------------------------------------------------
  #      Defines a method _method_ which delegates to _obj_ (i.e. it calls
  #      the method of the same name in _obj_). If _new_name_ is provided,
  #      it is used as the name for the delegate method.
  # 
  #      See the examples at Forwardable and forwardable.rb.
  # 
  # 
  #      (also known as def_delegator)
  def def_instance_delegator(arg0, arg1, arg2, arg3, *rest)
  end

end
