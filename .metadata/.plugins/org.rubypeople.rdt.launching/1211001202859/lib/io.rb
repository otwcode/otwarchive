=begin
-------------------------------------------------------------- Class: IO
     Class +IO+ is the basis for all input and output in Ruby. An I/O
     stream may be _duplexed_ (that is, bidirectional), and so may use
     more than one native operating system stream.

     Many of the examples in this section use class +File+, the only
     standard subclass of +IO+. The two classes are closely associated.

     As used in this section, _portname_ may take any of the following
     forms.

     *   A plain string represents a filename suitable for the
         underlying operating system.

     *   A string starting with ``+|+'' indicates a subprocess. The
         remainder of the string following the ``+|+'' is invoked as a
         process with appropriate input/output channels connected to it.

     *   A string equal to ``+|-+'' will create another Ruby instance as
         a subprocess.

     Ruby will convert pathnames between different operating system
     conventions if possible. For instance, on a Windows system the
     filename ``+/gumby/ruby/test.rb+'' will be opened as
     ``+\gumby\ruby\test.rb+''. When specifying a Windows-style filename
     in a Ruby string, remember to escape the backslashes:

        "c:\gumby\ruby\test.rb"

     Our examples here will use the Unix-style forward slashes;
     +File::SEPARATOR+ can be used to get the platform-specific
     separator character.

     I/O ports may be opened in any one of several different modes,
     which are shown in this section as _mode_. The mode may either be a
     Fixnum or a String. If numeric, it should be one of the operating
     system specific constants (O_RDONLY, O_WRONLY, O_RDWR, O_APPEND and
     so on). See man open(2) for more information.

     If the mode is given as a String, it must be one of the values
     listed in the following table.

       Mode |  Meaning
       -----+--------------------------------------------------------
       "r"  |  Read-only, starts at beginning of file  (default mode).
       -----+--------------------------------------------------------
       "r+" |  Read-write, starts at beginning of file.
       -----+--------------------------------------------------------
       "w"  |  Write-only, truncates existing file
            |  to zero length or creates a new file for writing.
       -----+--------------------------------------------------------
       "w+" |  Read-write, truncates existing file to zero length
            |  or creates a new file for reading and writing.
       -----+--------------------------------------------------------
       "a"  |  Write-only, starts at end of file if file exists,
            |  otherwise creates a new file for writing.
       -----+--------------------------------------------------------
       "a+" |  Read-write, starts at end of file if file exists,
            |  otherwise creates a new file for reading and
            |  writing.
       -----+--------------------------------------------------------
        "b" |  (DOS/Windows only) Binary file mode (may appear with
            |  any of the key letters listed above).

     The global constant ARGF (also accessible as $<) provides an
     IO-like stream which allows access to all files mentioned on the
     command line (or STDIN if no files are mentioned). ARGF provides
     the methods +#path+ and +#filename+ to access the name of the file
     currently being read.

------------------------------------------------------------------------


Includes:
---------
     Enumerable(all?, any?, collect, detect, each_cons, each_slice,
     each_with_index, entries, enum_cons, enum_slice, enum_with_index,
     find, find_all, grep, group_by, include?, index_by, inject, map,
     max, member?, min, partition, reject, select, sort, sort_by, sum,
     to_a, to_set, zip), File::Constants()


Constants:
----------
     SEEK_CUR: INT2FIX(SEEK_CUR)
     SEEK_END: INT2FIX(SEEK_END)
     SEEK_SET: INT2FIX(SEEK_SET)


Class methods:
--------------
     for_fd, foreach, new, open, pipe, popen, read, readlines, select,
     sysopen


Instance methods:
-----------------
     <<, binmode, block_scanf, close, close_read, close_write, closed?,
     each, each_byte, each_line, eof, eof?, fcntl, fileno, flush, fsync,
     getc, gets, inspect, ioctl, isatty, lineno, lineno=, open, pid,
     pos, pos=, print, printf, putc, puts, read, read_nonblock,
     readbytes, readchar, readline, readlines, readpartial, reopen,
     rewind, scanf, seek, soak_up_spaces, stat, sync, sync=, sysread,
     sysseek, syswrite, tell, to_i, to_io, tty?, ungetc, write,
     write_nonblock

=end
class IO < Object
  include File::Constants
  include Enumerable

  # ------------------------------------------------------------ IO::foreach
  #      IO.foreach(name, sep_string=$/) {|line| block }   => nil
  # ------------------------------------------------------------------------
  #      Executes the block for every line in the named I/O port, where
  #      lines are separated by _sep_string_.
  # 
  #         IO.foreach("testfile") {|x| print "GOT ", x }
  # 
  #      _produces:_
  # 
  #         GOT This is line one
  #         GOT This is line two
  #         GOT This is line three
  #         GOT And so on...
  # 
  def self.foreach(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- IO::popen
  #      IO.popen(cmd_string, mode="r" )               => io
  #      IO.popen(cmd_string, mode="r" ) {|io| block } => obj
  # ------------------------------------------------------------------------
  #      Runs the specified command string as a subprocess; the subprocess's
  #      standard input and output will be connected to the returned +IO+
  #      object. If _cmd_string_ starts with a ``+-+'', then a new instance
  #      of Ruby is started as the subprocess. The default mode for the new
  #      file object is ``r'', but _mode_ may be set to any of the modes
  #      listed in the description for class IO.
  # 
  #      If a block is given, Ruby will run the command as a child connected
  #      to Ruby with a pipe. Ruby's end of the pipe will be passed as a
  #      parameter to the block. At the end of block, Ruby close the pipe
  #      and sets +$?+. In this case +IO::popen+ returns the value of the
  #      block.
  # 
  #      If a block is given with a _cmd_string_ of ``+-+'', the block will
  #      be run in two separate processes: once in the parent, and once in a
  #      child. The parent process will be passed the pipe object as a
  #      parameter to the block, the child version of the block will be
  #      passed +nil+, and the child's standard in and standard out will be
  #      connected to the parent through the pipe. Not available on all
  #      platforms.
  # 
  #         f = IO.popen("uname")
  #         p f.readlines
  #         puts "Parent is #{Process.pid}"
  #         IO.popen ("date") { |f| puts f.gets }
  #         IO.popen("-") {|f| $stderr.puts "#{Process.pid} is here, f is #{f}"}
  #         p $?
  # 
  #      _produces:_
  # 
  #         ["Linux\n"]
  #         Parent is 26166
  #         Wed Apr  9 08:53:52 CDT 2003
  #         26169 is here, f is
  #         26166 is here, f is #<IO:0x401b3d44>
  #         #<Process::Status: pid=26166,exited(0)>
  # 
  def self.popen(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------- IO::for_fd
  #      IO.for_fd(fd, mode)    => io
  # ------------------------------------------------------------------------
  #      Synonym for +IO::new+.
  # 
  def self.for_fd(arg0, arg1, *rest)
  end

  # --------------------------------------------------------------- IO::read
  #      IO.read(name, [length [, offset]] )   => string
  # ------------------------------------------------------------------------
  #      Opens the file, optionally seeks to the given offset, then returns
  #      _length_ bytes (defaulting to the rest of the file). +read+ ensures
  #      the file is closed before returning.
  # 
  #         IO.read("testfile")           #=> "This is line one\nThis is line two\nThis is line three\nAnd so on...\n"
  #         IO.read("testfile", 20)       #=> "This is line one\nThi"
  #         IO.read("testfile", 20, 10)   #=> "ne one\nThis is line "
  # 
  def self.read(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------- IO::select
  #      IO.select(read_array 
  #      [, write_array 
  #      [, error_array 
  #      [, timeout]]] ) =>  array  or  nil
  # ------------------------------------------------------------------------
  #      See +Kernel#select+.
  # 
  def self.select(arg0, arg1, *rest)
  end

  # --------------------------------------------------------------- IO::pipe
  #      IO.pipe -> array
  # ------------------------------------------------------------------------
  #      Creates a pair of pipe endpoints (connected to each other) and
  #      returns them as a two-element array of +IO+ objects: +[+
  #      _read_file_, _write_file_ +]+. Not available on all platforms.
  # 
  #      In the example below, the two processes close the ends of the pipe
  #      that they are not using. This is not just a cosmetic nicety. The
  #      read end of a pipe will not generate an end of file condition if
  #      there are any writers with the pipe still open. In the case of the
  #      parent process, the +rd.read+ will never return if it does not
  #      first issue a +wr.close+.
  # 
  #         rd, wr = IO.pipe
  #      
  #         if fork
  #           wr.close
  #           puts "Parent got: <#{rd.read}>"
  #           rd.close
  #           Process.wait
  #         else
  #           rd.close
  #           puts "Sending message to parent"
  #           wr.write "Hi Dad"
  #           wr.close
  #         end
  # 
  #      _produces:_
  # 
  #         Sending message to parent
  #         Parent got: <Hi Dad>
  # 
  def self.pipe
  end

  # ---------------------------------------------------------------- IO::new
  #      IO.new(fd, mode_string)   => io
  # ------------------------------------------------------------------------
  #      Returns a new +IO+ object (a stream) for the given integer file
  #      descriptor and mode string. See also +IO#fileno+ and +IO::for_fd+.
  # 
  #         a = IO.new(2,"w")      # '2' is standard error
  #         $stderr.puts "Hello"
  #         a.puts "World"
  # 
  #      _produces:_
  # 
  #         Hello
  #         World
  # 
  def self.new(arg0, arg1, *rest)
  end

  # --------------------------------------------------------------- IO::open
  #      IO.open(fd, mode_string="r" )               => io
  #      IO.open(fd, mode_string="r" ) {|io| block } => obj
  # ------------------------------------------------------------------------
  #      With no associated block, +open+ is a synonym for +IO::new+. If the
  #      optional code block is given, it will be passed _io_ as an
  #      argument, and the IO object will automatically be closed when the
  #      block terminates. In this instance, +IO::open+ returns the value of
  #      the block.
  # 
  def self.open(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ IO::sysopen
  #      IO.sysopen(path, [mode, [perm]])  => fixnum
  # ------------------------------------------------------------------------
  #      Opens the given path, returning the underlying file descriptor as a
  #      +Fixnum+.
  # 
  #         IO.sysopen("testfile")   #=> 3
  # 
  def self.sysopen(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- IO::readlines
  #      IO.readlines(name, sep_string=$/)   => array
  # ------------------------------------------------------------------------
  #      Reads the entire file specified by _name_ as individual lines, and
  #      returns those lines in an array. Lines are separated by
  #      _sep_string_.
  # 
  #         a = IO.readlines("testfile")
  #         a[0]   #=> "This is line one\n"
  # 
  def self.readlines(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------------- IO#putc
  #      ios.putc(obj)    => obj
  # ------------------------------------------------------------------------
  #      If _obj_ is +Numeric+, write the character whose code is _obj_,
  #      otherwise write the first character of the string representation of
  #      _obj_ to _ios_.
  # 
  #         $stdout.putc "A"
  #         $stdout.putc 65
  # 
  #      _produces:_
  # 
  #         AA
  # 
  def putc
  end

  # -------------------------------------------------------------- IO#fileno
  #      ios.fileno    => fixnum
  #      ios.to_i      => fixnum
  # ------------------------------------------------------------------------
  #      Returns an integer representing the numeric file descriptor for
  #      _ios_.
  # 
  #         $stdin.fileno    #=> 0
  #         $stdout.fileno   #=> 1
  # 
  # 
  #      (also known as to_i)
  def fileno
  end

  # ---------------------------------------------------------------- IO#tell
  #      ios.pos     => integer
  #      ios.tell    => integer
  # ------------------------------------------------------------------------
  #      Returns the current offset (in bytes) of _ios_.
  # 
  #         f = File.new("testfile")
  #         f.pos    #=> 0
  #         f.gets   #=> "This is line one\n"
  #         f.pos    #=> 17
  # 
  def tell
  end

  # ---------------------------------------------------------- IO#close_read
  #      ios.close_read    => nil
  # ------------------------------------------------------------------------
  #      Closes the read end of a duplex I/O stream (i.e., one that contains
  #      both a read and a write stream, such as a pipe). Will raise an
  #      +IOError+ if the stream is not duplexed.
  # 
  #         f = IO.popen("/bin/sh","r+")
  #         f.close_read
  #         f.readlines
  # 
  #      _produces:_
  # 
  #         prog.rb:3:in `readlines': not opened for reading (IOError)
  #          from prog.rb:3
  # 
  def close_read
  end

  # --------------------------------------------------------- IO#readpartial
  #      ios.readpartial(maxlen)              => string
  #      ios.readpartial(maxlen, outbuf)      => outbuf
  # ------------------------------------------------------------------------
  #      Reads at most _maxlen_ bytes from the I/O stream. It blocks only if
  #      _ios_ has no data immediately available. It doesn't block if some
  #      data available. If the optional _outbuf_ argument is present, it
  #      must reference a String, which will receive the data. It raises
  #      +EOFError+ on end of file.
  # 
  #      readpartial is designed for streams such as pipe, socket, tty, etc.
  #      It blocks only when no data immediately available. This means that
  #      it blocks only when following all conditions hold.
  # 
  #      *   the buffer in the IO object is empty.
  # 
  #      *   the content of the stream is empty.
  # 
  #      *   the stream is not reached to EOF.
  # 
  #      When readpartial blocks, it waits data or EOF on the stream. If
  #      some data is reached, readpartial returns with the data. If EOF is
  #      reached, readpartial raises EOFError.
  # 
  #      When readpartial doesn't blocks, it returns or raises immediately.
  #      If the buffer is not empty, it returns the data in the buffer.
  #      Otherwise if the stream has some content, it returns the data in
  #      the stream. Otherwise if the stream is reached to EOF, it raises
  #      EOFError.
  # 
  #         r, w = IO.pipe           #               buffer          pipe content
  #         w << "abc"               #               ""              "abc".
  #         r.readpartial(4096)      #=> "abc"       ""              ""
  #         r.readpartial(4096)      # blocks because buffer and pipe is empty.
  #      
  #         r, w = IO.pipe           #               buffer          pipe content
  #         w << "abc"               #               ""              "abc"
  #         w.close                  #               ""              "abc" EOF
  #         r.readpartial(4096)      #=> "abc"       ""              EOF
  #         r.readpartial(4096)      # raises EOFError
  #      
  #         r, w = IO.pipe           #               buffer          pipe content
  #         w << "abc\ndef\n"        #               ""              "abc\ndef\n"
  #         r.gets                   #=> "abc\n"     "def\n"         ""
  #         w << "ghi\n"             #               "def\n"         "ghi\n"
  #         r.readpartial(4096)      #=> "def\n"     ""              "ghi\n"
  #         r.readpartial(4096)      #=> "ghi\n"     ""              ""
  # 
  #      Note that readpartial behaves similar to sysread. The differences
  #      are:
  # 
  #      *   If the buffer is not empty, read from the buffer instead of
  #          "sysread for buffered IO (IOError)".
  # 
  #      *   It doesn't cause Errno::EAGAIN and Errno::EINTR. When
  #          readpartial meets EAGAIN and EINTR by read system call,
  #          readpartial retry the system call.
  # 
  #      The later means that readpartial is nonblocking-flag insensitive.
  #      It blocks on the situation IO#sysread causes Errno::EAGAIN as if
  #      the fd is blocking mode.
  # 
  def readpartial
  end

  # ----------------------------------------------------------------- IO#eof
  #      ios.eof     => true or false
  #      ios.eof?    => true or false
  # ------------------------------------------------------------------------
  #      Returns true if _ios_ is at end of file that means there are no
  #      more data to read. The stream must be opened for reading or an
  #      +IOError+ will be raised.
  # 
  #         f = File.new("testfile")
  #         dummy = f.readlines
  #         f.eof   #=> true
  # 
  #      If _ios_ is a stream such as pipe or socket, +IO#eof?+ blocks until
  #      the other end sends some data or closes it.
  # 
  #         r, w = IO.pipe
  #         Thread.new { sleep 1; w.close }
  #         r.eof?  #=> true after 1 second blocking
  #      
  #         r, w = IO.pipe
  #         Thread.new { sleep 1; w.puts "a" }
  #         r.eof?  #=> false after 1 second blocking
  #      
  #         r, w = IO.pipe
  #         r.eof?  # blocks forever
  # 
  #      Note that +IO#eof?+ reads data to a input buffer. So +IO#sysread+
  #      doesn't work with +IO#eof?+.
  # 
  def eof
  end

  # --------------------------------------------------------------- IO#fcntl
  #      ios.fcntl(integer_cmd, arg)    => integer
  # ------------------------------------------------------------------------
  #      Provides a mechanism for issuing low-level commands to control or
  #      query file-oriented I/O streams. Arguments and results are platform
  #      dependent. If _arg_ is a number, its value is passed directly. If
  #      it is a string, it is interpreted as a binary sequence of bytes
  #      (+Array#pack+ might be a useful way to build this string). On Unix
  #      platforms, see +fcntl(2)+ for details. Not implemented on all
  #      platforms.
  # 
  def fcntl
  end

  # ---------------------------------------------------------------- IO#each
  #      ios.each(sep_string=$/)      {|line| block }  => ios
  #      ios.each_line(sep_string=$/) {|line| block }  => ios
  # ------------------------------------------------------------------------
  #      Executes the block for every line in _ios_, where lines are
  #      separated by _sep_string_. _ios_ must be opened for reading or an
  #      +IOError+ will be raised.
  # 
  #         f = File.new("testfile")
  #         f.each {|line| puts "#{f.lineno}: #{line}" }
  # 
  #      _produces:_
  # 
  #         1: This is line one
  #         2: This is line two
  #         3: This is line three
  #         4: And so on...
  # 
  def each
  end

  # ---------------------------------------------------------------- IO#sync
  #      ios.sync    => true or false
  # ------------------------------------------------------------------------
  #      Returns the current ``sync mode'' of _ios_. When sync mode is true,
  #      all output is immediately flushed to the underlying operating
  #      system and is not buffered by Ruby internally. See also +IO#fsync+.
  # 
  #         f = File.new("testfile")
  #         f.sync   #=> false
  # 
  def sync
  end

  # ------------------------------------------------------------- IO#lineno=
  #      ios.lineno = integer    => integer
  # ------------------------------------------------------------------------
  #      Manually sets the current line number to the given value. +$.+ is
  #      updated only on the next read.
  # 
  #         f = File.new("testfile")
  #         f.gets                     #=> "This is line one\n"
  #         $.                         #=> 1
  #         f.lineno = 1000
  #         f.lineno                   #=> 1000
  #         $. # lineno of last read   #=> 1
  #         f.gets                     #=> "This is line two\n"
  #         $. # lineno of last read   #=> 1001
  # 
  def lineno=
  end

  # ------------------------------------------------------------ IO#readline
  #      ios.readline(sep_string=$/)   => string
  # ------------------------------------------------------------------------
  #      Reads a line as with +IO#gets+, but raises an +EOFError+ on end of
  #      file.
  # 
  def readline
  end

  # --------------------------------------------------------------- IO#print
  #      ios.print()             => nil
  #      ios.print(obj, ...)     => nil
  # ------------------------------------------------------------------------
  #      Writes the given object(s) to _ios_. The stream must be opened for
  #      writing. If the output record separator (+$\+) is not +nil+, it
  #      will be appended to the output. If no arguments are given, prints
  #      +$_+. Objects that aren't strings will be converted by calling
  #      their +to_s+ method. With no argument, prints the contents of the
  #      variable +$_+. Returns +nil+.
  # 
  #         $stdout.print("This is ", 100, " percent.\n")
  # 
  #      _produces:_
  # 
  #         This is 100 percent.
  # 
  def print
  end

  # ------------------------------------------------------------- IO#sysread
  #      ios.sysread(integer )    => string
  # ------------------------------------------------------------------------
  #      Reads _integer_ bytes from _ios_ using a low-level read and returns
  #      them as a string. Do not mix with other methods that read from
  #      _ios_ or you may get unpredictable results. Raises
  #      +SystemCallError+ on error and +EOFError+ at end of file.
  # 
  #         f = File.new("testfile")
  #         f.sysread(16)   #=> "This is line one"
  # 
  def sysread
  end

  # --------------------------------------------------------------- IO#flush
  #      ios.flush    => ios
  # ------------------------------------------------------------------------
  #      Flushes any buffered data within _ios_ to the underlying operating
  #      system (note that this is Ruby internal buffering only; the OS may
  #      buffer the data as well).
  # 
  #         $stdout.print "no newline"
  #         $stdout.flush
  # 
  #      _produces:_
  # 
  #         no newline
  # 
  def flush
  end

  # ---------------------------------------------------------------- IO#to_i
  #      to_i()
  # ------------------------------------------------------------------------
  #      Alias for #fileno
  # 
  def to_i
  end

  # ------------------------------------------------------ IO#write_nonblock
  #      ios.write_nonblock(string)   => integer
  # ------------------------------------------------------------------------
  #      Writes the given string to _ios_ using write(2) system call after
  #      O_NONBLOCK is set for the underlying file descriptor.
  # 
  #      write_nonblock just calls write(2). It causes all errors write(2)
  #      causes: EAGAIN, EINTR, etc. The result may also be smaller than
  #      string.length (partial write). The caller should care such errors
  #      and partial write.
  # 
  def write_nonblock
  end

  # ---------------------------------------------------------------- IO#getc
  #      ios.getc   => fixnum or nil
  # ------------------------------------------------------------------------
  #      Gets the next 8-bit byte (0..255) from _ios_. Returns +nil+ if
  #      called at end of file.
  # 
  #         f = File.new("testfile")
  #         f.getc   #=> 84
  #         f.getc   #=> 104
  # 
  def getc
  end

  # ------------------------------------------------------------------ IO#<<
  #      ios << obj     => ios
  # ------------------------------------------------------------------------
  #      String Output---Writes _obj_ to _ios_. _obj_ will be converted to a
  #      string using +to_s+.
  # 
  #         $stdout << "Hello " << "world!\n"
  # 
  #      _produces:_
  # 
  #         Hello world!
  # 
  def <<
  end

  # ----------------------------------------------------------------- IO#pos
  #      ios.pos     => integer
  #      ios.tell    => integer
  # ------------------------------------------------------------------------
  #      Returns the current offset (in bytes) of _ios_.
  # 
  #         f = File.new("testfile")
  #         f.pos    #=> 0
  #         f.gets   #=> "This is line one\n"
  #         f.pos    #=> 17
  # 
  def pos
  end

  # ---------------------------------------------------------------- IO#eof?
  #      ios.eof     => true or false
  #      ios.eof?    => true or false
  # ------------------------------------------------------------------------
  #      Returns true if _ios_ is at end of file that means there are no
  #      more data to read. The stream must be opened for reading or an
  #      +IOError+ will be raised.
  # 
  #         f = File.new("testfile")
  #         dummy = f.readlines
  #         f.eof   #=> true
  # 
  #      If _ios_ is a stream such as pipe or socket, +IO#eof?+ blocks until
  #      the other end sends some data or closes it.
  # 
  #         r, w = IO.pipe
  #         Thread.new { sleep 1; w.close }
  #         r.eof?  #=> true after 1 second blocking
  #      
  #         r, w = IO.pipe
  #         Thread.new { sleep 1; w.puts "a" }
  #         r.eof?  #=> false after 1 second blocking
  #      
  #         r, w = IO.pipe
  #         r.eof?  # blocks forever
  # 
  #      Note that +IO#eof?+ reads data to a input buffer. So +IO#sysread+
  #      doesn't work with +IO#eof?+.
  # 
  def eof?
  end

  # --------------------------------------------------------------- IO#ioctl
  #      ios.ioctl(integer_cmd, arg)    => integer
  # ------------------------------------------------------------------------
  #      Provides a mechanism for issuing low-level commands to control or
  #      query I/O devices. Arguments and results are platform dependent. If
  #      _arg_ is a number, its value is passed directly. If it is a string,
  #      it is interpreted as a binary sequence of bytes. On Unix platforms,
  #      see +ioctl(2)+ for details. Not implemented on all platforms.
  # 
  def ioctl
  end

  # ---------------------------------------------------------------- IO#stat
  #      ios.stat    => stat
  # ------------------------------------------------------------------------
  #      Returns status information for _ios_ as an object of type
  #      +File::Stat+.
  # 
  #         f = File.new("testfile")
  #         s = f.stat
  #         "%o" % s.mode   #=> "100644"
  #         s.blksize       #=> 4096
  #         s.atime         #=> Wed Apr 09 08:53:54 CDT 2003
  # 
  def stat
  end

  # --------------------------------------------------------------- IO#fsync
  #      ios.fsync   => 0 or nil
  # ------------------------------------------------------------------------
  #      Immediately writes all buffered data in _ios_ to disk. Returns
  #      +nil+ if the underlying operating system does not support
  #      _fsync(2)_. Note that +fsync+ differs from using +IO#sync=+. The
  #      latter ensures that data is flushed from Ruby's buffers, but
  #      doesn't not guarantee that the underlying operating system actually
  #      writes it to disk.
  # 
  def fsync
  end

  # --------------------------------------------------------------- IO#sync=
  #      ios.sync = boolean   => boolean
  # ------------------------------------------------------------------------
  #      Sets the ``sync mode'' to +true+ or +false+. When sync mode is
  #      true, all output is immediately flushed to the underlying operating
  #      system and is not buffered internally. Returns the new state. See
  #      also +IO#fsync+.
  # 
  #         f = File.new("testfile")
  #         f.sync = true
  # 
  #      _(produces no output)_
  # 
  def sync=
  end

  # ---------------------------------------------------------------- IO#gets
  #      ios.gets(sep_string=$/)   => string or nil
  # ------------------------------------------------------------------------
  #      Reads the next ``line'' from the I/O stream; lines are separated by
  #      _sep_string_. A separator of +nil+ reads the entire contents, and a
  #      zero-length separator reads the input a paragraph at a time (two
  #      successive newlines in the input separate paragraphs). The stream
  #      must be opened for reading or an +IOError+ will be raised. The line
  #      read in will be returned and also assigned to +$_+. Returns +nil+
  #      if called at end of file.
  # 
  #         File.new("testfile").gets   #=> "This is line one\n"
  #         $_                          #=> "This is line one\n"
  # 
  def gets
  end

  # -------------------------------------------------------------- IO#isatty
  #      ios.isatty   => true or false
  #      ios.tty?     => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _ios_ is associated with a terminal device (tty),
  #      +false+ otherwise.
  # 
  #         File.new("testfile").isatty   #=> false
  #         File.new("/dev/tty").isatty   #=> true
  # 
  def isatty
  end

  # -------------------------------------------------------------- IO#printf
  #      ios.printf(format_string [, obj, ...] )   => nil
  # ------------------------------------------------------------------------
  #      Formats and writes to _ios_, converting parameters under control of
  #      the format string. See +Kernel#sprintf+ for details.
  # 
  def printf
  end

  # ------------------------------------------------------------ IO#syswrite
  #      ios.syswrite(string)   => integer
  # ------------------------------------------------------------------------
  #      Writes the given string to _ios_ using a low-level write. Returns
  #      the number of bytes written. Do not mix with other methods that
  #      write to _ios_ or you may get unpredictable results. Raises
  #      +SystemCallError+ on error.
  # 
  #         f = File.new("out", "w")
  #         f.syswrite("ABCDEF")   #=> 6
  # 
  def syswrite
  end

  # -------------------------------------------------------------- IO#ungetc
  #      ios.ungetc(integer)   => nil
  # ------------------------------------------------------------------------
  #      Pushes back one character (passed as a parameter) onto _ios_, such
  #      that a subsequent buffered read will return it. Only one character
  #      may be pushed back before a subsequent read operation (that is, you
  #      will be able to read only the last of several characters that have
  #      been pushed back). Has no effect with unbuffered reads (such as
  #      +IO#sysread+).
  # 
  #         f = File.new("testfile")   #=> #<File:testfile>
  #         c = f.getc                 #=> 84
  #         f.ungetc(c)                #=> nil
  #         f.getc                     #=> 84
  # 
  def ungetc
  end

  def close
  end

  # ----------------------------------------------------------- IO#each_byte
  #      ios.each_byte {|byte| block }  => nil
  # ------------------------------------------------------------------------
  #      Calls the given block once for each byte (0..255) in _ios_, passing
  #      the byte as an argument. The stream must be opened for reading or
  #      an +IOError+ will be raised.
  # 
  #         f = File.new("testfile")
  #         checksum = 0
  #         f.each_byte {|x| checksum ^= x }   #=> #<File:testfile>
  #         checksum                           #=> 12
  # 
  def each_byte
  end

  # ------------------------------------------------------- IO#read_nonblock
  #      ios.read_nonblock(maxlen)              => string
  #      ios.read_nonblock(maxlen, outbuf)      => outbuf
  # ------------------------------------------------------------------------
  #      Reads at most _maxlen_ bytes from _ios_ using read(2) system call
  #      after O_NONBLOCK is set for the underlying file descriptor.
  # 
  #      If the optional _outbuf_ argument is present, it must reference a
  #      String, which will receive the data.
  # 
  #      read_nonblock just calls read(2). It causes all errors read(2)
  #      causes: EAGAIN, EINTR, etc. The caller should care such errors.
  # 
  #      read_nonblock causes EOFError on EOF.
  # 
  #      If the read buffer is not empty, read_nonblock reads from the
  #      buffer like readpartial. In this case, read(2) is not called.
  # 
  def read_nonblock
  end

  # ---------------------------------------------------------------- IO#read
  #      ios.read([length [, buffer]])    => string, buffer, or nil
  # ------------------------------------------------------------------------
  #      Reads at most _length_ bytes from the I/O stream, or to the end of
  #      file if _length_ is omitted or is +nil+. _length_ must be a
  #      non-negative integer or nil. If the optional _buffer_ argument is
  #      present, it must reference a String, which will receive the data.
  # 
  #      At end of file, it returns +nil+ or +""+ depend on _length_.
  #      +_ios_.read()+ and +_ios_.read(nil)+ returns +""+.
  #      +_ios_.read(_positive-integer_)+ returns nil.
  # 
  #         f = File.new("testfile")
  #         f.read(16)   #=> "This is line one"
  # 
  def read
  end

  # -------------------------------------------------------------- IO#rewind
  #      ios.rewind    => 0
  # ------------------------------------------------------------------------
  #      Positions _ios_ to the beginning of input, resetting +lineno+ to
  #      zero.
  # 
  #         f = File.new("testfile")
  #         f.readline   #=> "This is line one\n"
  #         f.rewind     #=> 0
  #         f.lineno     #=> 0
  #         f.readline   #=> "This is line one\n"
  # 
  def rewind
  end

  # ---------------------------------------------------------------- IO#pos=
  #      ios.pos = integer    => integer
  # ------------------------------------------------------------------------
  #      Seeks to the given position (in bytes) in _ios_.
  # 
  #         f = File.new("testfile")
  #         f.pos = 17
  #         f.gets   #=> "This is line two\n"
  # 
  def pos=
  end

  # ------------------------------------------------------------- IO#sysseek
  #      ios.sysseek(offset, whence=SEEK_SET)   => integer
  # ------------------------------------------------------------------------
  #      Seeks to a given _offset_ in the stream according to the value of
  #      _whence_ (see +IO#seek+ for values of _whence_). Returns the new
  #      offset into the file.
  # 
  #         f = File.new("testfile")
  #         f.sysseek(-13, IO::SEEK_END)   #=> 53
  #         f.sysread(10)                  #=> "And so on."
  # 
  def sysseek
  end

  # ---------------------------------------------------------------- IO#puts
  #      ios.puts(obj, ...)    => nil
  # ------------------------------------------------------------------------
  #      Writes the given objects to _ios_ as with +IO#print+. Writes a
  #      record separator (typically a newline) after any that do not
  #      already end with a newline sequence. If called with an array
  #      argument, writes each element on a new line. If called without
  #      arguments, outputs a single record separator.
  # 
  #         $stdout.puts("this", "is", "a", "test")
  # 
  #      _produces:_
  # 
  #         this
  #         is
  #         a
  #         test
  # 
  def puts
  end

  # --------------------------------------------------------------- IO#to_io
  #      ios.to_io -> ios
  # ------------------------------------------------------------------------
  #      Returns _ios_.
  # 
  def to_io
  end

  # ---------------------------------------------------------------- IO#seek
  #      ios.seek(amount, whence=SEEK_SET) -> 0
  # ------------------------------------------------------------------------
  #      Seeks to a given offset _anInteger_ in the stream according to the
  #      value of _whence_:
  # 
  #        IO::SEEK_CUR  | Seeks to <em>amount</em> plus current position
  #        --------------+----------------------------------------------------
  #        IO::SEEK_END  | Seeks to <em>amount</em> plus end of stream (you probably
  #                      | want a negative value for <em>amount</em>)
  #        --------------+----------------------------------------------------
  #        IO::SEEK_SET  | Seeks to the absolute location given by <em>amount</em>
  # 
  #      Example:
  # 
  #         f = File.new("testfile")
  #         f.seek(-13, IO::SEEK_END)   #=> 0
  #         f.readline                  #=> "And so on...\n"
  # 
  def seek
  end

  # --------------------------------------------------------- IO#close_write
  #      ios.close_write   => nil
  # ------------------------------------------------------------------------
  #      Closes the write end of a duplex I/O stream (i.e., one that
  #      contains both a read and a write stream, such as a pipe). Will
  #      raise an +IOError+ if the stream is not duplexed.
  # 
  #         f = IO.popen("/bin/sh","r+")
  #         f.close_write
  #         f.print "nowhere"
  # 
  #      _produces:_
  # 
  #         prog.rb:3:in `write': not opened for writing (IOError)
  #          from prog.rb:3:in `print'
  #          from prog.rb:3
  # 
  def close_write
  end

  # ---------------------------------------------------------------- IO#tty?
  #      ios.isatty   => true or false
  #      ios.tty?     => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _ios_ is associated with a terminal device (tty),
  #      +false+ otherwise.
  # 
  #         File.new("testfile").isatty   #=> false
  #         File.new("/dev/tty").isatty   #=> true
  # 
  def tty?
  end

  # -------------------------------------------------------------- IO#reopen
  #      ios.reopen(other_IO)         => ios 
  #      ios.reopen(path, mode_str)   => ios
  # ------------------------------------------------------------------------
  #      Reassociates _ios_ with the I/O stream given in _other_IO_ or to a
  #      new stream opened on _path_. This may dynamically change the actual
  #      class of this stream.
  # 
  #         f1 = File.new("testfile")
  #         f2 = File.new("testfile")
  #         f2.readlines[0]   #=> "This is line one\n"
  #         f2.reopen(f1)     #=> #<File:testfile>
  #         f2.readlines[0]   #=> "This is line one\n"
  # 
  def reopen
  end

  # ------------------------------------------------------------ IO#readchar
  #      ios.readchar   => fixnum
  # ------------------------------------------------------------------------
  #      Reads a character as with +IO#getc+, but raises an +EOFError+ on
  #      end of file.
  # 
  def readchar
  end

  # ------------------------------------------------------------- IO#closed?
  #      ios.closed?    => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _ios_ is completely closed (for duplex streams,
  #      both reader and writer), +false+ otherwise.
  # 
  #         f = File.new("testfile")
  #         f.close         #=> nil
  #         f.closed?       #=> true
  #         f = IO.popen("/bin/sh","r+")
  #         f.close_write   #=> nil
  #         f.closed?       #=> false
  #         f.close_read    #=> nil
  #         f.closed?       #=> true
  # 
  def closed?
  end

  # ----------------------------------------------------------------- IO#pid
  #      ios.pid    => fixnum
  # ------------------------------------------------------------------------
  #      Returns the process ID of a child process associated with _ios_.
  #      This will be set by +IO::popen+.
  # 
  #         pipe = IO.popen("-")
  #         if pipe
  #           $stderr.puts "In parent, child pid is #{pipe.pid}"
  #         else
  #           $stderr.puts "In child, pid is #{$$}"
  #         end
  # 
  #      _produces:_
  # 
  #         In child, pid is 26209
  #         In parent, child pid is 26209
  # 
  def pid
  end

  # ----------------------------------------------------------- IO#each_line
  #      ios.each(sep_string=$/)      {|line| block }  => ios
  #      ios.each_line(sep_string=$/) {|line| block }  => ios
  # ------------------------------------------------------------------------
  #      Executes the block for every line in _ios_, where lines are
  #      separated by _sep_string_. _ios_ must be opened for reading or an
  #      +IOError+ will be raised.
  # 
  #         f = File.new("testfile")
  #         f.each {|line| puts "#{f.lineno}: #{line}" }
  # 
  #      _produces:_
  # 
  #         1: This is line one
  #         2: This is line two
  #         3: This is line three
  #         4: And so on...
  # 
  def each_line
  end

  # -------------------------------------------------------------- IO#lineno
  #      ios.lineno    => integer
  # ------------------------------------------------------------------------
  #      Returns the current line number in _ios_. The stream must be opened
  #      for reading. +lineno+ counts the number of times +gets+ is called,
  #      rather than the number of newlines encountered. The two values will
  #      differ if +gets+ is called with a separator other than newline. See
  #      also the +$.+ variable.
  # 
  #         f = File.new("testfile")
  #         f.lineno   #=> 0
  #         f.gets     #=> "This is line one\n"
  #         f.lineno   #=> 1
  #         f.gets     #=> "This is line two\n"
  #         f.lineno   #=> 2
  # 
  def lineno
  end

  # ----------------------------------------------------------- IO#readlines
  #      ios.readlines(sep_string=$/)  =>   array
  # ------------------------------------------------------------------------
  #      Reads all of the lines in _ios_, and returns them in _anArray_.
  #      Lines are separated by the optional _sep_string_. If _sep_string_
  #      is +nil+, the rest of the stream is returned as a single record.
  #      The stream must be opened for reading or an +IOError+ will be
  #      raised.
  # 
  #         f = File.new("testfile")
  #         f.readlines[0]   #=> "This is line one\n"
  # 
  def readlines
  end

  # --------------------------------------------------------------- IO#write
  #      ios.write(string)    => integer
  # ------------------------------------------------------------------------
  #      Writes the given string to _ios_. The stream must be opened for
  #      writing. If the argument is not a string, it will be converted to a
  #      string using +to_s+. Returns the number of bytes written.
  # 
  #         count = $stdout.write( "This is a test\n" )
  #         puts "That was #{count} bytes of data"
  # 
  #      _produces:_
  # 
  #         This is a test
  #         That was 15 bytes of data
  # 
  def write
  end

  # ------------------------------------------------------------- IO#binmode
  #      ios.binmode    => ios
  # ------------------------------------------------------------------------
  #      Puts _ios_ into binary mode. This is useful only in MS-DOS/Windows
  #      environments. Once a stream is in binary mode, it cannot be reset
  #      to nonbinary mode.
  # 
  def binmode
  end

  # ------------------------------------------------------------- IO#inspect
  #      ios.inspect   => string
  # ------------------------------------------------------------------------
  #      Return a string describing this IO object.
  # 
  def inspect
  end

end
