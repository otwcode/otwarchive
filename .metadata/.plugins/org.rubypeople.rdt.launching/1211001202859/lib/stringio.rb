=begin
-------------------------------------------------------- Class: StringIO
     Pseudo I/O on String object.

------------------------------------------------------------------------


Includes:
---------
     Enumerable(all?, any?, collect, detect, each_cons, each_slice,
     each_with_index, entries, enum_cons, enum_slice, enum_with_index,
     find, find_all, grep, group_by, include?, index_by, inject, map,
     max, member?, min, partition, reject, select, sort, sort_by, sum,
     to_a, to_set, zip)


Class methods:
--------------
     new, new, open


Instance methods:
-----------------
     <<, binmode, close, close_read, close_write, closed?, closed_read?,
     closed_write?, each, each_byte, each_line, eof, eof, eof?, eof?,
     fcntl, fileno, flush, fsync, getc, gets, isatty, length, lineno,
     lineno=, path, pid, pos, pos, pos=, print, printf, putc, puts,
     read, readchar, readline, readline, readlines, reopen, rewind,
     rewind, seek, seek, size, string, string=, sync, sync=, sysread,
     syswrite, tell, truncate, tty?, ungetc, write

=end
class StringIO < Data
  include Enumerable

  # --------------------------------------------------------- StringIO::open
  #       StringIO.open(string=""[, mode]) {|strio| ...}
  # ------------------------------------------------------------------------
  #      Equivalent to StringIO.new except that when it is called with a
  #      block, it yields with the new instance and closes it, and returns
  #      the result which returned from the block.
  # 
  def self.open(arg0, arg1, *rest)
  end

  # ---------------------------------------------------- StringIO#close_read
  #      strio.close_read    -> nil
  # ------------------------------------------------------------------------
  #      Closes the read end of a StringIO. Will raise an +IOError+ if the
  #      *strio* is not readable.
  # 
  def close_read
  end

  # ---------------------------------------------------------- StringIO#tell
  #      strio.pos     -> integer
  #      strio.tell    -> integer
  # ------------------------------------------------------------------------
  #      Returns the current offset (in bytes) of *strio*.
  # 
  def tell
  end

  # ---------------------------------------------------------- StringIO#putc
  #      strio.putc(obj)    -> obj
  # ------------------------------------------------------------------------
  #      See IO#putc.
  # 
  def putc(arg0)
  end

  # -------------------------------------------------------- StringIO#fileno
  #       strio.fileno -> nil 
  # ------------------------------------------------------------------------
  #      Returns +nil+. Just for compatibility to IO.
  # 
  def fileno
  end

  # -------------------------------------------------------- StringIO#string
  #       strio.string     -> string
  # ------------------------------------------------------------------------
  #      Returns underlying String object, the subject of IO.
  # 
  def string
  end

  # ----------------------------------------------------------- StringIO#eof
  #      strio.eof     -> true or false
  #      strio.eof?    -> true or false
  # ------------------------------------------------------------------------
  #      Returns true if *strio* is at end of file. The stringio must be
  #      opened for reading or an +IOError+ will be raised.
  # 
  def eof
  end

  # --------------------------------------------------------- StringIO#fcntl
  #       strio.fcntl 
  # ------------------------------------------------------------------------
  #      Raises NotImplementedError.
  # 
  def fcntl(arg0, arg1, *rest)
  end

  # ------------------------------------------------------- StringIO#lineno=
  #      strio.lineno = integer    -> integer
  # ------------------------------------------------------------------------
  #      Manually sets the current line number to the given value. +$.+ is
  #      updated only on the next read.
  # 
  def lineno=(arg0)
  end

  # ---------------------------------------------------------- StringIO#sync
  #      strio.sync    -> true
  # ------------------------------------------------------------------------
  #      Returns +true+ always.
  # 
  def sync
  end

  # ---------------------------------------------------------- StringIO#each
  #      strio.each(sep_string=$/)      {|line| block }  -> strio
  #      strio.each_line(sep_string=$/) {|line| block }  -> strio
  # ------------------------------------------------------------------------
  #      See IO#each.
  # 
  def each(arg0, arg1, *rest)
  end

  # ------------------------------------------------------ StringIO#readline
  #      strio.readline(sep_string=$/)   -> string
  # ------------------------------------------------------------------------
  #      See IO#readline.
  # 
  def readline(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- StringIO#size
  #      strio.size   -> integer
  # ------------------------------------------------------------------------
  #      Returns the size of the buffer string.
  # 
  def size
  end

  # ------------------------------------------------- StringIO#closed_write?
  #      strio.closed_write?    -> true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if *strio* is not writable, +false+ otherwise.
  # 
  def closed_write?
  end

  # --------------------------------------------------------- StringIO#flush
  #       strio.flush -> strio 
  # ------------------------------------------------------------------------
  #      Returns *strio* itself. Just for compatibility to IO.
  # 
  def flush
  end

  # ---------------------------------------------------------- StringIO#path
  #       strio.path -> nil 
  # ------------------------------------------------------------------------
  #      Returns +nil+. Just for compatibility to IO.
  # 
  def path
  end

  # ------------------------------------------------------- StringIO#sysread
  #      strio.sysread(integer[, outbuf])    -> string
  # ------------------------------------------------------------------------
  #      Similar to #read, but raises +EOFError+ at end of string instead of
  #      returning +nil+, as well as IO#sysread does.
  # 
  def sysread(arg0, arg1, *rest)
  end

  # --------------------------------------------------------- StringIO#print
  #      strio.print()             -> nil
  #      strio.print(obj, ...)     -> nil
  # ------------------------------------------------------------------------
  #      See IO#print.
  # 
  def print(arg0, arg1, *rest)
  end

  # ------------------------------------------------------- StringIO#string=
  #      strio.string = string  -> string
  # ------------------------------------------------------------------------
  #      Changes underlying String object, the subject of IO.
  # 
  def string=(arg0)
  end

  # ---------------------------------------------------------- StringIO#eof?
  #      strio.eof     -> true or false
  #      strio.eof?    -> true or false
  # ------------------------------------------------------------------------
  #      Returns true if *strio* is at end of file. The stringio must be
  #      opened for reading or an +IOError+ will be raised.
  # 
  def eof?
  end

  # ----------------------------------------------------------- StringIO#pos
  #      strio.pos     -> integer
  #      strio.tell    -> integer
  # ------------------------------------------------------------------------
  #      Returns the current offset (in bytes) of *strio*.
  # 
  def pos
  end

  # ---------------------------------------------------------- StringIO#getc
  #      strio.getc   -> fixnum or nil
  # ------------------------------------------------------------------------
  #      See IO#getc.
  # 
  def getc
  end

  # ------------------------------------------------------------ StringIO#<<
  #      strio << obj     -> strio
  # ------------------------------------------------------------------------
  #      See IO#<<.
  # 
  def <<(arg0)
  end

  # ------------------------------------------------------ StringIO#truncate
  #      strio.truncate(integer)    -> 0
  # ------------------------------------------------------------------------
  #      Truncates the buffer string to at most _integer_ bytes. The *strio*
  #      must be opened for writing.
  # 
  def truncate(arg0)
  end

  # --------------------------------------------------------- StringIO#fsync
  #       strio.fsync -> 0 
  # ------------------------------------------------------------------------
  #      Returns 0. Just for compatibility to IO.
  # 
  def fsync
  end

  # --------------------------------------------------------- StringIO#sync=
  #       strio.sync = boolean -> boolean 
  # ------------------------------------------------------------------------
  #      Returns the argument unchanged. Just for compatibility to IO.
  # 
  def sync=(arg0)
  end

  # ---------------------------------------------------------- StringIO#gets
  #      strio.gets(sep_string=$/)   -> string or nil
  # ------------------------------------------------------------------------
  #      See IO#gets.
  # 
  def gets(arg0, arg1, *rest)
  end

  # -------------------------------------------------------- StringIO#isatty
  #      strio.isatty -> nil
  #      strio.tty? -> nil
  # ------------------------------------------------------------------------
  #      Returns +false+. Just for compatibility to IO.
  # 
  def isatty
  end

  # -------------------------------------------------------- StringIO#length
  #      strio.size   -> integer
  # ------------------------------------------------------------------------
  #      Returns the size of the buffer string.
  # 
  def length
  end

  # --------------------------------------------------------- StringIO#close
  #      strio.close  -> nil
  # ------------------------------------------------------------------------
  #      Closes strio. The *strio* is unavailable for any further data
  #      operations; an +IOError+ is raised if such an attempt is made.
  # 
  def close
  end

  # -------------------------------------------------- StringIO#closed_read?
  #      strio.closed_read?    -> true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if *strio* is not readable, +false+ otherwise.
  # 
  def closed_read?
  end

  # -------------------------------------------------------- StringIO#ungetc
  #      strio.ungetc(integer)   -> nil
  # ------------------------------------------------------------------------
  #      Pushes back one character (passed as a parameter) onto *strio* such
  #      that a subsequent buffered read will return it. Pushing back behind
  #      the beginning of the buffer string is not possible. Nothing will be
  #      done if such an attempt is made. In other case, there is no
  #      limitation for multiple pushbacks.
  # 
  def ungetc(arg0)
  end

  # -------------------------------------------------------- StringIO#printf
  #      strio.printf(format_string [, obj, ...] )   -> nil
  # ------------------------------------------------------------------------
  #      See IO#printf.
  # 
  def printf(arg0, arg1, *rest)
  end

  # ------------------------------------------------------ StringIO#syswrite
  #      strio.write(string)    -> integer
  #      strio.syswrite(string) -> integer
  # ------------------------------------------------------------------------
  #      Appends the given string to the underlying buffer string of
  #      *strio*. The stream must be opened for writing. If the argument is
  #      not a string, it will be converted to a string using +to_s+.
  #      Returns the number of bytes written. See IO#write.
  # 
  def syswrite(arg0)
  end

  # ---------------------------------------------------------- StringIO#pos=
  #      strio.pos = integer    -> integer
  # ------------------------------------------------------------------------
  #      Seeks to the given position (in bytes) in *strio*.
  # 
  def pos=(arg0)
  end

  # -------------------------------------------------------- StringIO#rewind
  #      rewind()
  # ------------------------------------------------------------------------
  #      (no description...)
  def rewind
  end

  # ----------------------------------------------------- StringIO#each_byte
  #      strio.each_byte {|byte| block }  -> strio
  # ------------------------------------------------------------------------
  #      See IO#each_byte.
  # 
  def each_byte
  end

  # ---------------------------------------------------------- StringIO#read
  #      strio.read([length [, buffer]])    -> string, buffer, or nil
  # ------------------------------------------------------------------------
  #      See IO#read.
  # 
  def read(arg0, arg1, *rest)
  end

  # --------------------------------------------------- StringIO#close_write
  #      strio.close_write    -> nil
  # ------------------------------------------------------------------------
  #      Closes the write end of a StringIO. Will raise an +IOError+ if the
  #      *strio* is not writeable.
  # 
  def close_write
  end

  # ---------------------------------------------------------- StringIO#seek
  #      strio.seek(amount, whence=SEEK_SET) -> 0
  # ------------------------------------------------------------------------
  #      Seeks to a given offset _amount_ in the stream according to the
  #      value of _whence_ (see IO#seek).
  # 
  def seek(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- StringIO#puts
  #      strio.puts(obj, ...)    -> nil
  # ------------------------------------------------------------------------
  #      See IO#puts.
  # 
  def puts(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- StringIO#tty?
  #      strio.isatty -> nil
  #      strio.tty? -> nil
  # ------------------------------------------------------------------------
  #      Returns +false+. Just for compatibility to IO.
  # 
  def tty?
  end

  # -------------------------------------------------------- StringIO#reopen
  #      strio.reopen(other_StrIO)     -> strio
  #      strio.reopen(string, mode)    -> strio
  # ------------------------------------------------------------------------
  #      Reinitializes *strio* with the given _other_StrIO_ or _string_ and
  #      _mode_ (see StringIO#new).
  # 
  def reopen(arg0, arg1, *rest)
  end

  # ------------------------------------------------------- StringIO#closed?
  #      strio.closed?    -> true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if *strio* is completely closed, +false+ otherwise.
  # 
  def closed?
  end

  # ------------------------------------------------------ StringIO#readchar
  #      strio.readchar   -> fixnum
  # ------------------------------------------------------------------------
  #      See IO#readchar.
  # 
  def readchar
  end

  # ----------------------------------------------------------- StringIO#pid
  #       strio.pid -> nil 
  # ------------------------------------------------------------------------
  #      Returns +nil+. Just for compatibility to IO.
  # 
  def pid
  end

  # -------------------------------------------------------- StringIO#lineno
  #      strio.lineno    -> integer
  # ------------------------------------------------------------------------
  #      Returns the current line number in *strio*. The stringio must be
  #      opened for reading. +lineno+ counts the number of times +gets+ is
  #      called, rather than the number of newlines encountered. The two
  #      values will differ if +gets+ is called with a separator other than
  #      newline. See also the +$.+ variable.
  # 
  def lineno
  end

  # ------------------------------------------------------- StringIO#binmode
  #       strio.binmode -> true 
  # ------------------------------------------------------------------------
  #      Returns *strio* itself. Just for compatibility to IO.
  # 
  def binmode
  end

  # ----------------------------------------------------- StringIO#each_line
  #      strio.each(sep_string=$/)      {|line| block }  -> strio
  #      strio.each_line(sep_string=$/) {|line| block }  -> strio
  # ------------------------------------------------------------------------
  #      See IO#each.
  # 
  def each_line(arg0, arg1, *rest)
  end

  # ----------------------------------------------------- StringIO#readlines
  #      strio.readlines(sep_string=$/)  ->   array
  # ------------------------------------------------------------------------
  #      See IO#readlines.
  # 
  def readlines(arg0, arg1, *rest)
  end

  # --------------------------------------------------------- StringIO#write
  #      strio.write(string)    -> integer
  #      strio.syswrite(string) -> integer
  # ------------------------------------------------------------------------
  #      Appends the given string to the underlying buffer string of
  #      *strio*. The stream must be opened for writing. If the argument is
  #      not a string, it will be converted to a string using +to_s+.
  #      Returns the number of bytes written. See IO#write.
  # 
  def write(arg0)
  end

end
