=begin
------------------------------------------------------------ Class: File

FTOOLS.RB: EXTRA TOOLS FOR THE FILE CLASS
=========================================
     Author:        WATANABE, Hirofumi

     Documentation: Zachary Landau

     This library can be distributed under the terms of the Ruby
     license. You can freely distribute/modify this library.

     It is included in the Ruby standard library.


Description
-----------
     ftools adds several (class, not instance) methods to the File
     class, for copying, moving, deleting, installing, and comparing
     files, as well as creating a directory path. See the File class for
     details.

     FileUtils contains all or nearly all the same functionality and
     more, and is a recommended option over ftools

     When you

       require 'ftools'

     then the File class aquires some utility methods for copying,
     moving, and deleting files, and more.

     See the method descriptions below, and consider using FileUtils as
     it is more comprehensive.

------------------------------------------------------------------------


Includes:
---------
     Windows::DeviceIO(CTL_CODE, FSCTL_CREATE_USN_JOURNAL,
     FSCTL_DELETE_USN_JOURNAL, FSCTL_EXTEND_VOLUME,
     FSCTL_QUERY_USN_JOURNAL, FSCTL_READ_FILE_USN_DATA,
     FSCTL_READ_USN_JOURNAL, FSCTL_SET_COMPRESSION, FSCTL_SET_SPARSE,
     FSCTL_WRITE_USN_CLOSE_RECORD), Windows::Error(get_last_error),
     Windows::File(), Windows::Limits(), Windows::Security()


Constants:
----------
     ADD:             0x001201bf
     ALT_SEPARATOR:   Qnil
     ARCHIVE:         FILE_ATTRIBUTE_ARCHIVE
     BUFSIZE:         8 * 1024
     CHANGE:          FILE_GENERIC_WRITE | FILE_GENERIC_READ |
                      FILE_EXECUTE | DELETE
     COMPRESSED:      FILE_ATTRIBUTE_COMPRESSED
     CONTENT_INDEXED: 0x0002000
     FULL:            STANDARD_RIGHTS_ALL | FILE_READ_DATA |
                      FILE_WRITE_DATA |       FILE_APPEND_DATA |
                      FILE_READ_EA | FILE_WRITE_EA | FILE_EXECUTE |     
                       FILE_DELETE_CHILD | FILE_READ_ATTRIBUTES |
                      FILE_WRITE_ATTRIBUTES
     HIDDEN:          FILE_ATTRIBUTE_HIDDEN
     INDEXED:         0x0002000
     MAX_PATH:        260
     NORMAL:          FILE_ATTRIBUTE_NORMAL
     OFFLINE:         FILE_ATTRIBUTE_OFFLINE
     PATH_SEPARATOR:  rb_obj_freeze(rb_str_new2(PATH_SEP))
     READ:            FILE_GENERIC_READ | FILE_EXECUTE
     READONLY:        FILE_ATTRIBUTE_READONLY
     SECURITY_RIGHTS: {       'FULL'    => FULL,       'DELETE'  =>
                      DELETE,        'READ'    => READ,        'CHANGE' 
                      => CHANGE,       'ADD'     => ADD
     SEPARATOR:       separator
     SYSTEM:          FILE_ATTRIBUTE_SYSTEM
     Separator:       separator
     TEMPORARY:       FILE_ATTRIBUTE_TEMPORARY
     VERSION:         '0.5.4'


Class methods:
--------------
     archive?, atime, atomic_write, attributes, basename, blksize,
     blockdev?, catname, chardev?, chmod, chown, compare, compressed?,
     copy, ctime, decrypt, delete, directory?, dirname, encrypt,
     encrypted?, executable?, executable_real?, exist?, exists?,
     expand_path, extname, file?, fnmatch, fnmatch?, ftype,
     get_permissions, grpowned?, hidden?, identical?, indexed?, install,
     join, lchmod, lchown, link, long_path, lstat, makedirs, move,
     mtime, new, normal?, offline?, owned?, pipe?, read, readable?,
     readable_real?, readlink, readonly?, remove_attributes, rename,
     reparse_point?, safe_unlink, securities, set_attributes,
     set_permissions, setgid?, setuid?, short_path, size, size?,
     socket?, sparse?, split, stat, sticky?, symlink, symlink?, syscopy,
     system?, temporary?, truncate, umask, unlink, utime, writable?,
     writable_real?, zero?


Instance methods:
-----------------
     archive=, atime, chmod, chown, compressed=, content_indexed=,
     ctime, flock, hidden=, indexed=, lstat, mtime, normal=, o_chmod,
     offline=, path, readonly=, sparse=, stat, system=, temporary=,
     truncate

=end
class File < IO
  include File::Constants
  include Enumerable

  # ------------------------------------------------------ File::executable?
  #      File.executable?(file_name)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file is executable by the effective
  #      user id of this process.
  # 
  def self.executable?(arg0)
  end

  # ---------------------------------------------------------- File::setuid?
  #      File.setuid?(file_name)   =>  true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file has the setuid bit set.
  # 
  def self.setuid?(arg0)
  end

  # ------------------------------------------------------------ File::ctime
  #      File.ctime(file_name)  => time
  # ------------------------------------------------------------------------
  #      Returns the change time for the named file (the time at which
  #      directory information about the file was changed, not the file
  #      itself).
  # 
  #         File.ctime("testfile")   #=> Wed Apr 09 08:53:13 CDT 2003
  # 
  def self.ctime(arg0)
  end

  # ------------------------------------------------------------ File::umask
  #      File.umask()          => integer
  #      File.umask(integer)   => integer
  # ------------------------------------------------------------------------
  #      Returns the current umask value for this process. If the optional
  #      argument is given, set the umask to that value and return the
  #      previous value. Umask values are _subtracted_ from the default
  #      permissions, so a umask of +0222+ would make a file read-only for
  #      everyone.
  # 
  #         File.umask(0006)   #=> 18
  #         File.umask         #=> 6
  # 
  def self.umask(arg0, arg1, *rest)
  end

  # -------------------------------------------------------- File::readable?
  #      File.readable?(file_name)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file is readable by the effective user
  #      id of this process.
  # 
  def self.readable?(arg0)
  end

  # --------------------------------------------------------- File::symlink?
  #      File.symlink?(file_name)   =>  true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file is a symbolic link.
  # 
  def self.symlink?(arg0)
  end

  def self.lstat(arg0)
  end

  # ---------------------------------------------------------- File::symlink
  #      File.symlink(old_name, new_name)   => 0
  # ------------------------------------------------------------------------
  #      Creates a symbolic link called _new_name_ for the existing file
  #      _old_name_. Raises a +NotImplemented+ exception on platforms that
  #      do not support symbolic links.
  # 
  #         File.symlink("testfile", "link2test")   #=> 0
  # 
  def self.symlink(arg0, arg1)
  end

  # ------------------------------------------------------------- File::join
  #      File.join(string, ...) -> path
  # ------------------------------------------------------------------------
  #      Returns a new string formed by joining the strings using
  #      +File::SEPARATOR+.
  # 
  #         File.join("usr", "mail", "gumby")   #=> "usr/mail/gumby"
  # 
  def self.join(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ File::size?
  #      File.size?(file_name)   => Integer or nil
  # ------------------------------------------------------------------------
  #      Returns +nil+ if +file_name+ doesn't exist or has zero size, the
  #      size of the file otherwise.
  # 
  def self.size?(arg0)
  end

  def self.size(arg0)
  end

  # ------------------------------------------------------- File::identical?
  #      File.identical?(file_1, file_2)   =>  true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named files are identical.
  # 
  #          open("a", "w") {}
  #          p File.identical?("a", "a")      #=> true
  #          p File.identical?("a", "./a")    #=> true
  #          File.link("a", "b")
  #          p File.identical?("a", "b")      #=> true
  #          File.symlink("a", "c")
  #          p File.identical?("a", "c")      #=> true
  #          open("d", "w") {}
  #          p File.identical?("a", "d")      #=> false
  # 
  def self.identical?(arg0, arg1)
  end

  # ------------------------------------------------------------ File::chown
  #      File.chown(owner_int, group_int, file_name,... ) -> integer
  # ------------------------------------------------------------------------
  #      Changes the owner and group of the named file(s) to the given
  #      numeric owner and group id's. Only a process with superuser
  #      privileges may change the owner of a file. The current owner of a
  #      file may change the file's group to any group to which the owner
  #      belongs. A +nil+ or -1 owner or group id is ignored. Returns the
  #      number of files processed.
  # 
  #         File.chown(nil, 100, "testfile")
  # 
  def self.chown(arg0, arg1, *rest)
  end

  def self.dirname(arg0)
  end

  # ---------------------------------------------------------- File::fnmatch
  #      File.fnmatch( pattern, path, [flags] ) => (true or false)
  #      File.fnmatch?( pattern, path, [flags] ) => (true or false)
  # ------------------------------------------------------------------------
  #      Returns true if _path_ matches against _pattern_ The pattern is not
  #      a regular expression; instead it follows rules similar to shell
  #      filename globbing. It may contain the following metacharacters:
  # 
  #      <code>*</code>:     Matches any file. Can be restricted by other
  #                          values in the glob. +*+ will match all files;
  #                          +c*+ will match all files beginning with +c+;
  #                          +*c+ will match all files ending with +c+; and
  #                          *+c+* will match all files that have +c+ in
  #                          them (including at the beginning or end).
  #                          Equivalent to +/ .* /x+ in regexp.
  # 
  #      <code>**</code>:    Matches directories recursively or files
  #                          expansively.
  # 
  #      <code>?</code>:     Matches any one character. Equivalent to
  #                          +/.{1}/+ in regexp.
  # 
  #      <code>[set]</code>: Matches any one character in +set+. Behaves
  #                          exactly like character sets in Regexp,
  #                          including set negation (+[^a-z]+).
  # 
  #      <code>\</code>:     Escapes the next metacharacter.
  # 
  #      _flags_ is a bitwise OR of the +FNM_xxx+ parameters. The same glob
  #      pattern and flags are used by +Dir::glob+.
  # 
  #         File.fnmatch('cat',       'cat')        #=> true  : match entire string
  #         File.fnmatch('cat',       'category')   #=> false : only match partial string
  #         File.fnmatch('c{at,ub}s', 'cats')       #=> false : { } isn't supported
  #      
  #         File.fnmatch('c?t',     'cat')          #=> true  : '?' match only 1 character
  #         File.fnmatch('c??t',    'cat')          #=> false : ditto
  #         File.fnmatch('c*',      'cats')         #=> true  : '*' match 0 or more characters
  #         File.fnmatch('c*t',     'c/a/b/t')      #=> true  : ditto
  #         File.fnmatch('ca[a-z]', 'cat')          #=> true  : inclusive bracket expression
  #         File.fnmatch('ca[^t]',  'cat')          #=> false : exclusive bracket expression ('^' or '!')
  #      
  #         File.fnmatch('cat', 'CAT')                     #=> false : case sensitive
  #         File.fnmatch('cat', 'CAT', File::FNM_CASEFOLD) #=> true  : case insensitive
  #      
  #         File.fnmatch('?',   '/', File::FNM_PATHNAME)  #=> false : wildcard doesn't match '/' on FNM_PATHNAME
  #         File.fnmatch('*',   '/', File::FNM_PATHNAME)  #=> false : ditto
  #         File.fnmatch('[/]', '/', File::FNM_PATHNAME)  #=> false : ditto
  #      
  #         File.fnmatch('\?',   '?')                       #=> true  : escaped wildcard becomes ordinary
  #         File.fnmatch('\a',   'a')                       #=> true  : escaped ordinary remains ordinary
  #         File.fnmatch('\a',   '\a', File::FNM_NOESCAPE)  #=> true  : FNM_NOESACPE makes '\' ordinary
  #         File.fnmatch('[\?]', '?')                       #=> true  : can escape inside bracket expression
  #      
  #         File.fnmatch('*',   '.profile')                      #=> false : wildcard doesn't match leading
  #         File.fnmatch('*',   '.profile', File::FNM_DOTMATCH)  #=> true    period by default.
  #         File.fnmatch('.*',  '.profile')                      #=> true
  #      
  #         rbfiles = '**' '/' '*.rb' # you don't have to do like this. just write in single string.
  #         File.fnmatch(rbfiles, 'main.rb')                    #=> false
  #         File.fnmatch(rbfiles, './main.rb')                  #=> false
  #         File.fnmatch(rbfiles, 'lib/song.rb')                #=> true
  #         File.fnmatch('**.rb', 'main.rb')                    #=> true
  #         File.fnmatch('**.rb', './main.rb')                  #=> false
  #         File.fnmatch('**.rb', 'lib/song.rb')                #=> true
  #         File.fnmatch('*',           'dave/.profile')                      #=> true
  #      
  #         pattern = '*' '/' '*'
  #         File.fnmatch(pattern, 'dave/.profile', File::FNM_PATHNAME)  #=> false
  #         File.fnmatch(pattern, 'dave/.profile', File::FNM_PATHNAME | File::FNM_DOTMATCH) #=> true
  #      
  #         pattern = '**' '/' 'foo'
  #         File.fnmatch(pattern, 'a/b/c/foo', File::FNM_PATHNAME)     #=> true
  #         File.fnmatch(pattern, '/a/b/c/foo', File::FNM_PATHNAME)    #=> true
  #         File.fnmatch(pattern, 'c:/a/b/c/foo', File::FNM_PATHNAME)  #=> true
  #         File.fnmatch(pattern, 'a/.b/c/foo', File::FNM_PATHNAME)    #=> false
  #         File.fnmatch(pattern, 'a/.b/c/foo', File::FNM_PATHNAME | File::FNM_DOTMATCH) #=> true
  # 
  def self.fnmatch(arg0, arg1, *rest)
  end

  # --------------------------------------------------- File::writable_real?
  #      File.writable_real?(file_name)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file is writable by the real user id of
  #      this process.
  # 
  def self.writable_real?(arg0)
  end

  # ------------------------------------------------------------ File::zero?
  #      File.zero?(file_name)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file exists and has a zero size.
  # 
  def self.zero?(arg0)
  end

  def self.chardev?(arg0)
  end

  # ------------------------------------------------------------ File::mtime
  #      File.mtime(file_name)  =>  time
  # ------------------------------------------------------------------------
  #      Returns the modification time for the named file as a Time object.
  # 
  #         File.mtime("testfile")   #=> Tue Apr 08 12:58:04 CDT 2003
  # 
  def self.mtime(arg0)
  end

  # ----------------------------------------------------------- File::rename
  #      File.rename(old_name, new_name)   => 0
  # ------------------------------------------------------------------------
  #      Renames the given file to the new name. Raises a +SystemCallError+
  #      if the file cannot be renamed.
  # 
  #         File.rename("afile", "afile.bak")   #=> 0
  # 
  def self.rename(arg0, arg1)
  end

  # ---------------------------------------------------------- File::exists?
  #      File.exist?(file_name)    =>  true or false
  #      File.exists?(file_name)   =>  true or false    (obsolete)
  # ------------------------------------------------------------------------
  #      Return +true+ if the named file exists.
  # 
  def self.exists?(arg0)
  end

  # ------------------------------------------------------------ File::pipe?
  #      File.pipe?(file_name)   =>  true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file is a pipe.
  # 
  def self.pipe?(arg0)
  end

  def self.stat(arg0)
  end

  # ------------------------------------------------------------- File::link
  #      File.link(old_name, new_name)    => 0
  # ------------------------------------------------------------------------
  #      Creates a new name for an existing file using a hard link. Will not
  #      overwrite _new_name_ if it already exists (raising a subclass of
  #      +SystemCallError+). Not available on all platforms.
  # 
  #         File.link("testfile", ".testfile")   #=> 0
  #         IO.readlines(".testfile")[0]         #=> "This is line one\n"
  # 
  def self.link(arg0, arg1)
  end

  # --------------------------------------------------------- File::truncate
  #      File.truncate(file_name, integer)  => 0
  # ------------------------------------------------------------------------
  #      Truncates the file _file_name_ to be at most _integer_ bytes long.
  #      Not available on all platforms.
  # 
  #         f = File.new("out", "w")
  #         f.write("1234567890")     #=> 10
  #         f.close                   #=> nil
  #         File.truncate("out", 5)   #=> 0
  #         File.size("out")          #=> 5
  # 
  def self.truncate(arg0, arg1)
  end

  # ------------------------------------------------------------ File::file?
  #      File.file?(file_name)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file exists and is a regular file.
  # 
  def self.file?(arg0)
  end

  # ---------------------------------------------------------- File::sticky?
  #      File.sticky?(file_name)   =>  true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file has the sticky bit set.
  # 
  def self.sticky?(arg0)
  end

  # ------------------------------------------------------------ File::chmod
  #      File::chmod(mode, *files)
  # ------------------------------------------------------------------------
  #      Changes permission bits on +files+ to the bit pattern represented
  #      by +mode+. If the last parameter isn't a String, verbose mode will
  #      be enabled.
  # 
  #        File.chmod 0755, 'somecommand'
  #        File.chmod 0644, 'my.rb', 'your.rb', true
  # 
  def self.chmod(arg0, arg1, *rest)
  end

  def self.basename(arg0, arg1, *rest)
  end

  # --------------------------------------------------------- File::fnmatch?
  #      File.fnmatch( pattern, path, [flags] ) => (true or false)
  #      File.fnmatch?( pattern, path, [flags] ) => (true or false)
  # ------------------------------------------------------------------------
  #      Returns true if _path_ matches against _pattern_ The pattern is not
  #      a regular expression; instead it follows rules similar to shell
  #      filename globbing. It may contain the following metacharacters:
  # 
  #      <code>*</code>:     Matches any file. Can be restricted by other
  #                          values in the glob. +*+ will match all files;
  #                          +c*+ will match all files beginning with +c+;
  #                          +*c+ will match all files ending with +c+; and
  #                          *+c+* will match all files that have +c+ in
  #                          them (including at the beginning or end).
  #                          Equivalent to +/ .* /x+ in regexp.
  # 
  #      <code>**</code>:    Matches directories recursively or files
  #                          expansively.
  # 
  #      <code>?</code>:     Matches any one character. Equivalent to
  #                          +/.{1}/+ in regexp.
  # 
  #      <code>[set]</code>: Matches any one character in +set+. Behaves
  #                          exactly like character sets in Regexp,
  #                          including set negation (+[^a-z]+).
  # 
  #      <code>\</code>:     Escapes the next metacharacter.
  # 
  #      _flags_ is a bitwise OR of the +FNM_xxx+ parameters. The same glob
  #      pattern and flags are used by +Dir::glob+.
  # 
  #         File.fnmatch('cat',       'cat')        #=> true  : match entire string
  #         File.fnmatch('cat',       'category')   #=> false : only match partial string
  #         File.fnmatch('c{at,ub}s', 'cats')       #=> false : { } isn't supported
  #      
  #         File.fnmatch('c?t',     'cat')          #=> true  : '?' match only 1 character
  #         File.fnmatch('c??t',    'cat')          #=> false : ditto
  #         File.fnmatch('c*',      'cats')         #=> true  : '*' match 0 or more characters
  #         File.fnmatch('c*t',     'c/a/b/t')      #=> true  : ditto
  #         File.fnmatch('ca[a-z]', 'cat')          #=> true  : inclusive bracket expression
  #         File.fnmatch('ca[^t]',  'cat')          #=> false : exclusive bracket expression ('^' or '!')
  #      
  #         File.fnmatch('cat', 'CAT')                     #=> false : case sensitive
  #         File.fnmatch('cat', 'CAT', File::FNM_CASEFOLD) #=> true  : case insensitive
  #      
  #         File.fnmatch('?',   '/', File::FNM_PATHNAME)  #=> false : wildcard doesn't match '/' on FNM_PATHNAME
  #         File.fnmatch('*',   '/', File::FNM_PATHNAME)  #=> false : ditto
  #         File.fnmatch('[/]', '/', File::FNM_PATHNAME)  #=> false : ditto
  #      
  #         File.fnmatch('\?',   '?')                       #=> true  : escaped wildcard becomes ordinary
  #         File.fnmatch('\a',   'a')                       #=> true  : escaped ordinary remains ordinary
  #         File.fnmatch('\a',   '\a', File::FNM_NOESCAPE)  #=> true  : FNM_NOESACPE makes '\' ordinary
  #         File.fnmatch('[\?]', '?')                       #=> true  : can escape inside bracket expression
  #      
  #         File.fnmatch('*',   '.profile')                      #=> false : wildcard doesn't match leading
  #         File.fnmatch('*',   '.profile', File::FNM_DOTMATCH)  #=> true    period by default.
  #         File.fnmatch('.*',  '.profile')                      #=> true
  #      
  #         rbfiles = '**' '/' '*.rb' # you don't have to do like this. just write in single string.
  #         File.fnmatch(rbfiles, 'main.rb')                    #=> false
  #         File.fnmatch(rbfiles, './main.rb')                  #=> false
  #         File.fnmatch(rbfiles, 'lib/song.rb')                #=> true
  #         File.fnmatch('**.rb', 'main.rb')                    #=> true
  #         File.fnmatch('**.rb', './main.rb')                  #=> false
  #         File.fnmatch('**.rb', 'lib/song.rb')                #=> true
  #         File.fnmatch('*',           'dave/.profile')                      #=> true
  #      
  #         pattern = '*' '/' '*'
  #         File.fnmatch(pattern, 'dave/.profile', File::FNM_PATHNAME)  #=> false
  #         File.fnmatch(pattern, 'dave/.profile', File::FNM_PATHNAME | File::FNM_DOTMATCH) #=> true
  #      
  #         pattern = '**' '/' 'foo'
  #         File.fnmatch(pattern, 'a/b/c/foo', File::FNM_PATHNAME)     #=> true
  #         File.fnmatch(pattern, '/a/b/c/foo', File::FNM_PATHNAME)    #=> true
  #         File.fnmatch(pattern, 'c:/a/b/c/foo', File::FNM_PATHNAME)  #=> true
  #         File.fnmatch(pattern, 'a/.b/c/foo', File::FNM_PATHNAME)    #=> false
  #         File.fnmatch(pattern, 'a/.b/c/foo', File::FNM_PATHNAME | File::FNM_DOTMATCH) #=> true
  # 
  def self.fnmatch?(arg0, arg1, *rest)
  end

  # -------------------------------------------------------- File::writable?
  #      File.writable?(file_name)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file is writable by the effective user
  #      id of this process.
  # 
  def self.writable?(arg0)
  end

  def self.blockdev?(arg0)
  end

  # ------------------------------------------------------------ File::atime
  #      File.atime(file_name)  =>  time
  # ------------------------------------------------------------------------
  #      Returns the last access time for the named file as a Time object).
  # 
  #         File.atime("testfile")   #=> Wed Apr 09 08:51:48 CDT 2003
  # 
  def self.atime(arg0)
  end

  # ----------------------------------------------------------- File::unlink
  #      File.delete(file_name, ...)  => integer
  #      File.unlink(file_name, ...)  => integer
  # ------------------------------------------------------------------------
  #      Deletes the named files, returning the number of names passed as
  #      arguments. Raises an exception on any error. See also +Dir::rmdir+.
  # 
  def self.unlink(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- File::exist?
  #      File.exist?(file_name)    =>  true or false
  #      File.exists?(file_name)   =>  true or false    (obsolete)
  # ------------------------------------------------------------------------
  #      Return +true+ if the named file exists.
  # 
  def self.exist?(arg0)
  end

  # -------------------------------------------------------- File::grpowned?
  #      File.grpowned?(file_name)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file exists and the effective group id
  #      of the calling process is the owner of the file. Returns +false+ on
  #      Windows.
  # 
  def self.grpowned?(arg0)
  end

  # ----------------------------------------------------------- File::lchown
  #      file.lchown(owner_int, group_int, file_name,..) => integer
  # ------------------------------------------------------------------------
  #      Equivalent to +File::chown+, but does not follow symbolic links (so
  #      it will change the owner associated with the link, not the file
  #      referenced by the link). Often not available. Returns number of
  #      files in the argument list.
  # 
  def self.lchown(arg0, arg1, *rest)
  end

  # ------------------------------------------------- File::executable_real?
  #      File.executable_real?(file_name)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file is executable by the real user id
  #      of this process.
  # 
  def self.executable_real?(arg0)
  end

  # ---------------------------------------------------------- File::setgid?
  #      File.setgid?(file_name)   =>  true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file has the setgid bit set.
  # 
  def self.setgid?(arg0)
  end

  # ------------------------------------------------------------ File::utime
  #      File.utime(atime, mtime, file_name,...)   =>  integer
  # ------------------------------------------------------------------------
  #      Sets the access and modification times of each named file to the
  #      first two arguments. Returns the number of file names in the
  #      argument list.
  # 
  def self.utime(arg0, arg1, *rest)
  end

  # ------------------------------------------------------ File::expand_path
  #      File.expand_path(file_name [, dir_string] ) -> abs_file_name
  # ------------------------------------------------------------------------
  #      Converts a pathname to an absolute pathname. Relative paths are
  #      referenced from the current working directory of the process unless
  #      _dir_string_ is given, in which case it will be used as the
  #      starting point. The given pathname may start with a ``+~+'', which
  #      expands to the process owner's home directory (the environment
  #      variable +HOME+ must be set correctly). ``+~+_user_'' expands to
  #      the named user's home directory.
  # 
  #         File.expand_path("~oracle/bin")           #=> "/home/oracle/bin"
  #         File.expand_path("../../bin", "/tmp/x")   #=> "/bin"
  # 
  def self.expand_path(arg0, arg1, *rest)
  end

  # --------------------------------------------------- File::readable_real?
  #      File.readable_real?(file_name)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file is readable by the real user id of
  #      this process.
  # 
  def self.readable_real?(arg0)
  end

  # ---------------------------------------------------------- File::socket?
  #      File.socket?(file_name)   =>  true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file is a socket.
  # 
  def self.socket?(arg0)
  end

  # ------------------------------------------------------------ File::ftype
  #      File.ftype(file_name)   => string
  # ------------------------------------------------------------------------
  #      Identifies the type of the named file; the return string is one of
  #      ``+file+'', ``+directory+'', ``+characterSpecial+'',
  #      ``+blockSpecial+'', ``+fifo+'', ``+link+'', ``+socket+'', or
  #      ``+unknown+''.
  # 
  #         File.ftype("testfile")            #=> "file"
  #         File.ftype("/dev/tty")            #=> "characterSpecial"
  #         File.ftype("/tmp/.X11-unix/X0")   #=> "socket"
  # 
  def self.ftype(arg0)
  end

  # --------------------------------------------------------- File::readlink
  #      File.readlink(link_name) -> file_name
  # ------------------------------------------------------------------------
  #      Returns the name of the file referenced by the given link. Not
  #      available on all platforms.
  # 
  #         File.symlink("testfile", "link2test")   #=> 0
  #         File.readlink("link2test")              #=> "testfile"
  # 
  def self.readlink(arg0)
  end

  # ----------------------------------------------------------- File::delete
  #      File.delete(file_name, ...)  => integer
  #      File.unlink(file_name, ...)  => integer
  # ------------------------------------------------------------------------
  #      Deletes the named files, returning the number of names passed as
  #      arguments. Raises an exception on any error. See also +Dir::rmdir+.
  # 
  def self.delete(arg0, arg1, *rest)
  end

  # ------------------------------------------------------- File::directory?
  #      File.directory?(file_name)   =>  true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file is a directory, +false+ otherwise.
  # 
  #         File.directory?(".")
  # 
  def self.directory?(arg0)
  end

  # ----------------------------------------------------------- File::owned?
  #      File.owned?(file_name)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named file exists and the effective used id
  #      of the calling process is the owner of the file.
  # 
  def self.owned?(arg0)
  end

  # ----------------------------------------------------------- File::lchmod
  #      File.lchmod(mode_int, file_name, ...)  => integer
  # ------------------------------------------------------------------------
  #      Equivalent to +File::chmod+, but does not follow symbolic links (so
  #      it will change the permissions associated with the link, not the
  #      file referenced by the link). Often not available.
  # 
  def self.lchmod(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- File::extname
  #      File.extname(path) -> string
  # ------------------------------------------------------------------------
  #      Returns the extension (the portion of file name in _path_ after the
  #      period).
  # 
  #         File.extname("test.rb")         #=> ".rb"
  #         File.extname("a/b/d/test.rb")   #=> ".rb"
  #         File.extname("test")            #=> ""
  #         File.extname(".profile")        #=> ""
  # 
  def self.extname(arg0)
  end

  def self.split(arg0)
  end

  # ------------------------------------------------------------- File#ctime
  #      file.ctime -> time
  # ------------------------------------------------------------------------
  #      Returns the change time for _file_ (that is, the time directory
  #      information about the file was changed, not the file itself).
  # 
  #         File.new("testfile").ctime   #=> Wed Apr 09 08:53:14 CDT 2003
  # 
  def ctime
  end

  # ------------------------------------------------------------- File#lstat
  #      file.lstat   =>  stat
  # ------------------------------------------------------------------------
  #      Same as +IO#stat+, but does not follow the last symbolic link.
  #      Instead, reports on the link itself.
  # 
  #         File.symlink("testfile", "link2test")   #=> 0
  #         File.stat("testfile").size              #=> 66
  #         f = File.new("link2test")
  #         f.lstat.size                            #=> 8
  #         f.stat.size                             #=> 66
  # 
  def lstat
  end

  # ------------------------------------------------------------- File#chown
  #      file.chown(owner_int, group_int )   => 0
  # ------------------------------------------------------------------------
  #      Changes the owner and group of _file_ to the given numeric owner
  #      and group id's. Only a process with superuser privileges may change
  #      the owner of a file. The current owner of a file may change the
  #      file's group to any group to which the owner belongs. A +nil+ or -1
  #      owner or group id is ignored. Follows symbolic links. See also
  #      +File#lchown+.
  # 
  #         File.new("testfile").chown(502, 1000)
  # 
  def chown
  end

  # ------------------------------------------------------------- File#mtime
  #      file.mtime -> time
  # ------------------------------------------------------------------------
  #      Returns the modification time for _file_.
  # 
  #         File.new("testfile").mtime   #=> Wed Apr 09 08:53:14 CDT 2003
  # 
  def mtime
  end

  # -------------------------------------------------------------- File#path
  #      file.path -> filename
  # ------------------------------------------------------------------------
  #      Returns the pathname used to create _file_ as a string. Does not
  #      normalize the name.
  # 
  #         File.new("testfile").path               #=> "testfile"
  #         File.new("/tmp/../tmp/xxx", "w").path   #=> "/tmp/../tmp/xxx"
  # 
  def path
  end

  # ---------------------------------------------------------- File#truncate
  #      file.truncate(integer)    => 0
  # ------------------------------------------------------------------------
  #      Truncates _file_ to at most _integer_ bytes. The file must be
  #      opened for writing. Not available on all platforms.
  # 
  #         f = File.new("out", "w")
  #         f.syswrite("1234567890")   #=> 10
  #         f.truncate(5)              #=> 0
  #         f.close()                  #=> nil
  #         File.size("out")           #=> 5
  # 
  def truncate
  end

  # ------------------------------------------------------------- File#chmod
  #      file.chmod(mode_int)   => 0
  # ------------------------------------------------------------------------
  #      Changes permission bits on _file_ to the bit pattern represented by
  #      _mode_int_. Actual effects are platform dependent; on Unix systems,
  #      see +chmod(2)+ for details. Follows symbolic links. Also see
  #      +File#lchmod+.
  # 
  #         f = File.new("out", "w");
  #         f.chmod(0644)   #=> 0
  # 
  # 
  #      (also known as o_chmod)
  def chmod
  end

  # ------------------------------------------------------------- File#atime
  #      file.atime    => time
  # ------------------------------------------------------------------------
  #      Returns the last access time (a +Time+ object)
  # 
  #       for <em>file</em>, or epoch if <em>file</em> has not been accessed.
  #      
  #         File.new("testfile").atime   #=> Wed Dec 31 18:00:00 CST 1969
  # 
  def atime
  end

  # ------------------------------------------------------------- File#flock
  #      file.flock (locking_constant ) =>  0 or false
  # ------------------------------------------------------------------------
  #      Locks or unlocks a file according to _locking_constant_ (a logical
  #      _or_ of the values in the table below). Returns +false+ if
  #      +File::LOCK_NB+ is specified and the operation would otherwise have
  #      blocked. Not available on all platforms.
  # 
  #      Locking constants (in class File):
  # 
  #         LOCK_EX   | Exclusive lock. Only one process may hold an
  #                   | exclusive lock for a given file at a time.
  #         ----------+------------------------------------------------
  #         LOCK_NB   | Don't block when locking. May be combined
  #                   | with other lock options using logical or.
  #         ----------+------------------------------------------------
  #         LOCK_SH   | Shared lock. Multiple processes may each hold a
  #                   | shared lock for a given file at the same time.
  #         ----------+------------------------------------------------
  #         LOCK_UN   | Unlock.
  # 
  #      Example:
  # 
  #         File.new("testfile").flock(File::LOCK_UN)   #=> 0
  # 
  def flock
  end

end
