=begin
---------------------------------------------------------- Class: Object
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
     Check first to see if we are in a Rails environment, no need to
     define these methods if we are

------------------------------------------------------------------------
     Same as above, except in Object.

------------------------------------------------------------------------


Includes:
---------
     InstanceExecMethods, Kernel(Array, Float, Integer, Pathname,
     String, URI, `, abort, at_exit, autoload, autoload?, binding,
     binding_n, block_given?, breakpoint, callcc, caller, catch, chomp,
     chomp!, chop, chop!, daemonize, debugger, enable_warnings, eval,
     exec, exit, exit!, fail, fork, format, gem, getc, gets,
     global_variables, gsub, gsub!, iterator?, lambda, load,
     local_variables, log_open_files, loop, method_missing, open,
     open_uri_original_open, p, pp, pretty_inspect, print, printf, proc,
     putc, puts, raise, rand, readline, readlines, require, require_gem,
     require_library_or_gem, scan, scanf, select, set_trace_func,
     silence_stream, silence_warnings, sleep, split, sprintf, srand,
     sub, sub!, suppress, syscall, system, test, throw, to_ptr,
     trace_var, trap, untrace_var, warn, y),
     PP::ObjectMixin(pretty_print, pretty_print_cycle,
     pretty_print_inspect, pretty_print_instance_variables)


Constants:
----------
     ARGF:              argf
     ARGV:              rb_argv
     DATA:              f
     ENV:               envtbl
     FALSE:             Qfalse
     IPsocket:          rb_cIPSocket
     MatchingData:      rb_cMatch
     NIL:               Qnil
     PLATFORM:          p
     RELEASE_DATE:      d
     RUBY_PATCHLEVEL:   INT2FIX(RUBY_PATCHLEVEL)
     RUBY_PLATFORM:     p
     RUBY_RELEASE_DATE: d
     RUBY_VERSION:      v
     SOCKSsocket:       rb_cSOCKSSocket
     STDERR:            rb_stderr
     STDIN:             rb_stdin
     STDOUT:            rb_stdout
     TCPserver:         rb_cTCPServer
     TCPsocket:         rb_cTCPSocket
     TOPLEVEL_BINDING:  rb_f_binding(ruby_top_self)
     TRUE:              Qtrue
     UDPsocket:         rb_cUDPSocket
     UNIXserver:        rb_cUNIXServer
     UNIXsocket:        rb_cUNIXSocket
     VERSION:           v


Class methods:
--------------
     find_hidden_method, method_added, new


Instance methods:
-----------------
     ==, ===, =~, __id__, __send__, acts_like?, blank?, class, clone,
     dclone, display, dup, duplicable?, enum_for, eql?, equal?, extend,
     freeze, frozen?, hash, id, inspect, instance_eval, instance_exec,
     instance_of?, instance_variable_defined?, instance_variable_get,
     instance_variable_set, instance_variables, is_a?, kind_of?, method,
     methods, nil?, object_id, private_methods, protected_methods,
     public_methods, remove_instance_variable, respond_to?, returning,
     send, singleton_method_added, singleton_method_removed,
     singleton_method_undefined, singleton_methods, taint, tainted?,
     to_a, to_enum, to_json, to_param, to_query, to_s, to_yaml,
     to_yaml_properties, to_yaml_style, type, unloadable, untaint,
     with_options

=end
class Object
  include Kernel

  def self.yaml_tag_subclasses?
  end

  def taguri=(arg0)
  end

  # ---------------------------------------------- Object#to_yaml_properties
  #      to_yaml_properties()
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml_properties
  end

  # --------------------------------------------------- Object#to_yaml_style
  #      to_yaml_style()
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml_style
  end

  def taguri
  end

  # --------------------------------------------------------- Object#to_yaml
  #      to_yaml( opts = {} )
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml(arg0, arg1, *rest)
  end

end
