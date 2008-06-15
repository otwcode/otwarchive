=begin
--------------------------------------- Class: NameError < StandardError
     Descendents of class +Exception+ are used to communicate between
     +raise+ methods and +rescue+ statements in +begin/end+ blocks.
     +Exception+ objects carry information about the exception---its
     type (the exception's class name), an optional descriptive string,
     and optional traceback information. Programs may subclass
     +Exception+ to add additional information.

------------------------------------------------------------------------
     Add a +missing_name+ method to NameError instances.

------------------------------------------------------------------------


Class methods:
--------------
     new


Instance methods:
-----------------
     name, to_s

=end
class NameError < StandardError

  # --------------------------------------------------------- NameError#to_s
  #      name_error.to_s   => string
  # ------------------------------------------------------------------------
  #      Produce a nicely-formated string representing the +NameError+.
  # 
  def to_s
  end

  # --------------------------------------------------------- NameError#name
  #      name_error.name    =>  string or nil
  # ------------------------------------------------------------------------
  #      Return the name associated with this NameError exception.
  # 
  def name
  end

end
