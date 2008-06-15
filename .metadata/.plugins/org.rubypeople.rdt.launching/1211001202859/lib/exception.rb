=begin
------------------------------------------------------- Class: Exception
     Descendents of class +Exception+ are used to communicate between
     +raise+ methods and +rescue+ statements in +begin/end+ blocks.
     +Exception+ objects carry information about the exception---its
     type (the exception's class name), an optional descriptive string,
     and optional traceback information. Programs may subclass
     +Exception+ to add additional information.

------------------------------------------------------------------------
     Add file-blaming to exceptions

------------------------------------------------------------------------


Class methods:
--------------
     exception, new, yaml_new


Instance methods:
-----------------
     backtrace, exception, inspect, message, set_backtrace, to_s,
     to_str, to_yaml

=end
class Exception < Object

  # ---------------------------------------------------- Exception::yaml_new
  #      Exception::yaml_new( klass, tag, val )
  # ------------------------------------------------------------------------
  #      (no description...)
  def self.yaml_new(arg0, arg1, arg2)
  end

  # --------------------------------------------------- Exception::exception
  #      exc.exception(string) -> an_exception or exc
  # ------------------------------------------------------------------------
  #      With no argument, or if the argument is the same as the receiver,
  #      return the receiver. Otherwise, create a new exception object of
  #      the same class as the receiver, but with a message equal to
  #      +string.to_str+.
  # 
  def self.exception(arg0, arg1, *rest)
  end

  def self.yaml_tag_subclasses?
  end

  # --------------------------------------------------------- Exception#to_s
  #      exception.to_s   =>  string
  # ------------------------------------------------------------------------
  #      Returns exception's message (or the name of the exception if no
  #      message is set).
  # 
  def to_s
  end

  # ------------------------------------------------------- Exception#to_str
  #      exception.message   =>  string
  #      exception.to_str    =>  string
  # ------------------------------------------------------------------------
  #      Returns the result of invoking +exception.to_s+. Normally this
  #      returns the exception's message or name. By supplying a to_str
  #      method, exceptions are agreeing to be used where Strings are
  #      expected.
  # 
  def to_str
  end

  # ---------------------------------------------------- Exception#backtrace
  #      exception.backtrace    => array
  # ------------------------------------------------------------------------
  #      Returns any backtrace associated with the exception. The backtrace
  #      is an array of strings, each containing either ``filename:lineNo:
  #      in `method''' or ``filename:lineNo.''
  # 
  #         def a
  #           raise "boom"
  #         end
  #      
  #         def b
  #           a()
  #         end
  #      
  #         begin
  #           b()
  #         rescue => detail
  #           print detail.backtrace.join("\n")
  #         end
  # 
  #      _produces:_
  # 
  #         prog.rb:2:in `a'
  #         prog.rb:6:in `b'
  #         prog.rb:10
  # 
  def backtrace
  end

  def taguri=(arg0)
  end

  # ------------------------------------------------------ Exception#message
  #      exception.message   =>  string
  #      exception.to_str    =>  string
  # ------------------------------------------------------------------------
  #      Returns the result of invoking +exception.to_s+. Normally this
  #      returns the exception's message or name. By supplying a to_str
  #      method, exceptions are agreeing to be used where Strings are
  #      expected.
  # 
  def message
  end

  # ---------------------------------------------------- Exception#exception
  #      exc.exception(string) -> an_exception or exc
  # ------------------------------------------------------------------------
  #      With no argument, or if the argument is the same as the receiver,
  #      return the receiver. Otherwise, create a new exception object of
  #      the same class as the receiver, but with a message equal to
  #      +string.to_str+.
  # 
  def exception(arg0, arg1, *rest)
  end

  # ------------------------------------------------------ Exception#inspect
  #      exception.inspect   => string
  # ------------------------------------------------------------------------
  #      Return this exception's class name an message
  # 
  def inspect
  end

  # ------------------------------------------------ Exception#set_backtrace
  #      exc.set_backtrace(array)   =>  array
  # ------------------------------------------------------------------------
  #      Sets the backtrace information associated with _exc_. The argument
  #      must be an array of +String+ objects in the format described in
  #      +Exception#backtrace+.
  # 
  def set_backtrace(arg0)
  end

  def taguri
  end

  # ------------------------------------------------------ Exception#to_yaml
  #      to_yaml( opts = {} )
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml(arg0, arg1, *rest)
  end

end
