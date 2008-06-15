=begin
--------------------------------------- Class: NoMethodError < NameError
     Descendents of class +Exception+ are used to communicate between
     +raise+ methods and +rescue+ statements in +begin/end+ blocks.
     +Exception+ objects carry information about the exception---its
     type (the exception's class name), an optional descriptive string,
     and optional traceback information. Programs may subclass
     +Exception+ to add additional information.

------------------------------------------------------------------------


Class methods:
--------------
     new


Instance methods:
-----------------
     args

=end
class NoMethodError < NameError

  # ----------------------------------------------------- NoMethodError#args
  #      no_method_error.args  => obj
  # ------------------------------------------------------------------------
  #      Return the arguments passed in as the third parameter to the
  #      constructor.
  # 
  def args
  end

end
