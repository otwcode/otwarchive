=begin
-------------------------------------------------------------- Class: GC
     The +GC+ module provides an interface to Ruby's mark and sweep
     garbage collection mechanism. Some of the underlying methods are
     also available via the +ObjectSpace+ module.

------------------------------------------------------------------------


Class methods:
--------------
     disable, enable, start


Instance methods:
-----------------
     garbage_collect

=end
module GC

  # ------------------------------------------------------------ GC::disable
  #      GC.disable    => true or false
  # ------------------------------------------------------------------------
  #      Disables garbage collection, returning +true+ if garbage collection
  #      was already disabled.
  # 
  #         GC.disable   #=> false
  #         GC.disable   #=> true
  # 
  def self.disable
  end

  # ------------------------------------------------------------- GC::enable
  #      GC.enable    => true or false
  # ------------------------------------------------------------------------
  #      Enables garbage collection, returning +true+ if garbage collection
  #      was previously disabled.
  # 
  #         GC.disable   #=> false
  #         GC.enable    #=> true
  #         GC.enable    #=> false
  # 
  def self.enable
  end

  # -------------------------------------------------------------- GC::start
  #      GC.start                     => nil
  #      gc.garbage_collect           => nil
  #      ObjectSpace.garbage_collect  => nil
  # ------------------------------------------------------------------------
  #      Initiates garbage collection, unless manually disabled.
  # 
  def self.start
  end

  # ----------------------------------------------------- GC#garbage_collect
  #      GC.start                     => nil
  #      gc.garbage_collect           => nil
  #      ObjectSpace.garbage_collect  => nil
  # ------------------------------------------------------------------------
  #      Initiates garbage collection, unless manually disabled.
  # 
  def garbage_collect
  end

end
