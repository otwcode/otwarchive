=begin
---------------------------------- Class: LocalJumpError < StandardError
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


Instance methods:
-----------------
     exit_value, reason

=end
class LocalJumpError < StandardError

  # -------------------------------------------------- LocalJumpError#reason
  #      local_jump_error.reason   => symbol
  # ------------------------------------------------------------------------
  #      The reason this block was terminated: :break, :redo, :retry, :next,
  #      :return, or :noreason.
  # 
  def reason
  end

  # ---------------------------------------------- LocalJumpError#exit_value
  #      exit_value()
  # ------------------------------------------------------------------------
  #      call_seq:
  # 
  #        local_jump_error.exit_value  => obj
  # 
  #      Returns the exit value associated with this +LocalJumpError+.
  # 
  def exit_value
  end

end
