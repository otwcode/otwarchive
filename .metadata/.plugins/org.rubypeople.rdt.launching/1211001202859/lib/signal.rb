=begin
---------------------------------------------------------- Class: Signal
     Many operating systems allow signals to be sent to running
     processes. Some signals have a defined effect on the process, while
     others may be trapped at the code level and acted upon. For
     example, your process may trap the USR1 signal and use it to toggle
     debugging, and may use TERM to initiate a controlled shutdown.

         pid = fork do
           Signal.trap("USR1") do
             $debug = !$debug
             puts "Debug now: #$debug"
           end
           Signal.trap("TERM") do
             puts "Terminating..."
             shutdown()
           end
           # . . . do some work . . .
         end
     
         Process.detach(pid)
     
         # Controlling program:
         Process.kill("USR1", pid)
         # ...
         Process.kill("USR1", pid)
         # ...
         Process.kill("TERM", pid)

     produces:

         Debug now: true
         Debug now: false
        Terminating...

     The list of available signal names and their interpretation is
     system dependent. Signal delivery semantics may also vary between
     systems; in particular signal delivery may not always be reliable.

------------------------------------------------------------------------


Class methods:
--------------
     list, trap

=end
module Signal

  # ----------------------------------------------------------- Signal::trap
  #      Signal.trap( signal, proc ) => obj
  #      Signal.trap( signal ) {| | block } => obj
  # ------------------------------------------------------------------------
  #      Specifies the handling of signals. The first parameter is a signal
  #      name (a string such as ``SIGALRM'', ``SIGUSR1'', and so on) or a
  #      signal number. The characters ``SIG'' may be omitted from the
  #      signal name. The command or block specifies code to be run when the
  #      signal is raised. If the command is the string ``IGNORE'' or
  #      ``SIG_IGN'', the signal will be ignored. If the command is
  #      ``DEFAULT'' or ``SIG_DFL'', the operating system's default handler
  #      will be invoked. If the command is ``EXIT'', the script will be
  #      terminated by the signal. Otherwise, the given command or block
  #      will be run. The special signal name ``EXIT'' or signal number zero
  #      will be invoked just prior to program termination. trap returns the
  #      previous handler for the given signal.
  # 
  #          Signal.trap(0, proc { puts "Terminating: #{$$}" })
  #          Signal.trap("CLD")  { puts "Child died" }
  #          fork && Process.wait
  # 
  #      produces:
  # 
  #          Terminating: 27461
  #          Child died
  #          Terminating: 27460
  # 
  def self.trap(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- Signal::list
  #      Signal.list => a_hash
  # ------------------------------------------------------------------------
  #      Returns a list of signal names mapped to the corresponding
  #      underlying signal numbers.
  # 
  #      Signal.list #=> {"ABRT"=>6, "ALRM"=>14, "BUS"=>7, "CHLD"=>17,
  #      "CLD"=>17, "CONT"=>18, "FPE"=>8, "HUP"=>1, "ILL"=>4, "INT"=>2,
  #      "IO"=>29, "IOT"=>6, "KILL"=>9, "PIPE"=>13, "POLL"=>29, "PROF"=>27,
  #      "PWR"=>30, "QUIT"=>3, "SEGV"=>11, "STOP"=>19, "SYS"=>31,
  #      "TERM"=>15, "TRAP"=>5, "TSTP"=>20, "TTIN"=>21, "TTOU"=>22,
  #      "URG"=>23, "USR1"=>10, "USR2"=>12, "VTALRM"=>26, "WINCH"=>28,
  #      "XCPU"=>24, "XFSZ"=>25}
  # 
  def self.list
  end

end
