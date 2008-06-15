=begin
------------------------------------------------------- Class: Delegator
     Delegator is an abstract class used to build delegator pattern
     objects from subclasses. Subclasses should redefine __getobj__. For
     a concrete implementation, see SimpleDelegator.

------------------------------------------------------------------------


Class methods:
--------------
     new


Instance methods:
-----------------
     __getobj__, marshal_dump, marshal_load, method_missing, respond_to?

=end
class Delegator < Object

  # ------------------------------------------------- Delegator#marshal_load
  #      marshal_load(obj)
  # ------------------------------------------------------------------------
  #      Reinitializes delegation from a serialized object.
  # 
  def marshal_load
  end

  # ----------------------------------------------- Delegator#method_missing
  #      method_missing(m, *args)
  # ------------------------------------------------------------------------
  #      Handles the magic of delegation through __getobj__.
  # 
  def method_missing
  end

  # ------------------------------------------------- Delegator#marshal_dump
  #      marshal_dump()
  # ------------------------------------------------------------------------
  #      Serialization support for the object returned by __getobj__.
  # 
  def marshal_dump
  end

  # -------------------------------------------------- Delegator#respond_to?
  #      respond_to?(m)
  # ------------------------------------------------------------------------
  #      Checks for a method provided by this the delegate object by
  #      fowarding the call through __getobj__.
  # 
  def respond_to?
  end

  # --------------------------------------------------- Delegator#__getobj__
  #      __getobj__()
  # ------------------------------------------------------------------------
  #      This method must be overridden by subclasses and should return the
  #      object method calls are being delegated to.
  # 
  def __getobj__
  end

end
