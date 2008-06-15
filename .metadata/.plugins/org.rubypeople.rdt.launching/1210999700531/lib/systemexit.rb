=begin
------------------------------------------ Class: SystemExit < Exception
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
     status, success?

=end
class SystemExit < Exception

  # ------------------------------------------------------ SystemExit#status
  #      system_exit.status   => fixnum
  # ------------------------------------------------------------------------
  #      Return the status value associated with this system exit.
  # 
  def status
  end

  # ---------------------------------------------------- SystemExit#success?
  #      system_exit.success?  => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if exiting successful, +false+ if not.
  # 
  def success?
  end

end
