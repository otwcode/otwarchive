=begin
------------------------------------------------------- Class: Precision
     Precision is a mixin for concrete numeric classes with precision.
     Here, `precision' means the fineness of approximation of a real
     number, so, this module should not be included into anything which
     is not a subset of Real (so it should not be included in classes
     such as +Complex+ or +Matrix+).

------------------------------------------------------------------------


Class methods:
--------------
     included


Instance methods:
-----------------
     prec, prec_f, prec_i

=end
module Precision

  # ---------------------------------------------------- Precision::included
  #      Precision::included(p1)
  # ------------------------------------------------------------------------
  #      call_seq:
  # 
  #        included
  # 
  #      When the +Precision+ module is mixed-in to a class, this +included+
  #      method is used to add our default +induced_from+ implementation to
  #      the host class.
  # 
  def self.included(arg0)
  end

  # ------------------------------------------------------- Precision#prec_f
  #      num.prec_f  =>  Float
  # ------------------------------------------------------------------------
  #      Returns a +Float+ converted from _num_. It is equivalent to
  #      +prec(Float)+.
  # 
  def prec_f
  end

  # ------------------------------------------------------- Precision#prec_i
  #      num.prec_i  =>  Integer
  # ------------------------------------------------------------------------
  #      Returns an +Integer+ converted from _num_. It is equivalent to
  #      +prec(Integer)+.
  # 
  def prec_i
  end

  # --------------------------------------------------------- Precision#prec
  #      num.prec(klass)   => a_klass
  # ------------------------------------------------------------------------
  #      Converts _self_ into an instance of _klass_. By default, +prec+
  #      invokes
  # 
  #         klass.induced_from(num)
  # 
  #      and returns its value. So, if +klass.induced_from+ doesn't return
  #      an instance of _klass_, it will be necessary to reimplement +prec+.
  # 
  def prec(arg0)
  end

end
