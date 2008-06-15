=begin
--------------------------------- Class: SystemCallError < StandardError
     Descendents of class +Exception+ are used to communicate between
     +raise+ methods and +rescue+ statements in +begin/end+ blocks.
     +Exception+ objects carry information about the exception---its
     type (the exception's class name), an optional descriptive string,
     and optional traceback information. Programs may subclass
     +Exception+ to add additional information.

------------------------------------------------------------------------


Class methods:
--------------
     ===, new


Instance methods:
-----------------
     errno

=end
class SystemCallError < StandardError

  # --------------------------------------------------- SystemCallError::===
  #      system_call_error === other  => true or false
  # ------------------------------------------------------------------------
  #      Return +true+ if the receiver is a generic +SystemCallError+, or if
  #      the error numbers _self_ and _other_ are the same.
  # 
  def self.===(arg0)
  end

  # -------------------------------------------------- SystemCallError#errno
  #      system_call_error.errno   => fixnum
  # ------------------------------------------------------------------------
  #      Return this SystemCallError's error number.
  # 
  def errno
  end

end
