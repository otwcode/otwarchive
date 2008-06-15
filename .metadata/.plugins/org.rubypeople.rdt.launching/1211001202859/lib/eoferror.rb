=begin
---------------------------------------------- Class: EOFError < IOError
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

=end
class EOFError < IOError

end
