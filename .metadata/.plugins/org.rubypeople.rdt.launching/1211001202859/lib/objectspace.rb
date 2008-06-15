=begin
----------------------------------------------------- Class: ObjectSpace
     The +ObjectSpace+ module contains a number of routines that
     interact with the garbage collection facility and allow you to
     traverse all living objects with an iterator.

     +ObjectSpace+ also provides support for object finalizers, procs
     that will be called when a specific object is about to be destroyed
     by garbage collection.

        include ObjectSpace
     
        a = "A"
        b = "B"
        c = "C"
     
        define_finalizer(a, proc {|id| puts "Finalizer one on #{id}" })
        define_finalizer(a, proc {|id| puts "Finalizer two on #{id}" })
        define_finalizer(b, proc {|id| puts "Finalizer three on #{id}" })

     _produces:_

        Finalizer three on 537763470
        Finalizer one on 537763480
        Finalizer two on 537763480

------------------------------------------------------------------------


Class methods:
--------------
     _id2ref, add_finalizer, call_finalizer, define_finalizer,
     each_object, finalizers, garbage_collect, remove_finalizer,
     undefine_finalizer

=end
module ObjectSpace

  # --------------------------------------------- ObjectSpace::add_finalizer
  #      ObjectSpace::add_finalizer(p1)
  # ------------------------------------------------------------------------
  #      deprecated
  # 
  def self.add_finalizer(arg0)
  end

  # -------------------------------------------- ObjectSpace::call_finalizer
  #      ObjectSpace::call_finalizer(p1)
  # ------------------------------------------------------------------------
  #      deprecated
  # 
  def self.call_finalizer(arg0)
  end

  # ----------------------------------------------- ObjectSpace::each_object
  #      ObjectSpace.each_object([module]) {|obj| ... } => fixnum
  # ------------------------------------------------------------------------
  #      Calls the block once for each living, nonimmediate object in this
  #      Ruby process. If _module_ is specified, calls the block for only
  #      those classes or modules that match (or are a subclass of)
  #      _module_. Returns the number of objects found. Immediate objects
  #      (+Fixnum+s, +Symbol+s +true+, +false+, and +nil+) are never
  #      returned. In the example below, +each_object+ returns both the
  #      numbers we defined and several constants defined in the +Math+
  #      module.
  # 
  #         a = 102.7
  #         b = 95       # Won't be returned
  #         c = 12345678987654321
  #         count = ObjectSpace.each_object(Numeric) {|x| p x }
  #         puts "Total count: #{count}"
  # 
  #      _produces:_
  # 
  #         12345678987654321
  #         102.7
  #         2.71828182845905
  #         3.14159265358979
  #         2.22044604925031e-16
  #         1.7976931348623157e+308
  #         2.2250738585072e-308
  #         Total count: 7
  # 
  def self.each_object(arg0, arg1, *rest)
  end

  # --------------------------------------------------- ObjectSpace::_id2ref
  #      ObjectSpace._id2ref(object_id) -> an_object
  # ------------------------------------------------------------------------
  #      Converts an object id to a reference to the object. May not be
  #      called on an object id passed as a parameter to a finalizer.
  # 
  #         s = "I am a string"                    #=> "I am a string"
  #         r = ObjectSpace._id2ref(s.object_id)   #=> "I am a string"
  #         r == s                                 #=> true
  # 
  def self._id2ref(arg0)
  end

  # ------------------------------------------------ ObjectSpace::finalizers
  #      ObjectSpace::finalizers()
  # ------------------------------------------------------------------------
  #      deprecated
  # 
  def self.finalizers
  end

  # ---------------------------------------- ObjectSpace::undefine_finalizer
  #      ObjectSpace.undefine_finalizer(obj)
  # ------------------------------------------------------------------------
  #      Removes all finalizers for _obj_.
  # 
  def self.undefine_finalizer(arg0)
  end

  # ------------------------------------------ ObjectSpace::remove_finalizer
  #      ObjectSpace::remove_finalizer(p1)
  # ------------------------------------------------------------------------
  #      deprecated
  # 
  def self.remove_finalizer(arg0)
  end

  # ------------------------------------------- ObjectSpace::garbage_collect
  #      GC.start                     => nil
  #      gc.garbage_collect           => nil
  #      ObjectSpace.garbage_collect  => nil
  # ------------------------------------------------------------------------
  #      Initiates garbage collection, unless manually disabled.
  # 
  def self.garbage_collect
  end

  # ------------------------------------------ ObjectSpace::define_finalizer
  #      ObjectSpace.define_finalizer(obj, aProc=proc())
  # ------------------------------------------------------------------------
  #      Adds _aProc_ as a finalizer, to be called after _obj_ was
  #      destroyed.
  # 
  def self.define_finalizer(arg0, arg1, *rest)
  end

end
