=begin
---------------------------------------------------------- Class: Kernel
     +Object+ is the parent class of all classes in Ruby. Its methods
     are therefore available to all objects unless explicitly
     overridden.

     +Object+ mixes in the +Kernel+ module, making the built-in kernel
     functions globally accessible. Although the instance methods of
     +Object+ are defined by the +Kernel+ module, we have chosen to
     document them here for clarity.

     In the descriptions of Object's methods, the parameter _symbol_
     refers to a symbol, which is either a quoted string or a +Symbol+
     (such as +:name+).

------------------------------------------------------------------------
     Since Ruby is very dynamic, methods added to the ancestors of
     BlankSlate _after BlankSlate is defined_ will show up in the list
     of available BlankSlate methods. We handle this by defining a hook
     in the Object and Kernel classes that will hide any method defined
     after BlankSlate has been loaded.

------------------------------------------------------------------------
     Since Ruby is very dynamic, methods added to the ancestors of
     BlankSlate _after BlankSlate is defined_ will show up in the list
     of available BlankSlate methods. We handle this by defining a hook
     in the Object and Kernel classes that will hide any defined

------------------------------------------------------------------------
     Create a global fork method

------------------------------------------------------------------------


Class methods:
--------------
     method_added


Instance methods:
-----------------
     Array, Float, Integer, Pathname, String, URI, `, abort, at_exit,
     autoload, autoload?, binding, binding_n, block_given?, breakpoint,
     callcc, caller, catch, chomp, chomp!, chop, chop!, daemonize,
     debugger, enable_warnings, eval, exec, exit, exit!, fail, fork,
     format, gem, getc, gets, global_variables, gsub, gsub!, iterator?,
     lambda, load, local_variables, log_open_files, loop,
     method_missing, open, open_uri_original_open, p, pp,
     pretty_inspect, print, printf, proc, putc, puts, raise, rand,
     readline, readlines, require, require_gem, require_library_or_gem,
     scan, scanf, select, set_trace_func, silence_stream,
     silence_warnings, sleep, split, sprintf, srand, sub, sub!,
     suppress, syscall, system, test, throw, to_ptr, trace_var, trap,
     untrace_var, warn, y

=end
module Kernel

  def self.format(arg0, arg1, *rest)
  end

  def self.exit(arg0, arg1, *rest)
  end

  def self.chomp!(arg0, arg1, *rest)
  end

  def self.putc(arg0)
  end

  def self.rand(arg0, arg1, *rest)
  end

  def self.Integer(arg0)
  end

  def self.untrace_var(arg0, arg1, *rest)
  end

  def self.syscall(arg0, arg1, *rest)
  end

  def self.eval(arg0, arg1, *rest)
  end

  def self.block_given?
  end

  def self.catch(arg0)
  end

  def self.sub(arg0, arg1, *rest)
  end

  def self.readline(arg0, arg1, *rest)
  end

  def self.exit!(arg0, arg1, *rest)
  end

  def self.autoload(arg0, arg1)
  end

  def self.binding
  end

  def self.sprintf(arg0, arg1, *rest)
  end

  def self.Array(arg0)
  end

  def self.caller(arg0, arg1, *rest)
  end

  def self.chop!
  end

  def self.scan(arg0)
  end

  def self.print(arg0, arg1, *rest)
  end

  def self.srand(arg0, arg1, *rest)
  end

  def self.sleep(arg0, arg1, *rest)
  end

  def self.loop
  end

  def self.local_variables
  end

  def self.trace_var(arg0, arg1, *rest)
  end

  def self.chomp(arg0, arg1, *rest)
  end

  def self.callcc
  end

  def self.getc
  end

  def self.iterator?
  end

  def self.at_exit
  end

  def self.gets(arg0, arg1, *rest)
  end

  def self.trap(arg0, arg1, *rest)
  end

  def self.fork
  end

  def self.require(arg0)
  end

  def self.autoload?(arg0)
  end

  def self.String(arg0)
  end

  def self.method_missing(arg0, arg1, *rest)
  end

  def self.fail(arg0, arg1, *rest)
  end

  def self.gsub!(arg0, arg1, *rest)
  end

  def self.warn(arg0)
  end

  def self.printf(arg0, arg1, *rest)
  end

  def self.system(arg0, arg1, *rest)
  end

  def self.URI(arg0)
  end

  def self.global_variables
  end

  def self.chop
  end

  def self.p(arg0, arg1, *rest)
  end

  def self.lambda
  end

  def self.abort(arg0, arg1, *rest)
  end

  def self.puts(arg0, arg1, *rest)
  end

  def self.select(arg0, arg1, *rest)
  end

  def self.`(arg0)
  end

  def self.load(arg0, arg1, *rest)
  end

  def self.Float(arg0)
  end

  def self.raise(arg0, arg1, *rest)
  end

  def self.set_trace_func(arg0)
  end

  def self.sub!(arg0, arg1, *rest)
  end

  def self.open(arg0, arg1, *rest)
  end

  def self.exec(arg0, arg1, *rest)
  end

  def self.throw(arg0, arg1, *rest)
  end

  def self.gsub(arg0, arg1, *rest)
  end

  def self.split(arg0, arg1, *rest)
  end

  def self.readlines(arg0, arg1, *rest)
  end

  def self.test(arg0, arg1, *rest)
  end

  def self.proc
  end

  # -------------------------------------------------- Kernel#pretty_inspect
  #      pretty_inspect()
  # ------------------------------------------------------------------------
  #      returns a pretty printed object as a string.
  # 
  def inspect
  end

  def clone
  end

  def public_methods(arg0, arg1, *rest)
  end

  def display(arg0, arg1, *rest)
  end

  def instance_variable_defined?(arg0)
  end

  def equal?(arg0)
  end

  def freeze
  end

  def methods(arg0, arg1, *rest)
  end

  def respond_to?(arg0, arg1, *rest)
  end

  def dup
  end

  def instance_variables
  end

  def __id__
  end

  # -------------------------------------------------- Kernel#method_missing
  #      obj.method_missing(symbol [, *args] )   => result
  # ------------------------------------------------------------------------
  #      Invoked by Ruby when _obj_ is sent a message it cannot handle.
  #      _symbol_ is the symbol for the method called, and _args_ are any
  #      arguments that were passed to it. By default, the interpreter
  #      raises an error when this method is called. However, it is possible
  #      to override the method to provide more dynamic behavior. The
  #      example below creates a class +Roman+, which responds to methods
  #      with names consisting of roman numerals, returning the
  #      corresponding integer values.
  # 
  #         class Roman
  #           def romanToInt(str)
  #             # ...
  #           end
  #           def method_missing(methId)
  #             str = methId.id2name
  #             romanToInt(str)
  #           end
  #         end
  #      
  #         r = Roman.new
  #         r.iv      #=> 4
  #         r.xxiii   #=> 23
  #         r.mm      #=> 2000
  # 
  def method(arg0)
  end

  def eql?(arg0)
  end

  def id
  end

  def singleton_methods(arg0, arg1, *rest)
  end

  def send(arg0, arg1, *rest)
  end

  def taint
  end

  def frozen?
  end

  def instance_variable_get(arg0)
  end

  def __send__(arg0, arg1, *rest)
  end

  def instance_of?(arg0)
  end

  def to_a
  end

  def type
  end

  def protected_methods(arg0, arg1, *rest)
  end

  def instance_eval(arg0, arg1, *rest)
  end

  def object_id
  end

  # ----------------------------------------------------- Kernel#require_gem
  #      require_gem(gem_name, *version_requirements)
  # ------------------------------------------------------------------------
  #      Same as the +gem+ command, but will also require a file if the gem
  #      provides an auto-required file name.
  # 
  #      DEPRECATED! Use +gem+ instead.
  # 
  def require_gem(arg0, arg1, arg2, *rest)
  end

  def ==(arg0)
  end

  # --------------------------------------------------------- Kernel#require
  #      require(string)    => true or false
  # ------------------------------------------------------------------------
  #      Ruby tries to load the library named _string_, returning +true+ if
  #      successful. If the filename does not resolve to an absolute path,
  #      it will be searched for in the directories listed in +$:+. If the
  #      file has the extension ``.rb'', it is loaded as a source file; if
  #      the extension is ``.so'', ``.o'', or ``.dll'', or whatever the
  #      default shared library extension is on the current platform, Ruby
  #      loads the shared library as a Ruby extension. Otherwise, Ruby tries
  #      adding ``.rb'', ``.so'', and so on to the name. The name of the
  #      loaded feature is added to the array in +$"+. A feature will not be
  #      loaded if it's name already appears in +$"+. However, the file name
  #      is not converted to an absolute path, so that ``+require
  #      'a';require './a'+'' will load +a.rb+ twice.
  # 
  #         require "my-library.rb"
  #         require "db-driver"
  # 
  def require(arg0)
  end

  def ===(arg0)
  end

  def instance_variable_set(arg0, arg1)
  end

  def kind_of?(arg0)
  end

  def extend(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------- Kernel#gem
  #      gem(gem_name, *version_requirements)
  # ------------------------------------------------------------------------
  #      Adds a Ruby Gem to the $LOAD_PATH. Before a Gem is loaded, its
  #      required Gems are loaded. If the version information is omitted,
  #      the highest version Gem of the supplied name is loaded. If a Gem is
  #      not found that meets the version requirement and/or a required Gem
  #      is not found, a Gem::LoadError is raised. More information on
  #      version requirements can be found in the Gem::Version
  #      documentation.
  # 
  #      The +gem+ directive should be executed *before* any require
  #      statements (otherwise rubygems might select a conflicting library
  #      version).
  # 
  #      You can define the environment variable GEM_SKIP as a way to not
  #      load specified gems. you might do this to test out changes that
  #      haven't been intsalled yet. Example:
  # 
  #        GEM_SKIP=libA:libB ruby-I../libA -I../libB ./mycode.rb
  # 
  #      gem:                 [String or Gem::Dependency] The gem name or
  #                           dependency instance.
  # 
  #      version_requirement: [default=">= 0.0.0"] The version requirement.
  # 
  #      return:              [Boolean] true if the Gem is loaded, otherwise
  #                           false.
  # 
  #      raises:              [Gem::LoadError] if Gem cannot be found, is
  #                           listed in GEM_SKIP, or version requirement not
  #                           met.
  # 
  def gem(arg0, arg1, arg2, *rest)
  end

  def to_s
  end

  def hash
  end

  def class
  end

  def tainted?
  end

  def =~(arg0)
  end

  def private_methods(arg0, arg1, *rest)
  end

  def nil?
  end

  def untaint
  end

  def is_a?(arg0)
  end

end
