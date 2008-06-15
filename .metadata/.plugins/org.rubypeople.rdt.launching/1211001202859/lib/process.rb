=begin
--------------------------------------------------------- Class: Process
     The +Process+ module is a collection of methods used to manipulate
     processes.

------------------------------------------------------------------------


Includes:
---------
     Windows::Console(), Windows::Error(get_last_error),
     Windows::Handle(CloseHandle, DuplicateHandle, GetHandleInformation,
     SetHandleInformation, get_osfhandle, open_osfhandle),
     Windows::Library(), Windows::Process(),
     Windows::Synchronize(HasOverlappedIoCompleted), Windows::Window()


Constants:
----------
     PRIO_PGRP:             INT2FIX(PRIO_PGRP)
     PRIO_PROCESS:          INT2FIX(PRIO_PROCESS)
     PRIO_USER:             INT2FIX(PRIO_USER)
     ProcessInfo:           Struct.new("ProcessInfo",      
                            :process_handle,       :thread_handle,      
                            :process_id,       :thread_id
     RLIMIT_AS:             INT2FIX(RLIMIT_AS)
     RLIMIT_CORE:           INT2FIX(RLIMIT_CORE)
     RLIMIT_CPU:            INT2FIX(RLIMIT_CPU)
     RLIMIT_DATA:           INT2FIX(RLIMIT_DATA)
     RLIMIT_FSIZE:          INT2FIX(RLIMIT_FSIZE)
     RLIMIT_MEMLOCK:        INT2FIX(RLIMIT_MEMLOCK)
     RLIMIT_NOFILE:         INT2FIX(RLIMIT_NOFILE)
     RLIMIT_NPROC:          INT2FIX(RLIMIT_NPROC)
     RLIMIT_RSS:            INT2FIX(RLIMIT_RSS)
     RLIMIT_SBSIZE:         INT2FIX(RLIMIT_SBSIZE)
     RLIMIT_STACK:          INT2FIX(RLIMIT_STACK)
     RLIM_INFINITY:         RLIM2NUM(RLIM_INFINITY)
     RLIM_SAVED_CUR:        RLIM2NUM(RLIM_SAVED_CUR)
     RLIM_SAVED_MAX:        RLIM2NUM(RLIM_SAVED_MAX)
     WIN32_PROCESS_VERSION: '0.5.3'
     WNOHANG:               INT2FIX(0)
     WUNTRACED:             INT2FIX(0)


Class methods:
--------------
     abort, detach, egid, egid=, euid, euid=, exit, exit!, fork,
     getpgid, getpriority, getrlimit, gid, gid=, groups, groups=,
     initgroups, kill, maxgroups, maxgroups=, pid, ppid, setpgid,
     setpgrp, setpriority, setrlimit, setsid, times, uid, uid=, wait,
     wait2, waitall, waitpid, waitpid2


Instance methods:
-----------------
     create, fork, kill, wait, wait2, waitpid, waitpid2

=end
module Process

  # ---------------------------------------------------------- Process::exit
  #      exit(integer=0)
  #      Kernel::exit(integer=0)
  #      Process::exit(integer=0)
  # ------------------------------------------------------------------------
  #      Initiates the termination of the Ruby script by raising the
  #      +SystemExit+ exception. This exception may be caught. The optional
  #      parameter is used to return a status code to the invoking
  #      environment.
  # 
  #         begin
  #           exit
  #           puts "never get here"
  #         rescue SystemExit
  #           puts "rescued a SystemExit exception"
  #         end
  #         puts "after begin block"
  # 
  #      _produces:_
  # 
  #         rescued a SystemExit exception
  #         after begin block
  # 
  #      Just prior to termination, Ruby executes any +at_exit+ functions
  #      (see Kernel::at_exit) and runs any object finalizers (see
  #      ObjectSpace::define_finalizer).
  # 
  #         at_exit { puts "at_exit function" }
  #         ObjectSpace.define_finalizer("string",  proc { puts "in finalizer" })
  #         exit
  # 
  #      _produces:_
  # 
  #         at_exit function
  #         in finalizer
  # 
  def self.exit(arg0, arg1, *rest)
  end

  # --------------------------------------------------- Process::setpriority
  #      Process.setpriority(kind, integer, priority)   => 0
  # ------------------------------------------------------------------------
  #      See +Process#getpriority+.
  # 
  #         Process.setpriority(Process::PRIO_USER, 0, 19)      #=> 0
  #         Process.setpriority(Process::PRIO_PROCESS, 0, 19)   #=> 0
  #         Process.getpriority(Process::PRIO_USER, 0)          #=> 19
  #         Process.getpriority(Process::PRIO_PROCESS, 0)       #=> 19
  # 
  def self.setpriority(arg0, arg1, arg2)
  end

  # ---------------------------------------------------------- Process::uid=
  #      Process.uid= integer   => numeric
  # ------------------------------------------------------------------------
  #      Sets the (integer) user ID for this process. Not available on all
  #      platforms.
  # 
  def self.uid=(arg0)
  end

  # ------------------------------------------------------- Process::getpgid
  #      Process.getpgid(pid)   => integer
  # ------------------------------------------------------------------------
  #      Returns the process group ID for the given process id. Not
  #      available on all platforms.
  # 
  #         Process.getpgid(Process.ppid())   #=> 25527
  # 
  def self.getpgid(arg0)
  end

  # ----------------------------------------------------- Process::maxgroups
  #      Process.maxgroups   => fixnum
  # ------------------------------------------------------------------------
  #      Returns the maximum number of gids allowed in the supplemental
  #      group access list.
  # 
  #         Process.maxgroups   #=> 32
  # 
  def self.maxgroups
  end

  # --------------------------------------------------------- Process::exit!
  #      Process.exit!(fixnum=-1)
  # ------------------------------------------------------------------------
  #      Exits the process immediately. No exit handlers are run. _fixnum_
  #      is returned to the underlying system as the exit status.
  # 
  #         Process.exit!(0)
  # 
  def self.exit!(arg0, arg1, *rest)
  end

  # ------------------------------------------------------- Process::waitpid
  #      Process.wait()                     => fixnum
  #      Process.wait(pid=-1, flags=0)      => fixnum
  #      Process.waitpid(pid=-1, flags=0)   => fixnum
  # ------------------------------------------------------------------------
  #      Waits for a child process to exit, returns its process id, and sets
  #      +$?+ to a +Process::Status+ object containing information on that
  #      process. Which child it waits on depends on the value of _pid_:
  # 
  #      > 0:  Waits for the child whose process ID equals _pid_.
  # 
  #      0:    Waits for any child whose process group ID equals that of the
  #            calling process.
  # 
  #      -1:   Waits for any child process (the default if no _pid_ is
  #            given).
  # 
  #      < -1: Waits for any child whose process group ID equals the
  #            absolute value of _pid_.
  # 
  #      The _flags_ argument may be a logical or of the flag values
  #      +Process::WNOHANG+ (do not block if no child available) or
  #      +Process::WUNTRACED+ (return stopped children that haven't been
  #      reported). Not all flags are available on all platforms, but a flag
  #      value of zero will work on all platforms.
  # 
  #      Calling this method raises a +SystemError+ if there are no child
  #      processes. Not available on all platforms.
  # 
  #         include Process
  #         fork { exit 99 }                 #=> 27429
  #         wait                             #=> 27429
  #         $?.exitstatus                    #=> 99
  #      
  #         pid = fork { sleep 3 }           #=> 27440
  #         Time.now                         #=> Wed Apr 09 08:57:09 CDT 2003
  #         waitpid(pid, Process::WNOHANG)   #=> nil
  #         Time.now                         #=> Wed Apr 09 08:57:09 CDT 2003
  #         waitpid(pid, 0)                  #=> 27440
  #         Time.now                         #=> Wed Apr 09 08:57:12 CDT 2003
  # 
  def self.waitpid(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- Process::euid
  #      Process.euid           => fixnum
  #      Process::UID.eid       => fixnum
  #      Process::Sys.geteuid   => fixnum
  # ------------------------------------------------------------------------
  #      Returns the effective user ID for this process.
  # 
  #         Process.euid   #=> 501
  # 
  def self.euid
  end

  # --------------------------------------------------------- Process::egid=
  #      Process.egid = fixnum   => fixnum
  # ------------------------------------------------------------------------
  #      Sets the effective group ID for this process. Not available on all
  #      platforms.
  # 
  def self.egid=(arg0)
  end

  # --------------------------------------------------- Process::getpriority
  #      Process.getpriority(kind, integer)   => fixnum
  # ------------------------------------------------------------------------
  #      Gets the scheduling priority for specified process, process group,
  #      or user. _kind_ indicates the kind of entity to find: one of
  #      +Process::PRIO_PGRP+, +Process::PRIO_USER+, or
  #      +Process::PRIO_PROCESS+. _integer_ is an id indicating the
  #      particular process, process group, or user (an id of 0 means
  #      _current_). Lower priorities are more favorable for scheduling. Not
  #      available on all platforms.
  # 
  #         Process.getpriority(Process::PRIO_USER, 0)      #=> 19
  #         Process.getpriority(Process::PRIO_PROCESS, 0)   #=> 19
  # 
  def self.getpriority(arg0, arg1)
  end

  # -------------------------------------------------------- Process::detach
  #      Process.detach(pid)   => thread
  # ------------------------------------------------------------------------
  #      Some operating systems retain the status of terminated child
  #      processes until the parent collects that status (normally using
  #      some variant of +wait()+. If the parent never collects this status,
  #      the child stays around as a _zombie_ process. +Process::detach+
  #      prevents this by setting up a separate Ruby thread whose sole job
  #      is to reap the status of the process _pid_ when it terminates. Use
  #      +detach+ only when you do not intent to explicitly wait for the
  #      child to terminate. +detach+ only checks the status periodically
  #      (currently once each second).
  # 
  #      In this first example, we don't reap the first child process, so it
  #      appears as a zombie in the process status display.
  # 
  #         p1 = fork { sleep 0.1 }
  #         p2 = fork { sleep 0.2 }
  #         Process.waitpid(p2)
  #         sleep 2
  #         system("ps -ho pid,state -p #{p1}")
  # 
  #      _produces:_
  # 
  #         27389 Z
  # 
  #      In the next example, +Process::detach+ is used to reap the child
  #      automatically.
  # 
  #         p1 = fork { sleep 0.1 }
  #         p2 = fork { sleep 0.2 }
  #         Process.detach(p1)
  #         Process.waitpid(p2)
  #         sleep 2
  #         system("ps -ho pid,state -p #{p1}")
  # 
  #      _(produces no output)_
  # 
  def self.detach(arg0)
  end

  # ------------------------------------------------------- Process::setpgrp
  #      Process.setpgrp   => 0
  # ------------------------------------------------------------------------
  #      Equivalent to +setpgid(0,0)+. Not available on all platforms.
  # 
  def self.setpgrp
  end

  # -------------------------------------------------------- Process::groups
  #      Process.groups   => array
  # ------------------------------------------------------------------------
  #      Get an +Array+ of the gids of groups in the supplemental group
  #      access list for this process.
  # 
  #         Process.groups   #=> [27, 6, 10, 11]
  # 
  def self.groups
  end

  # ---------------------------------------------------- Process::maxgroups=
  #      Process.maxgroups= fixnum   => fixnum
  # ------------------------------------------------------------------------
  #      Sets the maximum number of gids allowed in the supplemental group
  #      access list.
  # 
  def self.maxgroups=(arg0)
  end

  # ---------------------------------------------------------- Process::fork
  #      Kernel.fork  [{ block }]   => fixnum or nil
  #      Process.fork [{ block }]   => fixnum or nil
  # ------------------------------------------------------------------------
  #      Creates a subprocess. If a block is specified, that block is run in
  #      the subprocess, and the subprocess terminates with a status of
  #      zero. Otherwise, the +fork+ call returns twice, once in the parent,
  #      returning the process ID of the child, and once in the child,
  #      returning _nil_. The child process can exit using +Kernel.exit!+ to
  #      avoid running any +at_exit+ functions. The parent process should
  #      use +Process.wait+ to collect the termination statuses of its
  #      children or use +Process.detach+ to register disinterest in their
  #      status; otherwise, the operating system may accumulate zombie
  #      processes.
  # 
  #      The thread calling fork is the only thread in the created child
  #      process. fork doesn't copy other threads.
  # 
  def self.fork
  end

  # --------------------------------------------------------- Process::wait2
  #      Process.wait2(pid=-1, flags=0)      => [pid, status]
  #      Process.waitpid2(pid=-1, flags=0)   => [pid, status]
  # ------------------------------------------------------------------------
  #      Waits for a child process to exit (see Process::waitpid for exact
  #      semantics) and returns an array containing the process id and the
  #      exit status (a +Process::Status+ object) of that child. Raises a
  #      +SystemError+ if there are no child processes.
  # 
  #         Process.fork { exit 99 }   #=> 27437
  #         pid, status = Process.wait2
  #         pid                        #=> 27437
  #         status.exitstatus          #=> 99
  # 
  def self.wait2(arg0, arg1, *rest)
  end

  # ----------------------------------------------------- Process::setrlimit
  #      Process.setrlimit(resource, cur_limit, max_limit)        => nil
  #      Process.setrlimit(resource, cur_limit)                   => nil
  # ------------------------------------------------------------------------
  #      Sets the resource limit of the process. _cur_limit_ means current
  #      (soft) limit and _max_limit_ means maximum (hard) limit.
  # 
  #      If _max_limit_ is not given, _cur_limit_ is used.
  # 
  #      _resource_ indicates the kind of resource to limit. The list of
  #      resources are OS dependent. Ruby may support following resources.
  # 
  # Process::RLIMIT_COREcore size (bytes) (SUSv3)
  # 
  # Process::RLIMIT_CPUCPU time (seconds) (SUSv3)
  # 
  # Process::RLIMIT_DATAdata segment (bytes) (SUSv3)
  # 
  # Process::RLIMIT_FSIZEfile size (bytes) (SUSv3)
  # 
  # Process::RLIMIT_NOFILEfile descriptors (number) (SUSv3)
  # 
  # Process::RLIMIT_STACKstack size (bytes) (SUSv3)
  # 
  # Process::RLIMIT_AStotal available memory (bytes) (SUSv3, NetBSD,
  #                   FreeBSD, OpenBSD but 4.4BSD-Lite)
  # 
  # Process::RLIMIT_MEMLOCKtotal size for mlock(2) (bytes) (4.4BSD,
  #                        GNU/Linux)
  # 
  # Process::RLIMIT_NPROCnumber of processes for the user (number) (4.4BSD,
  #                      GNU/Linux)
  # 
  # Process::RLIMIT_RSSresident memory size (bytes) (4.2BSD, GNU/Linux)
  # 
  # Process::RLIMIT_SBSIZEall socket buffers (bytes) (NetBSD, FreeBSD)
  # 
  #      Other +Process::RLIMIT_???+ constants may be defined.
  # 
  #      _cur_limit_ and _max_limit_ may be +Process::RLIM_INFINITY+, which
  #      means that the resource is not limited. They may be
  #      +Process::RLIM_SAVED_MAX+ or +Process::RLIM_SAVED_CUR+ too. See
  #      system setrlimit(2) manual for details.
  # 
  def self.setrlimit(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- Process::gid
  #      Process.gid           => fixnum
  #      Process::GID.rid      => fixnum
  #      Process::Sys.getgid   => fixnum
  # ------------------------------------------------------------------------
  #      Returns the (real) group ID for this process.
  # 
  #         Process.gid   #=> 500
  # 
  def self.gid
  end

  # --------------------------------------------------------- Process::euid=
  #      Process.euid= integer
  # ------------------------------------------------------------------------
  #      Sets the effective user ID for this process. Not available on all
  #      platforms.
  # 
  def self.euid=(arg0)
  end

  # -------------------------------------------------------- Process::setsid
  #      Process.setsid   => fixnum
  # ------------------------------------------------------------------------
  #      Establishes this process as a new session and process group leader,
  #      with no controlling tty. Returns the session id. Not available on
  #      all platforms.
  # 
  #         Process.setsid   #=> 27422
  # 
  def self.setsid
  end

  # --------------------------------------------------------- Process::times
  #      Process.times   => aStructTms
  # ------------------------------------------------------------------------
  #      Returns a +Tms+ structure (see +Struct::Tms+ on page 388) that
  #      contains user and system CPU times for this process.
  # 
  #         t = Process.times
  #         [ t.utime, t.stime ]   #=> [0.0, 0.02]
  # 
  def self.times
  end

  # ------------------------------------------------------- Process::waitall
  #      Process.waitall   => [ [pid1,status1], ...]
  # ------------------------------------------------------------------------
  #      Waits for all children, returning an array of _pid_/_status_ pairs
  #      (where _status_ is a +Process::Status+ object).
  # 
  #         fork { sleep 0.2; exit 2 }   #=> 27432
  #         fork { sleep 0.1; exit 1 }   #=> 27433
  #         fork {            exit 0 }   #=> 27434
  #         p Process.waitall
  # 
  #      _produces_:
  # 
  #         [[27434, #<Process::Status: pid=27434,exited(0)>],
  #          [27433, #<Process::Status: pid=27433,exited(1)>],
  #          [27432, #<Process::Status: pid=27432,exited(2)>]]
  # 
  def self.waitall
  end

  def self.getpgrp
  end

  # ---------------------------------------------------- Process::initgroups
  #      Process.initgroups(username, gid)   => array
  # ------------------------------------------------------------------------
  #      Initializes the supplemental group access list by reading the
  #      system group database and using all groups of which the given user
  #      is a member. The group with the specified _gid_ is also added to
  #      the list. Returns the resulting +Array+ of the gids of all the
  #      groups in the supplementary group access list. Not available on all
  #      platforms.
  # 
  #         Process.groups   #=> [0, 1, 2, 3, 4, 6, 10, 11, 20, 26, 27]
  #         Process.initgroups( "mgranger", 30 )   #=> [30, 6, 10, 11]
  #         Process.groups   #=> [30, 6, 10, 11]
  # 
  def self.initgroups(arg0, arg1)
  end

  # ------------------------------------------------------- Process::groups=
  #      Process.groups= array   => array
  # ------------------------------------------------------------------------
  #      Set the supplemental group access list to the given +Array+ of
  #      group IDs.
  # 
  #         Process.groups   #=> [0, 1, 2, 3, 4, 6, 10, 11, 20, 26, 27]
  #         Process.groups = [27, 6, 10, 11]   #=> [27, 6, 10, 11]
  #         Process.groups   #=> [27, 6, 10, 11]
  # 
  def self.groups=(arg0)
  end

  # --------------------------------------------------------- Process::abort
  #      abort
  #      Kernel::abort
  #      Process::abort
  # ------------------------------------------------------------------------
  #      Terminate execution immediately, effectively by calling
  #      +Kernel.exit(1)+. If _msg_ is given, it is written to STDERR prior
  #      to terminating.
  # 
  def self.abort(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- Process::wait
  #      Process.wait()                     => fixnum
  #      Process.wait(pid=-1, flags=0)      => fixnum
  #      Process.waitpid(pid=-1, flags=0)   => fixnum
  # ------------------------------------------------------------------------
  #      Waits for a child process to exit, returns its process id, and sets
  #      +$?+ to a +Process::Status+ object containing information on that
  #      process. Which child it waits on depends on the value of _pid_:
  # 
  #      > 0:  Waits for the child whose process ID equals _pid_.
  # 
  #      0:    Waits for any child whose process group ID equals that of the
  #            calling process.
  # 
  #      -1:   Waits for any child process (the default if no _pid_ is
  #            given).
  # 
  #      < -1: Waits for any child whose process group ID equals the
  #            absolute value of _pid_.
  # 
  #      The _flags_ argument may be a logical or of the flag values
  #      +Process::WNOHANG+ (do not block if no child available) or
  #      +Process::WUNTRACED+ (return stopped children that haven't been
  #      reported). Not all flags are available on all platforms, but a flag
  #      value of zero will work on all platforms.
  # 
  #      Calling this method raises a +SystemError+ if there are no child
  #      processes. Not available on all platforms.
  # 
  #         include Process
  #         fork { exit 99 }                 #=> 27429
  #         wait                             #=> 27429
  #         $?.exitstatus                    #=> 99
  #      
  #         pid = fork { sleep 3 }           #=> 27440
  #         Time.now                         #=> Wed Apr 09 08:57:09 CDT 2003
  #         waitpid(pid, Process::WNOHANG)   #=> nil
  #         Time.now                         #=> Wed Apr 09 08:57:09 CDT 2003
  #         waitpid(pid, 0)                  #=> 27440
  #         Time.now                         #=> Wed Apr 09 08:57:12 CDT 2003
  # 
  def self.wait(arg0, arg1, *rest)
  end

  # ----------------------------------------------------- Process::getrlimit
  #      Process.getrlimit(resource)   => [cur_limit, max_limit]
  # ------------------------------------------------------------------------
  #      Gets the resource limit of the process. _cur_limit_ means current
  #      (soft) limit and _max_limit_ means maximum (hard) limit.
  # 
  #      _resource_ indicates the kind of resource to limit: such as
  #      +Process::RLIMIT_CORE+, +Process::RLIMIT_CPU+, etc. See
  #      Process.setrlimit for details.
  # 
  #      _cur_limit_ and _max_limit_ may be +Process::RLIM_INFINITY+,
  #      +Process::RLIM_SAVED_MAX+ or +Process::RLIM_SAVED_CUR+. See
  #      Process.setrlimit and the system getrlimit(2) manual for details.
  # 
  def self.getrlimit(arg0)
  end

  # ----------------------------------------------------------- Process::uid
  #      Process.uid           => fixnum
  #      Process::UID.rid      => fixnum
  #      Process::Sys.getuid   => fixnum
  # ------------------------------------------------------------------------
  #      Returns the (real) user ID of this process.
  # 
  #         Process.uid   #=> 501
  # 
  def self.uid
  end

  # ---------------------------------------------------------- Process::gid=
  #      Process.gid= fixnum   => fixnum
  # ------------------------------------------------------------------------
  #      Sets the group ID for this process.
  # 
  def self.gid=(arg0)
  end

  # ----------------------------------------------------------- Process::pid
  #      Process.pid   => fixnum
  # ------------------------------------------------------------------------
  #      Returns the process id of this process. Not available on all
  #      platforms.
  # 
  #         Process.pid   #=> 27415
  # 
  def self.pid
  end

  # ------------------------------------------------------- Process::setpgid
  #      Process.setpgid(pid, integer)   => 0
  # ------------------------------------------------------------------------
  #      Sets the process group ID of _pid_ (0 indicates this process) to
  #      _integer_. Not available on all platforms.
  # 
  def self.setpgid(arg0, arg1)
  end

  # ---------------------------------------------------------- Process::kill
  #      Process.kill(signal, pid, ...)    => fixnum
  # ------------------------------------------------------------------------
  #      Sends the given signal to the specified process id(s), or to the
  #      current process if _pid_ is zero. _signal_ may be an integer signal
  #      number or a POSIX signal name (either with or without a +SIG+
  #      prefix). If _signal_ is negative (or starts with a minus sign),
  #      kills process groups instead of processes. Not all signals are
  #      available on all platforms.
  # 
  #         pid = fork do
  #            Signal.trap("HUP") { puts "Ouch!"; exit }
  #            # ... do some work ...
  #         end
  #         # ...
  #         Process.kill("HUP", pid)
  #         Process.wait
  # 
  #      _produces:_
  # 
  #         Ouch!
  # 
  def self.kill(arg0, arg1, *rest)
  end

  # ------------------------------------------------------ Process::waitpid2
  #      Process.wait2(pid=-1, flags=0)      => [pid, status]
  #      Process.waitpid2(pid=-1, flags=0)   => [pid, status]
  # ------------------------------------------------------------------------
  #      Waits for a child process to exit (see Process::waitpid for exact
  #      semantics) and returns an array containing the process id and the
  #      exit status (a +Process::Status+ object) of that child. Raises a
  #      +SystemError+ if there are no child processes.
  # 
  #         Process.fork { exit 99 }   #=> 27437
  #         pid, status = Process.wait2
  #         pid                        #=> 27437
  #         status.exitstatus          #=> 99
  # 
  def self.waitpid2(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- Process::ppid
  #      Process.ppid   => fixnum
  # ------------------------------------------------------------------------
  #      Returns the process id of the parent of this process. Always
  #      returns 0 on NT. Not available on all platforms.
  # 
  #         puts "I am #{Process.pid}"
  #         Process.fork { puts "Dad is #{Process.ppid}" }
  # 
  #      _produces:_
  # 
  #         I am 27417
  #         Dad is 27417
  # 
  def self.ppid
  end

  # ---------------------------------------------------------- Process::egid
  #      Process.egid          => fixnum
  #      Process::GID.eid      => fixnum
  #      Process::Sys.geteid   => fixnum
  # ------------------------------------------------------------------------
  #      Returns the effective group ID for this process. Not available on
  #      all platforms.
  # 
  #         Process.egid   #=> 500
  # 
  def self.egid
  end

end
