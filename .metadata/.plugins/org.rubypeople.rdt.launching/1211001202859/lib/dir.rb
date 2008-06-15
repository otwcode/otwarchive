=begin
------------------------------------------------------------- Class: Dir
     tmpdir - retrieve temporary directory path

     $Id: tmpdir.rb 11708 2007-02-12 23:01:19Z shyouhei $

------------------------------------------------------------------------


Includes:
---------
     Enumerable(all?, any?, collect, detect, each_cons, each_slice,
     each_with_index, entries, enum_cons, enum_slice, enum_with_index,
     find, find_all, grep, group_by, include?, index_by, inject, map,
     max, member?, min, partition, reject, select, sort, sort_by, sum,
     to_a, to_set, zip), Windows::DeviceIO(CTL_CODE,
     FSCTL_CREATE_USN_JOURNAL, FSCTL_DELETE_USN_JOURNAL,
     FSCTL_EXTEND_VOLUME, FSCTL_QUERY_USN_JOURNAL,
     FSCTL_READ_FILE_USN_DATA, FSCTL_READ_USN_JOURNAL,
     FSCTL_SET_COMPRESSION, FSCTL_SET_SPARSE,
     FSCTL_WRITE_USN_CLOSE_RECORD), Windows::Directory(),
     Windows::Error(get_last_error), Windows::File(), Windows::Shell()


Constants:
----------
     VERSION: '0.3.2'


Class methods:
--------------
     [], chdir, chroot, create_junction, delete, empty?, entries,
     foreach, getwd, glob, junction?, mkdir, new, open, pwd, rmdir,
     tmpdir, unlink


Instance methods:
-----------------
     close, each, path, pos, pos=, read, rewind, seek, tell

=end
class Dir < Object
  include Enumerable

  # ----------------------------------------------------------- Dir::foreach
  #      Dir.foreach( dirname ) {| filename | block }  => nil
  # ------------------------------------------------------------------------
  #      Calls the block once for each entry in the named directory, passing
  #      the filename of each entry as a parameter to the block.
  # 
  #         Dir.foreach("testdir") {|x| puts "Got #{x}" }
  # 
  #      _produces:_
  # 
  #         Got .
  #         Got ..
  #         Got config.h
  #         Got main.rb
  # 
  def self.foreach(arg0)
  end

  # ------------------------------------------------------------- Dir::mkdir
  #      Dir.mkdir( string [, integer] ) => 0
  # ------------------------------------------------------------------------
  #      Makes a new directory named by _string_, with permissions specified
  #      by the optional parameter _anInteger_. The permissions may be
  #      modified by the value of +File::umask+, and are ignored on NT.
  #      Raises a +SystemCallError+ if the directory cannot be created. See
  #      also the discussion of permissions in the class documentation for
  #      +File+.
  # 
  def self.mkdir(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------- Dir::chdir
  #      Dir.chdir( [ string] ) => 0
  #      Dir.chdir( [ string] ) {| path | block }  => anObject
  # ------------------------------------------------------------------------
  #      Changes the current working directory of the process to the given
  #      string. When called without an argument, changes the directory to
  #      the value of the environment variable +HOME+, or +LOGDIR+.
  #      +SystemCallError+ (probably +Errno::ENOENT+) if the target
  #      directory does not exist.
  # 
  #      If a block is given, it is passed the name of the new current
  #      directory, and the block is executed with that as the current
  #      directory. The original working directory is restored when the
  #      block exits. The return value of +chdir+ is the value of the block.
  #      +chdir+ blocks can be nested, but in a multi-threaded program an
  #      error will be raised if a thread attempts to open a +chdir+ block
  #      while another thread has one open.
  # 
  #         Dir.chdir("/var/spool/mail")
  #         puts Dir.pwd
  #         Dir.chdir("/tmp") do
  #           puts Dir.pwd
  #           Dir.chdir("/usr") do
  #             puts Dir.pwd
  #           end
  #           puts Dir.pwd
  #         end
  #         puts Dir.pwd
  # 
  #      _produces:_
  # 
  #         /var/spool/mail
  #         /tmp
  #         /usr
  #         /tmp
  #         /var/spool/mail
  # 
  def self.chdir(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------------- Dir::[]
  #      Dir[ array ]                 => array
  #      Dir[ string [, string ...] ] => array
  # ------------------------------------------------------------------------
  #      Equivalent to calling +Dir.glob(+_array,_+0)+ and
  #      +Dir.glob([+_string,..._+],0)+.
  # 
  def self.[](arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ Dir::chroot
  #      Dir.chroot( string ) => 0
  # ------------------------------------------------------------------------
  #      Changes this process's idea of the file system root. Only a
  #      privileged process may make this call. Not available on all
  #      platforms. On Unix systems, see +chroot(2)+ for more information.
  # 
  def self.chroot(arg0)
  end

  # -------------------------------------------------------------- Dir::glob
  #      Dir.glob( pattern, [flags] ) => array
  #      Dir.glob( pattern, [flags] ) {| filename | block }  => nil
  # ------------------------------------------------------------------------
  #      Returns the filenames found by expanding _pattern_ which is an
  #      +Array+ of the patterns or the pattern +String+, either as an
  #      _array_ or as parameters to the block. Note that this pattern is
  #      not a regexp (it's closer to a shell glob). See +File::fnmatch+ for
  #      the meaning of the _flags_ parameter. Note that case sensitivity
  #      depends on your system (so +File::FNM_CASEFOLD+ is ignored)
  # 
  #      <code>*</code>:     Matches any file. Can be restricted by other
  #                          values in the glob. +*+ will match all files;
  #                          +c*+ will match all files beginning with +c+;
  #                          +*c+ will match all files ending with +c+; and
  #                          *+c+* will match all files that have +c+ in
  #                          them (including at the beginning or end).
  #                          Equivalent to +/ .* /x+ in regexp.
  # 
  #      <code>**</code>:    Matches directories recursively.
  # 
  #      <code>?</code>:     Matches any one character. Equivalent to
  #                          +/.{1}/+ in regexp.
  # 
  #      <code>[set]</code>: Matches any one character in +set+. Behaves
  #                          exactly like character sets in Regexp,
  #                          including set negation (+[^a-z]+).
  # 
  #      <code>{p,q}</code>: Matches either literal +p+ or literal +q+.
  #                          Matching literals may be more than one
  #                          character in length. More than two literals may
  #                          be specified. Equivalent to pattern alternation
  #                          in regexp.
  # 
  #      <code>\</code>:     Escapes the next metacharacter.
  # 
  #         Dir["config.?"]                     #=> ["config.h"]
  #         Dir.glob("config.?")                #=> ["config.h"]
  #         Dir.glob("*.[a-z][a-z]")            #=> ["main.rb"]
  #         Dir.glob("*.[^r]*")                 #=> ["config.h"]
  #         Dir.glob("*.{rb,h}")                #=> ["main.rb", "config.h"]
  #         Dir.glob("*")                       #=> ["config.h", "main.rb"]
  #         Dir.glob("*", File::FNM_DOTMATCH)   #=> [".", "..", "config.h", "main.rb"]
  #      
  #         rbfiles = File.join("**", "*.rb")
  #         Dir.glob(rbfiles)                   #=> ["main.rb",
  #                                                  "lib/song.rb",
  #                                                  "lib/song/karaoke.rb"]
  #         libdirs = File.join("**", "lib")
  #         Dir.glob(libdirs)                   #=> ["lib"]
  #      
  #         librbfiles = File.join("**", "lib", "**", "*.rb")
  #         Dir.glob(librbfiles)                #=> ["lib/song.rb",
  #                                                  "lib/song/karaoke.rb"]
  #      
  #         librbfiles = File.join("**", "lib", "*.rb")
  #         Dir.glob(librbfiles)                #=> ["lib/song.rb"]
  # 
  def self.glob(arg0, arg1, *rest)
  end

  # --------------------------------------------------------------- Dir::pwd
  #      Dir.getwd => string
  #      Dir.pwd => string
  # ------------------------------------------------------------------------
  #      Returns the path to the current working directory of this process
  #      as a string.
  # 
  #         Dir.chdir("/tmp")   #=> 0
  #         Dir.getwd           #=> "/tmp"
  # 
  def self.pwd
  end

  # ------------------------------------------------------------ Dir::unlink
  #      Dir.delete( string ) => 0
  #      Dir.rmdir( string ) => 0
  #      Dir.unlink( string ) => 0
  # ------------------------------------------------------------------------
  #      Deletes the named directory. Raises a subclass of +SystemCallError+
  #      if the directory isn't empty.
  # 
  def self.unlink(arg0)
  end

  # ----------------------------------------------------------- Dir::entries
  #      Dir.entries( dirname ) => array
  # ------------------------------------------------------------------------
  #      Returns an array containing all of the filenames in the given
  #      directory. Will raise a +SystemCallError+ if the named directory
  #      doesn't exist.
  # 
  #         Dir.entries("testdir")   #=> [".", "..", "config.h", "main.rb"]
  # 
  def self.entries(arg0)
  end

  # ------------------------------------------------------------- Dir::rmdir
  #      Dir.delete( string ) => 0
  #      Dir.rmdir( string ) => 0
  #      Dir.unlink( string ) => 0
  # ------------------------------------------------------------------------
  #      Deletes the named directory. Raises a subclass of +SystemCallError+
  #      if the directory isn't empty.
  # 
  def self.rmdir(arg0)
  end

  # -------------------------------------------------------------- Dir::open
  #      Dir.open( string ) => aDir
  #      Dir.open( string ) {| aDir | block } => anObject
  # ------------------------------------------------------------------------
  #      With no block, +open+ is a synonym for +Dir::new+. If a block is
  #      present, it is passed _aDir_ as a parameter. The directory is
  #      closed at the end of the block, and +Dir::open+ returns the value
  #      of the block.
  # 
  def self.open(arg0)
  end

  # ------------------------------------------------------------- Dir::getwd
  #      Dir.getwd => string
  #      Dir.pwd => string
  # ------------------------------------------------------------------------
  #      Returns the path to the current working directory of this process
  #      as a string.
  # 
  #         Dir.chdir("/tmp")   #=> 0
  #         Dir.getwd           #=> "/tmp"
  # 
  def self.getwd
  end

  # ------------------------------------------------------------ Dir::delete
  #      Dir.delete( string ) => 0
  #      Dir.rmdir( string ) => 0
  #      Dir.unlink( string ) => 0
  # ------------------------------------------------------------------------
  #      Deletes the named directory. Raises a subclass of +SystemCallError+
  #      if the directory isn't empty.
  # 
  def self.delete(arg0)
  end

  # --------------------------------------------------------------- Dir#tell
  #      dir.pos => integer
  #      dir.tell => integer
  # ------------------------------------------------------------------------
  #      Returns the current position in _dir_. See also +Dir#seek+.
  # 
  #         d = Dir.new("testdir")
  #         d.tell   #=> 0
  #         d.read   #=> "."
  #         d.tell   #=> 12
  # 
  def tell
  end

  # --------------------------------------------------------------- Dir#each
  #      dir.each { |filename| block }  => dir
  # ------------------------------------------------------------------------
  #      Calls the block once for each entry in this directory, passing the
  #      filename of each entry as a parameter to the block.
  # 
  #         d = Dir.new("testdir")
  #         d.each  {|x| puts "Got #{x}" }
  # 
  #      _produces:_
  # 
  #         Got .
  #         Got ..
  #         Got config.h
  #         Got main.rb
  # 
  def each
  end

  # --------------------------------------------------------------- Dir#path
  #      dir.path => string or nil
  # ------------------------------------------------------------------------
  #      Returns the path parameter passed to _dir_'s constructor.
  # 
  #         d = Dir.new("..")
  #         d.path   #=> ".."
  # 
  def path
  end

  # ---------------------------------------------------------------- Dir#pos
  #      dir.pos => integer
  #      dir.tell => integer
  # ------------------------------------------------------------------------
  #      Returns the current position in _dir_. See also +Dir#seek+.
  # 
  #         d = Dir.new("testdir")
  #         d.tell   #=> 0
  #         d.read   #=> "."
  #         d.tell   #=> 12
  # 
  def pos
  end

  # -------------------------------------------------------------- Dir#close
  #      dir.close => nil
  # ------------------------------------------------------------------------
  #      Closes the directory stream. Any further attempts to access _dir_
  #      will raise an +IOError+.
  # 
  #         d = Dir.new("testdir")
  #         d.close   #=> nil
  # 
  def close
  end

  # --------------------------------------------------------------- Dir#read
  #      dir.read => string or nil
  # ------------------------------------------------------------------------
  #      Reads the next entry from _dir_ and returns it as a string. Returns
  #      +nil+ at the end of the stream.
  # 
  #         d = Dir.new("testdir")
  #         d.read   #=> "."
  #         d.read   #=> ".."
  #         d.read   #=> "config.h"
  # 
  def read
  end

  # ------------------------------------------------------------- Dir#rewind
  #      dir.rewind => dir
  # ------------------------------------------------------------------------
  #      Repositions _dir_ to the first entry.
  # 
  #         d = Dir.new("testdir")
  #         d.read     #=> "."
  #         d.rewind   #=> #<Dir:0x401b3fb0>
  #         d.read     #=> "."
  # 
  def rewind
  end

  # --------------------------------------------------------------- Dir#pos=
  #      dir.pos( integer ) => integer
  # ------------------------------------------------------------------------
  #      Synonym for +Dir#seek+, but returns the position parameter.
  # 
  #         d = Dir.new("testdir")   #=> #<Dir:0x401b3c40>
  #         d.read                   #=> "."
  #         i = d.pos                #=> 12
  #         d.read                   #=> ".."
  #         d.pos = i                #=> 12
  #         d.read                   #=> ".."
  # 
  def pos=
  end

  # --------------------------------------------------------------- Dir#seek
  #      dir.seek( integer ) => dir
  # ------------------------------------------------------------------------
  #      Seeks to a particular location in _dir_. _integer_ must be a value
  #      returned by +Dir#tell+.
  # 
  #         d = Dir.new("testdir")   #=> #<Dir:0x401b3c40>
  #         d.read                   #=> "."
  #         i = d.tell               #=> 12
  #         d.read                   #=> ".."
  #         d.seek(i)                #=> #<Dir:0x401b3c40>
  #         d.read                   #=> ".."
  # 
  def seek
  end

end
