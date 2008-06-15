=begin
------------------------------------------------------------ Class: Proc
     +Proc+ objects are blocks of code that have been bound to a set of
     local variables. Once bound, the code may be called in different
     contexts and still access those variables.

        def gen_times(factor)
          return Proc.new {|n| n*factor }
        end
     
        times3 = gen_times(3)
        times5 = gen_times(5)
     
        times3.call(12)               #=> 36
        times5.call(5)                #=> 25
        times3.call(times5.call(4))   #=> 60

------------------------------------------------------------------------


Class methods:
--------------
     new


Instance methods:
-----------------
     ==, [], arity, binding, call, clone, dup, to_proc, to_s

=end
class Proc < Object

  # -------------------------------------------------------------- Proc::new
  #      Proc.new {|...| block } => a_proc 
  #      Proc.new                => a_proc 
  # ------------------------------------------------------------------------
  #      Creates a new +Proc+ object, bound to the current context.
  #      +Proc::new+ may be called without a block only within a method with
  #      an attached block, in which case that block is converted to the
  #      +Proc+ object.
  # 
  #         def proc_from
  #           Proc.new
  #         end
  #         proc = proc_from { "hello" }
  #         proc.call   #=> "hello"
  # 
  def self.new(arg0, arg1, *rest)
  end

  # --------------------------------------------------------------- Proc#dup
  #      dup()
  # ------------------------------------------------------------------------
  #      MISSING: documentation
  # 
  def dup
  end

  # ---------------------------------------------------------------- Proc#[]
  #      prc.call(params,...)   => obj
  #      prc[params,...]        => obj
  # ------------------------------------------------------------------------
  #      Invokes the block, setting the block's parameters to the values in
  #      _params_ using something close to method calling semantics.
  #      Generates a warning if multiple values are passed to a proc that
  #      expects just one (previously this silently converted the parameters
  #      to an array).
  # 
  #      For procs created using +Kernel.proc+, generates an error if the
  #      wrong number of parameters are passed to a proc with multiple
  #      parameters. For procs created using +Proc.new+, extra parameters
  #      are silently discarded.
  # 
  #      Returns the value of the last expression evaluated in the block.
  #      See also +Proc#yield+.
  # 
  #         a_proc = Proc.new {|a, *b| b.collect {|i| i*a }}
  #         a_proc.call(9, 1, 2, 3)   #=> [9, 18, 27]
  #         a_proc[9, 1, 2, 3]        #=> [9, 18, 27]
  #         a_proc = Proc.new {|a,b| a}
  #         a_proc.call(1,2,3)
  # 
  #      _produces:_
  # 
  #         prog.rb:5: wrong number of arguments (3 for 2) (ArgumentError)
  #          from prog.rb:4:in `call'
  #          from prog.rb:5
  # 
  def []
  end

  # ---------------------------------------------------------------- Proc#==
  #      prc == other_proc   =>  true or false
  # ------------------------------------------------------------------------
  #      Return +true+ if _prc_ is the same object as _other_proc_, or if
  #      they are both procs with the same body.
  # 
  def ==
  end

  # -------------------------------------------------------------- Proc#to_s
  #      prc.to_s   => string
  # ------------------------------------------------------------------------
  #      Shows the unique identifier for this proc, along with an indication
  #      of where the proc was defined.
  # 
  def to_s
  end

  # ----------------------------------------------------------- Proc#binding
  #      prc.binding    => binding
  # ------------------------------------------------------------------------
  #      Returns the binding associated with _prc_. Note that +Kernel#eval+
  #      accepts either a +Proc+ or a +Binding+ object as its second
  #      parameter.
  # 
  #         def fred(param)
  #           proc {}
  #         end
  #      
  #         b = fred(99)
  #         eval("param", b.binding)   #=> 99
  #         eval("param", b)           #=> 99
  # 
  def binding
  end

  # ------------------------------------------------------------- Proc#clone
  #      clone()
  # ------------------------------------------------------------------------
  #      MISSING: documentation
  # 
  def clone
  end

  # ----------------------------------------------------------- Proc#to_proc
  #      prc.to_proc -> prc
  # ------------------------------------------------------------------------
  #      Part of the protocol for converting objects to +Proc+ objects.
  #      Instances of class +Proc+ simply return themselves.
  # 
  def to_proc
  end

  # -------------------------------------------------------------- Proc#call
  #      prc.call(params,...)   => obj
  #      prc[params,...]        => obj
  # ------------------------------------------------------------------------
  #      Invokes the block, setting the block's parameters to the values in
  #      _params_ using something close to method calling semantics.
  #      Generates a warning if multiple values are passed to a proc that
  #      expects just one (previously this silently converted the parameters
  #      to an array).
  # 
  #      For procs created using +Kernel.proc+, generates an error if the
  #      wrong number of parameters are passed to a proc with multiple
  #      parameters. For procs created using +Proc.new+, extra parameters
  #      are silently discarded.
  # 
  #      Returns the value of the last expression evaluated in the block.
  #      See also +Proc#yield+.
  # 
  #         a_proc = Proc.new {|a, *b| b.collect {|i| i*a }}
  #         a_proc.call(9, 1, 2, 3)   #=> [9, 18, 27]
  #         a_proc[9, 1, 2, 3]        #=> [9, 18, 27]
  #         a_proc = Proc.new {|a,b| a}
  #         a_proc.call(1,2,3)
  # 
  #      _produces:_
  # 
  #         prog.rb:5: wrong number of arguments (3 for 2) (ArgumentError)
  #          from prog.rb:4:in `call'
  #          from prog.rb:5
  # 
  def call
  end

  # ------------------------------------------------------------- Proc#arity
  #      prc.arity -> fixnum
  # ------------------------------------------------------------------------
  #      Returns the number of arguments that would not be ignored. If the
  #      block is declared to take no arguments, returns 0. If the block is
  #      known to take exactly n arguments, returns n. If the block has
  #      optional arguments, return -n-1, where n is the number of mandatory
  #      arguments. A +proc+ with no argument declarations is the same a
  #      block declaring +||+ as its arguments.
  # 
  #         Proc.new {}.arity          #=>  0
  #         Proc.new {||}.arity        #=>  0
  #         Proc.new {|a|}.arity       #=>  1
  #         Proc.new {|a,b|}.arity     #=>  2
  #         Proc.new {|a,b,c|}.arity   #=>  3
  #         Proc.new {|*a|}.arity      #=> -1
  #         Proc.new {|a,*b|}.arity    #=> -2
  # 
  def arity
  end

end
