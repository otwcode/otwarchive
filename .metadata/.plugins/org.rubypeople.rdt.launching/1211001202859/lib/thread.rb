=begin
---------------------------------------------------------- Class: Thread
     +Thread+ encapsulates the behavior of a thread of execution,
     including the main thread of the Ruby script.

     In the descriptions of the methods in this class, the parameter
     _sym_ refers to a symbol, which is either a quoted string or a
     +Symbol+ (such as +:name+).

------------------------------------------------------------------------


Class methods:
--------------
     abort_on_exception, abort_on_exception=, critical, critical=,
     current, exclusive, exit, fork, kill, list, main, new, new, pass,
     start, stop


Instance methods:
-----------------
     [], []=, abort_on_exception, abort_on_exception=, alive?, exit,
     exit!, group, inspect, join, key?, keys, kill, kill!, priority,
     priority=, raise, run, safe_level, status, stop?, terminate,
     terminate!, value, wakeup

=end
class Thread < Object

  # ----------------------------------------------------------- Thread::exit
  #      Thread.exit   => thread
  # ------------------------------------------------------------------------
  #      Terminates the currently running thread and schedules another
  #      thread to be run. If this thread is already marked to be killed,
  #      +exit+ returns the +Thread+. If this is the main thread, or the
  #      last thread, exit the process.
  # 
  def self.exit
  end

  # ----------------------------------------------------------- Thread::main
  #      Thread.main   => thread
  # ------------------------------------------------------------------------
  #      Returns the main thread for the process.
  # 
  #         Thread.main   #=> #<Thread:0x401bdf4c run>
  # 
  def self.main
  end

  # ----------------------------------------------------------- Thread::stop
  #      Thread.stop   => nil
  # ------------------------------------------------------------------------
  #      Stops execution of the current thread, putting it into a ``sleep''
  #      state, and schedules execution of another thread. Resets the
  #      ``critical'' condition to +false+.
  # 
  #         a = Thread.new { print "a"; Thread.stop; print "c" }
  #         Thread.pass
  #         print "b"
  #         a.run
  #         a.join
  # 
  #      _produces:_
  # 
  #         abc
  # 
  def self.stop
  end

  # --------------------------------------------- Thread::abort_on_exception
  #      Thread.abort_on_exception   => true or false
  # ------------------------------------------------------------------------
  #      Returns the status of the global ``abort on exception'' condition.
  #      The default is +false+. When set to +true+, or if the global
  #      +$DEBUG+ flag is +true+ (perhaps because the command line option
  #      +-d+ was specified) all threads will abort (the process will
  #      +exit(0)+) if an exception is raised in any thread. See also
  #      +Thread::abort_on_exception=+.
  # 
  def self.abort_on_exception
  end

  # -------------------------------------------------------- Thread::current
  #      Thread.current   => thread
  # ------------------------------------------------------------------------
  #      Returns the currently executing thread.
  # 
  #         Thread.current   #=> #<Thread:0x401bdf4c run>
  # 
  def self.current
  end

  # ----------------------------------------------------------- Thread::fork
  #      Thread.start([args]*) {|args| block }   => thread
  #      Thread.fork([args]*) {|args| block }    => thread
  # ------------------------------------------------------------------------
  #      Basically the same as +Thread::new+. However, if class +Thread+ is
  #      subclassed, then calling +start+ in that subclass will not invoke
  #      the subclass's +initialize+ method.
  # 
  def self.fork(arg0, arg1, *rest)
  end

  # ------------------------------------------------------- Thread::critical
  #      Thread.critical   => true or false
  # ------------------------------------------------------------------------
  #      Returns the status of the global ``thread critical'' condition.
  # 
  def self.critical
  end

  # -------------------------------------------- Thread::abort_on_exception=
  #      Thread.abort_on_exception= boolean   => true or false
  # ------------------------------------------------------------------------
  #      When set to +true+, all threads will abort if an exception is
  #      raised. Returns the new state.
  # 
  #         Thread.abort_on_exception = true
  #         t1 = Thread.new do
  #           puts  "In new thread"
  #           raise "Exception from thread"
  #         end
  #         sleep(1)
  #         puts "not reached"
  # 
  #      _produces:_
  # 
  #         In new thread
  #         prog.rb:4: Exception from thread (RuntimeError)
  #          from prog.rb:2:in `initialize'
  #          from prog.rb:2:in `new'
  #          from prog.rb:2
  # 
  def self.abort_on_exception=(arg0)
  end

  # ----------------------------------------------------------- Thread::pass
  #      Thread.pass   => nil
  # ------------------------------------------------------------------------
  #      Invokes the thread scheduler to pass execution to another thread.
  # 
  #         a = Thread.new { print "a"; Thread.pass;
  #                          print "b"; Thread.pass;
  #                          print "c" }
  #         b = Thread.new { print "x"; Thread.pass;
  #                          print "y"; Thread.pass;
  #                          print "z" }
  #         a.join
  #         b.join
  # 
  #      _produces:_
  # 
  #         axbycz
  # 
  def self.pass
  end

  # ---------------------------------------------------------- Thread::start
  #      Thread.start([args]*) {|args| block }   => thread
  #      Thread.fork([args]*) {|args| block }    => thread
  # ------------------------------------------------------------------------
  #      Basically the same as +Thread::new+. However, if class +Thread+ is
  #      subclassed, then calling +start+ in that subclass will not invoke
  #      the subclass's +initialize+ method.
  # 
  def self.start(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ Thread::new
  #      Thread.new([arg]*) {|args| block }   => thread
  # ------------------------------------------------------------------------
  #      Creates and runs a new thread to execute the instructions given in
  #      _block_. Any arguments passed to +Thread::new+ are passed into the
  #      block.
  # 
  #         x = Thread.new { sleep 0.1; print "x"; print "y"; print "z" }
  #         a = Thread.new { print "a"; print "b"; sleep 0.2; print "c" }
  #         x.join # Let the threads finish before
  #         a.join # main thread exits...
  # 
  #      _produces:_
  # 
  #         abxyzc
  # 
  def self.new(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- Thread::list
  #      Thread.list   => array
  # ------------------------------------------------------------------------
  #      Returns an array of +Thread+ objects for all threads that are
  #      either runnable or stopped.
  # 
  #         Thread.new { sleep(200) }
  #         Thread.new { 1000000.times {|i| i*i } }
  #         Thread.new { Thread.stop }
  #         Thread.list.each {|t| p t}
  # 
  #      _produces:_
  # 
  #         #<Thread:0x401b3e84 sleep>
  #         #<Thread:0x401b3f38 run>
  #         #<Thread:0x401b3fb0 sleep>
  #         #<Thread:0x401bdf4c run>
  # 
  def self.list
  end

  # ------------------------------------------------------ Thread::critical=
  #      Thread.critical= boolean   => true or false
  # ------------------------------------------------------------------------
  #      Sets the status of the global ``thread critical'' condition and
  #      returns it. When set to +true+, prohibits scheduling of any
  #      existing thread. Does not block new threads from being created and
  #      run. Certain thread operations (such as stopping or killing a
  #      thread, sleeping in the current thread, and raising an exception)
  #      may cause a thread to be scheduled even when in a critical section.
  #      +Thread::critical+ is not intended for daily use: it is primarily
  #      there to support folks writing threading libraries.
  # 
  def self.critical=(arg0)
  end

  # ----------------------------------------------------------- Thread::kill
  #      Thread.kill(thread)   => thread
  # ------------------------------------------------------------------------
  #      Causes the given _thread_ to exit (see +Thread::exit+).
  # 
  #         count = 0
  #         a = Thread.new { loop { count += 1 } }
  #         sleep(0.1)       #=> 0
  #         Thread.kill(a)   #=> #<Thread:0x401b3d30 dead>
  #         count            #=> 93947
  #         a.alive?         #=> false
  # 
  def self.kill(arg0)
  end

  # ------------------------------------------------------ Thread::exclusive
  #      Thread::exclusive() {|| ...}
  # ------------------------------------------------------------------------
  #      Wraps a block in Thread.critical, restoring the original value upon
  #      exit from the critical section.
  # 
  def self.exclusive
  end

  # ------------------------------------------------------------- Thread#run
  #      thr.run   => thr
  # ------------------------------------------------------------------------
  #      Wakes up _thr_, making it eligible for scheduling. If not in a
  #      critical section, then invokes the scheduler.
  # 
  #         a = Thread.new { puts "a"; Thread.stop; puts "c" }
  #         Thread.pass
  #         puts "Got here"
  #         a.run
  #         a.join
  # 
  #      _produces:_
  # 
  #         a
  #         Got here
  #         c
  # 
  def run
  end

  # ------------------------------------------------------------ Thread#exit
  #      thr.exit        => thr
  #      thr.kill        => thr
  #      thr.terminate   => thr
  # ------------------------------------------------------------------------
  #      Terminates _thr_ and schedules another thread to be run, returning
  #      the terminated +Thread+. If this is the main thread, or the last
  #      thread, exits the process.
  # 
  def exit
  end

  # ------------------------------------------------------ Thread#safe_level
  #      thr.safe_level   => integer
  # ------------------------------------------------------------------------
  #      Returns the safe level in effect for _thr_. Setting thread-local
  #      safe levels can help when implementing sandboxes which run insecure
  #      code.
  # 
  #         thr = Thread.new { $SAFE = 3; sleep }
  #         Thread.current.safe_level   #=> 0
  #         thr.safe_level              #=> 3
  # 
  def safe_level
  end

  # ------------------------------------------------------------ Thread#key?
  #      thr.key?(sym)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the given string (or symbol) exists as a
  #      thread-local variable.
  # 
  #         me = Thread.current
  #         me[:oliver] = "a"
  #         me.key?(:oliver)    #=> true
  #         me.key?(:stanley)   #=> false
  # 
  def key?
  end

  # ------------------------------------------------------------ Thread#join
  #      thr.join          => thr
  #      thr.join(limit)   => thr
  # ------------------------------------------------------------------------
  #      The calling thread will suspend execution and run _thr_. Does not
  #      return until _thr_ exits or until _limit_ seconds have passed. If
  #      the time limit expires, +nil+ will be returned, otherwise _thr_ is
  #      returned.
  # 
  #      Any threads not joined will be killed when the main program exits.
  #      If _thr_ had previously raised an exception and the
  #      +abort_on_exception+ and +$DEBUG+ flags are not set (so the
  #      exception has not yet been processed) it will be processed at this
  #      time.
  # 
  #         a = Thread.new { print "a"; sleep(10); print "b"; print "c" }
  #         x = Thread.new { print "x"; Thread.pass; print "y"; print "z" }
  #         x.join # Let x thread finish, a will be killed on exit.
  # 
  #      _produces:_
  # 
  #         axyz
  # 
  #      The following example illustrates the _limit_ parameter.
  # 
  #         y = Thread.new { 4.times { sleep 0.1; puts 'tick... ' }}
  #         puts "Waiting" until y.join(0.15)
  # 
  #      _produces:_
  # 
  #         tick...
  #         Waiting
  #         tick...
  #         Waitingtick...
  #      
  #         tick...
  # 
  def join
  end

  # ----------------------------------------------------------- Thread#stop?
  #      thr.stop?   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _thr_ is dead or sleeping.
  # 
  #         a = Thread.new { Thread.stop }
  #         b = Thread.current
  #         a.stop?   #=> true
  #         b.stop?   #=> false
  # 
  def stop?
  end

  # ----------------------------------------------------------- Thread#exit!
  #      thr.exit!        => thr
  #      thr.kill!        => thr
  #      thr.terminate!   => thr
  # ------------------------------------------------------------------------
  #      Terminates _thr_ without calling ensure clauses and schedules
  #      another thread to be run, returning the terminated +Thread+. If
  #      this is the main thread, or the last thread, exits the process.
  # 
  #      See +Thread#exit+ for the safer version.
  # 
  def exit!
  end

  # -------------------------------------------------------------- Thread#[]
  #      thr[sym]   => obj or nil
  # ------------------------------------------------------------------------
  #      Attribute Reference---Returns the value of a thread-local variable,
  #      using either a symbol or a string name. If the specified variable
  #      does not exist, returns +nil+.
  # 
  #         a = Thread.new { Thread.current["name"] = "A"; Thread.stop }
  #         b = Thread.new { Thread.current[:name]  = "B"; Thread.stop }
  #         c = Thread.new { Thread.current["name"] = "C"; Thread.stop }
  #         Thread.list.each {|x| puts "#{x.inspect}: #{x[:name]}" }
  # 
  #      _produces:_
  # 
  #         #<Thread:0x401b3b3c sleep>: C
  #         #<Thread:0x401b3bc8 sleep>: B
  #         #<Thread:0x401b3c68 sleep>: A
  #         #<Thread:0x401bdf4c run>:
  # 
  def []
  end

  # ------------------------------------------------------------ Thread#keys
  #      thr.keys   => array
  # ------------------------------------------------------------------------
  #      Returns an an array of the names of the thread-local variables (as
  #      Symbols).
  # 
  #         thr = Thread.new do
  #           Thread.current[:cat] = 'meow'
  #           Thread.current["dog"] = 'woof'
  #         end
  #         thr.join   #=> #<Thread:0x401b3f10 dead>
  #         thr.keys   #=> [:dog, :cat]
  # 
  def keys
  end

  # ---------------------------------------------- Thread#abort_on_exception
  #      thr.abort_on_exception   => true or false
  # ------------------------------------------------------------------------
  #      Returns the status of the thread-local ``abort on exception''
  #      condition for _thr_. The default is +false+. See also
  #      +Thread::abort_on_exception=+.
  # 
  def abort_on_exception
  end

  # -------------------------------------------------------- Thread#priority
  #      thr.priority   => integer
  # ------------------------------------------------------------------------
  #      Returns the priority of _thr_. Default is inherited from the
  #      current thread which creating the new thread, or zero for the
  #      initial main thread; higher-priority threads will run before
  #      lower-priority threads.
  # 
  #         Thread.current.priority   #=> 0
  # 
  def priority
  end

  # ------------------------------------------------------------- Thread#[]=
  #      thr[sym] = obj   => obj
  # ------------------------------------------------------------------------
  #      Attribute Assignment---Sets or creates the value of a thread-local
  #      variable, using either a symbol or a string. See also +Thread#[]+.
  # 
  def []=
  end

  # ----------------------------------------------------------- Thread#value
  #      thr.value   => obj
  # ------------------------------------------------------------------------
  #      Waits for _thr_ to complete (via +Thread#join+) and returns its
  #      value.
  # 
  #         a = Thread.new { 2 + 2 }
  #         a.value   #=> 4
  # 
  def value
  end

  # ---------------------------------------------------------- Thread#status
  #      thr.status   => string, false or nil
  # ------------------------------------------------------------------------
  #      Returns the status of _thr_: ``+sleep+'' if _thr_ is sleeping or
  #      waiting on I/O, ``+run+'' if _thr_ is executing, ``+aborting+'' if
  #      _thr_ is aborting, +false+ if _thr_ terminated normally, and +nil+
  #      if _thr_ terminated with an exception.
  # 
  #         a = Thread.new { raise("die now") }
  #         b = Thread.new { Thread.stop }
  #         c = Thread.new { Thread.exit }
  #         d = Thread.new { sleep }
  #         Thread.critical = true
  #         d.kill                  #=> #<Thread:0x401b3678 aborting>
  #         a.status                #=> nil
  #         b.status                #=> "sleep"
  #         c.status                #=> false
  #         d.status                #=> "aborting"
  #         Thread.current.status   #=> "run"
  # 
  def status
  end

  # ---------------------------------------------------------- Thread#alive?
  #      thr.alive?   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _thr_ is running or sleeping.
  # 
  #         thr = Thread.new { }
  #         thr.join                #=> #<Thread:0x401b3fb0 dead>
  #         Thread.current.alive?   #=> true
  #         thr.alive?              #=> false
  # 
  def alive?
  end

  # ------------------------------------------------------- Thread#terminate
  #      thr.exit        => thr
  #      thr.kill        => thr
  #      thr.terminate   => thr
  # ------------------------------------------------------------------------
  #      Terminates _thr_ and schedules another thread to be run, returning
  #      the terminated +Thread+. If this is the main thread, or the last
  #      thread, exits the process.
  # 
  def terminate
  end

  # ------------------------------------------------------ Thread#terminate!
  #      thr.exit!        => thr
  #      thr.kill!        => thr
  #      thr.terminate!   => thr
  # ------------------------------------------------------------------------
  #      Terminates _thr_ without calling ensure clauses and schedules
  #      another thread to be run, returning the terminated +Thread+. If
  #      this is the main thread, or the last thread, exits the process.
  # 
  #      See +Thread#exit+ for the safer version.
  # 
  def terminate!
  end

  # --------------------------------------------- Thread#abort_on_exception=
  #      thr.abort_on_exception= boolean   => true or false
  # ------------------------------------------------------------------------
  #      When set to +true+, causes all threads (including the main program)
  #      to abort if an exception is raised in _thr_. The process will
  #      effectively +exit(0)+.
  # 
  def abort_on_exception=
  end

  # ------------------------------------------------------- Thread#priority=
  #      thr.priority= integer   => thr
  # ------------------------------------------------------------------------
  #      Sets the priority of _thr_ to _integer_. Higher-priority threads
  #      will run before lower-priority threads.
  # 
  #         count1 = count2 = 0
  #         a = Thread.new do
  #               loop { count1 += 1 }
  #             end
  #         a.priority = -1
  #      
  #         b = Thread.new do
  #               loop { count2 += 1 }
  #             end
  #         b.priority = -2
  #         sleep 1   #=> 1
  #         Thread.critical = 1
  #         count1    #=> 622504
  #         count2    #=> 5832
  # 
  def priority=
  end

  # ---------------------------------------------------------- Thread#wakeup
  #      thr.wakeup   => thr
  # ------------------------------------------------------------------------
  #      Marks _thr_ as eligible for scheduling (it may still remain blocked
  #      on I/O, however). Does not invoke the scheduler (see +Thread#run+).
  # 
  #         c = Thread.new { Thread.stop; puts "hey!" }
  #         c.wakeup
  # 
  #      _produces:_
  # 
  #         hey!
  # 
  def wakeup
  end

  # ----------------------------------------------------------- Thread#kill!
  #      thr.exit!        => thr
  #      thr.kill!        => thr
  #      thr.terminate!   => thr
  # ------------------------------------------------------------------------
  #      Terminates _thr_ without calling ensure clauses and schedules
  #      another thread to be run, returning the terminated +Thread+. If
  #      this is the main thread, or the last thread, exits the process.
  # 
  #      See +Thread#exit+ for the safer version.
  # 
  def kill!
  end

  # ----------------------------------------------------------- Thread#group
  #      thr.group   => thgrp or nil
  # ------------------------------------------------------------------------
  #      Returns the +ThreadGroup+ which contains _thr_, or nil if the
  #      thread is not a member of any group.
  # 
  #         Thread.main.group   #=> #<ThreadGroup:0x4029d914>
  # 
  def group
  end

  # ----------------------------------------------------------- Thread#raise
  #      thr.raise(exception)
  # ------------------------------------------------------------------------
  #      Raises an exception (see +Kernel::raise+) from _thr_. The caller
  #      does not have to be _thr_.
  # 
  #         Thread.abort_on_exception = true
  #         a = Thread.new { sleep(200) }
  #         a.raise("Gotcha")
  # 
  #      _produces:_
  # 
  #         prog.rb:3: Gotcha (RuntimeError)
  #          from prog.rb:2:in `initialize'
  #          from prog.rb:2:in `new'
  #          from prog.rb:2
  # 
  def raise
  end

  # ------------------------------------------------------------ Thread#kill
  #      thr.exit        => thr
  #      thr.kill        => thr
  #      thr.terminate   => thr
  # ------------------------------------------------------------------------
  #      Terminates _thr_ and schedules another thread to be run, returning
  #      the terminated +Thread+. If this is the main thread, or the last
  #      thread, exits the process.
  # 
  def kill
  end

  # --------------------------------------------------------- Thread#inspect
  #      thr.inspect   => string
  # ------------------------------------------------------------------------
  #      Dump the name, id, and status of _thr_ to a string.
  # 
  def inspect
  end

end
