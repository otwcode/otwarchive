=begin
------------------------------------------------------ Class: GetoptLong
     The GetoptLong class allows you to parse command line options
     similarly to the GNU getopt_long() C library call. Note, however,
     that GetoptLong is a pure Ruby implementation.

     GetoptLong allows for POSIX-style options like +--file+ as well as
     single letter options like +-f+

     The empty option +--+ (two minus symbols) is used to end option
     processing. This can be particularly important if options have
     optional arguments.

     Here is a simple example of usage:

         # == Synopsis
         #
         # hello: greets user, demonstrates command line parsing
         #
         # == Usage
         #
         # hello [OPTION] ... DIR
         #
         # -h, --help:
         #    show help
         #
         # --repeat x, -n x:
         #    repeat x times
         #
         # --name [name]:
         #    greet user by name, if name not supplied default is John
         #
         # DIR: The directory in which to issue the greeting.
     
         require 'getoptlong'
         require 'rdoc/usage'
     
         opts = GetoptLong.new(
           [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
           [ '--repeat', '-n', GetoptLong::REQUIRED_ARGUMENT ],
           [ '--name', GetoptLong::OPTIONAL_ARGUMENT ]
         )
     
         dir = nil
         name = nil
         repetitions = 1
         opts.each do |opt, arg|
           case opt
             when '--help'
               RDoc::usage
             when '--repeat'
               repetitions = arg.to_i
             when '--name'
               if arg == ''
                 name = 'John'
               else
                 name = arg
               end
           end
         end
     
         if ARGV.length != 1
           puts "Missing dir argument (try --help)"
           exit 0
         end
     
         dir = ARGV.shift
     
         Dir.chdir(dir)
         for i in (1..repetitions)
           print "Hello"
           if name
             print ", #{name}"
           end
           puts
         end

     Example command line:

         hello -n 6 --name -- /tmp

------------------------------------------------------------------------


Constants:
----------
     ORDERINGS:         [REQUIRE_ORDER = 0, PERMUTE = 1, RETURN_IN_ORDER
                        = 2]
     ARGUMENT_FLAGS:    [NO_ARGUMENT = 0, REQUIRED_ARGUMENT = 1,    
                        OPTIONAL_ARGUMENT = 2]
     STATUS_TERMINATED: 0, 1, 2


Class methods:
--------------
     new


Instance methods:
-----------------
     each, each_option, error_message, get, get_option, ordering=,
     set_error, set_options, terminate, terminated?

Attributes:
     error, ordering, quiet, quiet

=end
class GetoptLong < Object

  # ----------------------------------------------- GetoptLong#error_message
  #      error_message()
  # ------------------------------------------------------------------------
  #      Return the appropriate error message in POSIX-defined format. If no
  #      error has occurred, returns nil.
  # 
  def error_message
  end

  # --------------------------------------------------------- GetoptLong#get
  #      get()
  # ------------------------------------------------------------------------
  #      Get next option name and its argument, as an Array of two elements.
  # 
  #      The option name is always converted to the first (preferred) name
  #      given in the original options to GetoptLong.new.
  # 
  #      Example: ['--option', 'value']
  # 
  #      Returns nil if the processing is complete (as determined by
  #      STATUS_TERMINATED).
  # 
  # 
  #      (also known as get_option)
  def get
  end

  # ------------------------------------------------- GetoptLong#terminated?
  #      terminated?()
  # ------------------------------------------------------------------------
  #      Returns true if option processing has terminated, false otherwise.
  # 
  def terminated?
  end

  # --------------------------------------------------- GetoptLong#ordering=
  #      ordering=(ordering)
  # ------------------------------------------------------------------------
  #      Set the handling of the ordering of options and arguments. A
  #      RuntimeError is raised if option processing has already started.
  # 
  #      The supplied value must be a member of GetoptLong::ORDERINGS. It
  #      alters the processing of options as follows:
  # 
  #      *REQUIRE_ORDER* :
  # 
  #      Options are required to occur before non-options.
  # 
  #      Processing of options ends as soon as a word is encountered that
  #      has not been preceded by an appropriate option flag.
  # 
  #      For example, if -a and -b are options which do not take arguments,
  #      parsing command line arguments of '-a one -b two' would result in
  #      'one', '-b', 'two' being left in ARGV, and only ('-a', '') being
  #      processed as an option/arg pair.
  # 
  #      This is the default ordering, if the environment variable
  #      POSIXLY_CORRECT is set. (This is for compatibility with GNU
  #      getopt_long.)
  # 
  #      *PERMUTE* :
  # 
  #      Options can occur anywhere in the command line parsed. This is the
  #      default behavior.
  # 
  #      Every sequence of words which can be interpreted as an option (with
  #      or without argument) is treated as an option; non-option words are
  #      skipped.
  # 
  #      For example, if -a does not require an argument and -b optionally
  #      takes an argument, parsing '-a one -b two three' would result in
  #      ('-a','') and ('-b', 'two') being processed as option/arg pairs,
  #      and 'one','three' being left in ARGV.
  # 
  #      If the ordering is set to PERMUTE but the environment variable
  #      POSIXLY_CORRECT is set, REQUIRE_ORDER is used instead. This is for
  #      compatibility with GNU getopt_long.
  # 
  #      *RETURN_IN_ORDER* :
  # 
  #      All words on the command line are processed as options. Words not
  #      preceded by a short or long option flag are passed as arguments
  #      with an option of '' (empty string).
  # 
  #      For example, if -a requires an argument but -b does not, a command
  #      line of '-a one -b two three' would result in option/arg pairs of
  #      ('-a', 'one') ('-b', ''), ('', 'two'), ('', 'three') being
  #      processed.
  # 
  def ordering
  end

  # -------------------------------------------------------- GetoptLong#each
  #      each() {|option_name, option_argument| ...}
  # ------------------------------------------------------------------------
  #      Iterator version of `get'.
  # 
  #      The block is called repeatedly with two arguments: The first is the
  #      option name. The second is the argument which followed it (if any).
  #      Example: ('--opt', 'value')
  # 
  #      The option name is always converted to the first (preferred) name
  #      given in the original options to GetoptLong.new.
  # 
  # 
  #      (also known as each_option)
  def each
  end

  # --------------------------------------------------- GetoptLong#ordering=
  #      ordering=(ordering)
  # ------------------------------------------------------------------------
  #      Set the handling of the ordering of options and arguments. A
  #      RuntimeError is raised if option processing has already started.
  # 
  #      The supplied value must be a member of GetoptLong::ORDERINGS. It
  #      alters the processing of options as follows:
  # 
  #      *REQUIRE_ORDER* :
  # 
  #      Options are required to occur before non-options.
  # 
  #      Processing of options ends as soon as a word is encountered that
  #      has not been preceded by an appropriate option flag.
  # 
  #      For example, if -a and -b are options which do not take arguments,
  #      parsing command line arguments of '-a one -b two' would result in
  #      'one', '-b', 'two' being left in ARGV, and only ('-a', '') being
  #      processed as an option/arg pair.
  # 
  #      This is the default ordering, if the environment variable
  #      POSIXLY_CORRECT is set. (This is for compatibility with GNU
  #      getopt_long.)
  # 
  #      *PERMUTE* :
  # 
  #      Options can occur anywhere in the command line parsed. This is the
  #      default behavior.
  # 
  #      Every sequence of words which can be interpreted as an option (with
  #      or without argument) is treated as an option; non-option words are
  #      skipped.
  # 
  #      For example, if -a does not require an argument and -b optionally
  #      takes an argument, parsing '-a one -b two three' would result in
  #      ('-a','') and ('-b', 'two') being processed as option/arg pairs,
  #      and 'one','three' being left in ARGV.
  # 
  #      If the ordering is set to PERMUTE but the environment variable
  #      POSIXLY_CORRECT is set, REQUIRE_ORDER is used instead. This is for
  #      compatibility with GNU getopt_long.
  # 
  #      *RETURN_IN_ORDER* :
  # 
  #      All words on the command line are processed as options. Words not
  #      preceded by a short or long option flag are passed as arguments
  #      with an option of '' (empty string).
  # 
  #      For example, if -a requires an argument but -b does not, a command
  #      line of '-a one -b two three' would result in option/arg pairs of
  #      ('-a', 'one') ('-b', ''), ('', 'two'), ('', 'three') being
  #      processed.
  # 
  def ordering=(arg0)
  end

  # ------------------------------------------------- GetoptLong#set_options
  #      set_options(*arguments)
  # ------------------------------------------------------------------------
  #      Set options. Takes the same argument as GetoptLong.new.
  # 
  #      Raises a RuntimeError if option processing has already started.
  # 
  def set_options(arg0, arg1, *rest)
  end

  # --------------------------------------------------- GetoptLong#terminate
  #      terminate()
  # ------------------------------------------------------------------------
  #      Explicitly terminate option processing.
  # 
  def terminate
  end

  def quiet
  end

  def error
  end

  def quiet?
  end

  # ------------------------------------------------- GetoptLong#each_option
  #      each_option()
  # ------------------------------------------------------------------------
  #      Alias for #each
  # 
  def each_option
  end

  def quiet=(arg0)
  end

  def error?
  end

  # --------------------------------------------------- GetoptLong#set_error
  #      set_error(type, message)
  # ------------------------------------------------------------------------
  #      Set an error (protected).
  # 
  def set_error(arg0, arg1)
  end

  # -------------------------------------------------- GetoptLong#get_option
  #      get_option()
  # ------------------------------------------------------------------------
  #      Alias for #get
  # 
  def get_option
  end

end
