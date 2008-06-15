=begin
-------------------------------- Class: SystemStackError < StandardError
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

=end
class SystemStackError < StandardError

end
