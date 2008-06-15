=begin
------------------------------------- Class: SimpleDelegator < Delegator
     A concrete implementation of Delegator, this class provides the
     means to delegate all supported method calls to the object passed
     into the constructor and even to change the object being delegated
     to at a later time with __setobj__ .

------------------------------------------------------------------------


Class methods:
--------------
     new


Instance methods:
-----------------
     __getobj__, __setobj__, clone, dup

=end
class SimpleDelegator < Delegator

  # ---------------------------------------------------- SimpleDelegator#dup
  #      dup(obj)
  # ------------------------------------------------------------------------
  #      Duplication support for the object returned by __getobj__.
  # 
  def dup
  end

  # -------------------------------------------------- SimpleDelegator#clone
  #      clone()
  # ------------------------------------------------------------------------
  #      Clone support for the object returned by __getobj__.
  # 
  def clone
  end

  # --------------------------------------------- SimpleDelegator#__setobj__
  #      __setobj__(obj)
  # ------------------------------------------------------------------------
  #      Changes the delegate object to _obj_.
  # 
  #      It's important to note that this does *not* cause SimpleDelegator's
  #      methods to change. Because of this, you probably only want to
  #      change delegation to objects of the same type as the original
  #      delegate.
  # 
  #      Here's an example of changing the delegation object.
  # 
  #        names = SimpleDelegator.new(%w{James Edward Gray II})
  #        puts names[1]    # => Edward
  #        names.<em>setobj</em>(%w{Gavin Sinclair})
  #        puts names[1]    # => Sinclair
  # 
  def __setobj__
  end

  # --------------------------------------------- SimpleDelegator#__getobj__
  #      __getobj__()
  # ------------------------------------------------------------------------
  #      Returns the current object method calls are being delegated to.
  # 
  def __getobj__
  end

end
