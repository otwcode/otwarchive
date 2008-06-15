=begin
---------------------------------------------------------- Class: Module
     A +Module+ is a collection of methods and constants. The methods in
     a module may be instance methods or module methods. Instance
     methods appear as methods in a class when the module is included,
     module methods do not. Conversely, module methods may be called
     without creating an encapsulating object, while instance methods
     may not. (See +Module#module_function+)

     In the descriptions that follow, the parameter _syml_ refers to a
     symbol, which is either a quoted string or a +Symbol+ (such as
     +:name+).

        module Mod
          include Math
          CONST = 1
          def meth
            #  ...
          end
        end
        Mod.class              #=> Module
        Mod.constants          #=> ["E", "PI", "CONST"]
        Mod.instance_methods   #=> ["meth"]

------------------------------------------------------------------------
     Also, modules included into Object need to be scanned and have
     their instance methods removed from blank slate. In theory, modules
     included into Kernel would have to be removed as well, but a
     "feature" of Ruby prevents late includes into modules from being
     exposed in the first place.

------------------------------------------------------------------------
     Rake extensions to Module.

------------------------------------------------------------------------


Class methods:
--------------
     constants, nesting, new


Instance methods:
-----------------
     <, <=, <=>, ==, ===, >, >=, alias_method, ancestors,
     append_features, attr, attr_accessor, attr_reader, attr_writer,
     autoload, autoload?, class_eval, class_variable_defined?,
     class_variable_get, class_variable_set, class_variables,
     const_defined?, const_get, const_missing, const_set, constants,
     debug_method, define_method, extend_object, extended, freeze,
     include, include?, included, included_modules, instance_method,
     instance_methods, method_added, method_defined?, method_removed,
     method_undefined, module_eval, module_function, name,
     post_mortem_method, private, private_class_method,
     private_instance_methods, private_method_defined?, protected,
     protected_instance_methods, protected_method_defined?, public,
     public_class_method, public_instance_methods,
     public_method_defined?, rake_extension, remove_class_variable,
     remove_const, remove_method, to_s, undef_method

=end
class Module < Object

  # ------------------------------------------------------ Module::constants
  #      Module.constants   => array
  # ------------------------------------------------------------------------
  #      Returns an array of the names of all constants defined in the
  #      system. This list includes the names of all modules and classes.
  # 
  #         p Module.constants.sort[1..5]
  # 
  #      _produces:_
  # 
  #         ["ARGV", "ArgumentError", "Array", "Bignum", "Binding"]
  # 
  def self.constants
  end

  # -------------------------------------------------------- Module::nesting
  #      Module.nesting    => array
  # ------------------------------------------------------------------------
  #      Returns the list of +Modules+ nested at the point of call.
  # 
  #         module M1
  #           module M2
  #             $a = Module.nesting
  #           end
  #         end
  #         $a           #=> [M1::M2, M1]
  #         $a[0].name   #=> "M1::M2"
  # 
  def self.nesting
  end

  # ---------------------------------------------------------- Module#freeze
  #      mod.freeze
  # ------------------------------------------------------------------------
  #      Prevents further modifications to _mod_.
  # 
  def freeze
  end

  def const_missing(arg0)
  end

  # ------------------------------------------------- Module#instance_method
  #      mod.instance_method(symbol)   => unbound_method
  # ------------------------------------------------------------------------
  #      Returns an +UnboundMethod+ representing the given instance method
  #      in _mod_.
  # 
  #         class Interpreter
  #           def do_a() print "there, "; end
  #           def do_d() print "Hello ";  end
  #           def do_e() print "!\n";     end
  #           def do_v() print "Dave";    end
  #           Dispatcher = {
  #            ?a => instance_method(:do_a),
  #            ?d => instance_method(:do_d),
  #            ?e => instance_method(:do_e),
  #            ?v => instance_method(:do_v)
  #           }
  #           def interpret(string)
  #             string.each_byte {|b| Dispatcher[b].bind(self).call }
  #           end
  #         end
  #      
  #         interpreter = Interpreter.new
  #         interpreter.interpret('dave')
  # 
  #      _produces:_
  # 
  #         Hello there, Dave!
  # 
  def instance_method(arg0)
  end

  # ------------------------------------------------------------- Module#<=>
  #      mod <=> other_mod   => -1, 0, +1, or nil
  # ------------------------------------------------------------------------
  #      Comparison---Returns -1 if _mod_ includes _other_mod_, 0 if _mod_
  #      is the same as _other_mod_, and +1 if _mod_ is included by
  #      _other_mod_ or if _mod_ has no relationship with _other_mod_.
  #      Returns +nil+ if _other_mod_ is not a module.
  # 
  def <=>(arg0)
  end

  # ------------------------------------------------------- Module#ancestors
  #      mod.ancestors -> array
  # ------------------------------------------------------------------------
  #      Returns a list of modules included in _mod_ (including _mod_
  #      itself).
  # 
  #         module Mod
  #           include Math
  #           include Comparable
  #         end
  #      
  #         Mod.ancestors    #=> [Mod, Comparable, Math]
  #         Math.ancestors   #=> [Math]
  # 
  def ancestors
  end

  # ------------------------------------------------------- Module#const_get
  #      mod.const_get(sym)    => obj
  # ------------------------------------------------------------------------
  #      Returns the value of the named constant in _mod_.
  # 
  #         Math.const_get(:PI)   #=> 3.14159265358979
  # 
  def const_get(arg0)
  end

  # -------------------------------------------------- Module#const_defined?
  #      mod.const_defined?(sym)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if a constant with the given name is defined by
  #      _mod_.
  # 
  #         Math.const_defined? "PI"   #=> true
  # 
  def const_defined?(arg0)
  end

  # --------------------------------------------- Module#public_class_method
  #      mod.public_class_method(symbol, ...)    => mod
  # ------------------------------------------------------------------------
  #      Makes a list of existing class methods public.
  # 
  def public_class_method(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- Module#==
  #      obj == other        => true or false
  #      obj.equal?(other)   => true or false
  #      obj.eql?(other)     => true or false
  # ------------------------------------------------------------------------
  #      Equality---At the +Object+ level, +==+ returns +true+ only if _obj_
  #      and _other_ are the same object. Typically, this method is
  #      overridden in descendent classes to provide class-specific meaning.
  # 
  #      Unlike +==+, the +equal?+ method should never be overridden by
  #      subclasses: it is used to determine object identity (that is,
  #      +a.equal?(b)+ iff +a+ is the same object as +b+).
  # 
  #      The +eql?+ method returns +true+ if _obj_ and _anObject_ have the
  #      same value. Used by +Hash+ to test members for equality. For
  #      objects of class +Object+, +eql?+ is synonymous with +==+.
  #      Subclasses normally continue this tradition, but there are
  #      exceptions. +Numeric+ types, for example, perform type conversion
  #      across +==+, but not across +eql?+, so:
  # 
  #         1 == 1.0     #=> true
  #         1.eql? 1.0   #=> false
  # 
  def ==(arg0)
  end

  # ------------------------------------------------------------ Module#to_s
  #      mod.to_s   => string
  # ------------------------------------------------------------------------
  #      Return a string representing this module or class. For basic
  #      classes and modules, this is the name. For singletons, we show
  #      information on the thing we're attached to as well.
  # 
  def to_s
  end

  # -------------------------------------------------------- Module#include?
  #      mod.include?(module)    => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _module_ is included in _mod_ or one of _mod_'s
  #      ancestors.
  # 
  #         module A
  #         end
  #         class B
  #           include A
  #         end
  #         class C < B
  #         end
  #         B.include?(A)   #=> true
  #         C.include?(A)   #=> true
  #         A.include?(A)   #=> false
  # 
  def include?(arg0)
  end

  # -------------------------------------- Module#protected_instance_methods
  #      mod.protected_instance_methods(include_super=true)   => array
  # ------------------------------------------------------------------------
  #      Returns a list of the protected instance methods defined in _mod_.
  #      If the optional parameter is not +false+, the methods of any
  #      ancestors are included.
  # 
  def protected_instance_methods(arg0, arg1, *rest)
  end

  # ----------------------------------------- Module#class_variable_defined?
  #      obj.class_variable_defined?(symbol)    => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the given class variable is defined in _obj_.
  # 
  #         class Fred
  #           @@foo = 99
  #         end
  #         Fred.class_variable_defined?(:@@foo)    #=> true
  #         Fred.class_variable_defined?(:@@bar)    #=> false
  # 
  def class_variable_defined?(arg0)
  end

  # ----------------------------------------- Module#private_method_defined?
  #      mod.private_method_defined?(symbol)    => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named private method is defined by _ mod_ (or
  #      its included modules and, if _mod_ is a class, its ancestors).
  # 
  #         module A
  #           def method1()  end
  #         end
  #         class B
  #           private
  #           def method2()  end
  #         end
  #         class C < B
  #           include A
  #           def method3()  end
  #         end
  #      
  #         A.method_defined? :method1            #=> true
  #         C.private_method_defined? "method1"   #=> false
  #         C.private_method_defined? "method2"   #=> true
  #         C.method_defined? "method2"           #=> false
  # 
  def private_method_defined?(arg0)
  end

  # -------------------------------------------------------- Module#autoload
  #      mod.autoload(name, filename)   => nil
  # ------------------------------------------------------------------------
  #      Registers _filename_ to be loaded (using +Kernel::require+) the
  #      first time that _name_ (which may be a +String+ or a symbol) is
  #      accessed in the namespace of _mod_.
  # 
  #         module A
  #         end
  #         A.autoload(:B, "b")
  #         A::B.doit            # autoloads "b"
  # 
  def autoload(arg0, arg1)
  end

  def yaml_as(arg0, arg1, arg2, *rest)
  end

  # ------------------------------------------------------------- Module#===
  #      mod === obj    => true or false
  # ------------------------------------------------------------------------
  #      Case Equality---Returns +true+ if _anObject_ is an instance of
  #      _mod_ or one of _mod_'s descendents. Of limited use for modules,
  #      but can be used in +case+ statements to classify objects by class.
  # 
  def ===(arg0)
  end

  # ------------------------------------------------------ Module#class_eval
  #      mod.class_eval(string [, filename [, lineno]])  => obj
  #      mod.module_eval {|| block }                     => obj
  # ------------------------------------------------------------------------
  #      Evaluates the string or block in the context of _mod_. This can be
  #      used to add methods to a class. +module_eval+ returns the result of
  #      evaluating its argument. The optional _filename_ and _lineno_
  #      parameters set the text for error messages.
  # 
  #         class Thing
  #         end
  #         a = %q{def hello() "Hello there!" end}
  #         Thing.module_eval(a)
  #         puts Thing.new.hello()
  #         Thing.module_eval("invalid code", "dummy", 123)
  # 
  #      _produces:_
  # 
  #         Hello there!
  #         dummy:123:in `module_eval': undefined local variable
  #             or method `code' for Thing:Class
  # 
  def class_eval(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ Module#name
  #      mod.name    => string
  # ------------------------------------------------------------------------
  #      Returns the name of the module _mod_.
  # 
  def name
  end

  # ------------------------------------------------------- Module#constants
  #      mod.constants    => array
  # ------------------------------------------------------------------------
  #      Returns an array of the names of the constants accessible in _mod_.
  #      This includes the names of constants in any included modules
  #      (example at start of section).
  # 
  def constants
  end

  # --------------------------------------------------------------- Module#<
  #      mod < other   =>  true, false, or nil
  # ------------------------------------------------------------------------
  #      Returns true if _mod_ is a subclass of _other_. Returns +nil+ if
  #      there's no relationship between the two. (Think of the relationship
  #      in terms of the class definition: "class A<B" implies "A<B").
  # 
  def <(arg0)
  end

  # -------------------------------------------------------------- Module#>=
  #      mod >= other   =>  true, false, or nil
  # ------------------------------------------------------------------------
  #      Returns true if _mod_ is an ancestor of _other_, or the two modules
  #      are the same. Returns +nil+ if there's no relationship between the
  #      two. (Think of the relationship in terms of the class definition:
  #      "class A<B" implies "B>A").
  # 
  def >=(arg0)
  end

  # ----------------------------------------- Module#public_instance_methods
  #      mod.public_instance_methods(include_super=true)   => array
  # ------------------------------------------------------------------------
  #      Returns a list of the public instance methods defined in _mod_. If
  #      the optional parameter is not +false+, the methods of any ancestors
  #      are included.
  # 
  def public_instance_methods(arg0, arg1, *rest)
  end

  # ------------------------------------------ Module#public_method_defined?
  #      mod.public_method_defined?(symbol)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named public method is defined by _mod_ (or
  #      its included modules and, if _mod_ is a class, its ancestors).
  # 
  #         module A
  #           def method1()  end
  #         end
  #         class B
  #           protected
  #           def method2()  end
  #         end
  #         class C < B
  #           include A
  #           def method3()  end
  #         end
  #      
  #         A.method_defined? :method1           #=> true
  #         C.public_method_defined? "method1"   #=> true
  #         C.public_method_defined? "method2"   #=> false
  #         C.method_defined? "method2"          #=> true
  # 
  def public_method_defined?(arg0)
  end

  # ------------------------------------------------------- Module#autoload?
  #      mod.autoload?(name)   => String or nil
  # ------------------------------------------------------------------------
  #      Returns _filename_ to be loaded if _name_ is registered as
  #      +autoload+ in the namespace of _mod_.
  # 
  #         module A
  #         end
  #         A.autoload(:B, "b")
  #         A.autoload?(:B)            # => "b"
  # 
  def autoload?(arg0)
  end

  # -------------------------------------------------------------- Module#<=
  #      mod <= other   =>  true, false, or nil
  # ------------------------------------------------------------------------
  #      Returns true if _mod_ is a subclass of _other_ or is the same as
  #      _other_. Returns +nil+ if there's no relationship between the two.
  #      (Think of the relationship in terms of the class definition: "class
  #      A<B" implies "A<B").
  # 
  def <=(arg0)
  end

  # ----------------------------------------------------- Module#module_eval
  #      mod.class_eval(string [, filename [, lineno]])  => obj
  #      mod.module_eval {|| block }                     => obj
  # ------------------------------------------------------------------------
  #      Evaluates the string or block in the context of _mod_. This can be
  #      used to add methods to a class. +module_eval+ returns the result of
  #      evaluating its argument. The optional _filename_ and _lineno_
  #      parameters set the text for error messages.
  # 
  #         class Thing
  #         end
  #         a = %q{def hello() "Hello there!" end}
  #         Thing.module_eval(a)
  #         puts Thing.new.hello()
  #         Thing.module_eval("invalid code", "dummy", 123)
  # 
  #      _produces:_
  # 
  #         Hello there!
  #         dummy:123:in `module_eval': undefined local variable
  #             or method `code' for Thing:Class
  # 
  def module_eval(arg0, arg1, *rest)
  end

  def yaml_tag_read_class(arg0)
  end

  # --------------------------------------------------------------- Module#>
  #      mod > other   =>  true, false, or nil
  # ------------------------------------------------------------------------
  #      Returns true if _mod_ is an ancestor of _other_. Returns +nil+ if
  #      there's no relationship between the two. (Think of the relationship
  #      in terms of the class definition: "class A<B" implies "B>A").
  # 
  def >(arg0)
  end

  def yaml_tag_class_name
  end

  # ------------------------------------------------ Module#instance_methods
  #      mod.instance_methods(include_super=true)   => array
  # ------------------------------------------------------------------------
  #      Returns an array containing the names of public instance methods in
  #      the receiver. For a module, these are the public methods; for a
  #      class, they are the instance (not singleton) methods. With no
  #      argument, or with an argument that is +false+, the instance methods
  #      in _mod_ are returned, otherwise the methods in _mod_ and _mod_'s
  #      superclasses are returned.
  # 
  #         module A
  #           def method1()  end
  #         end
  #         class B
  #           def method2()  end
  #         end
  #         class C < B
  #           def method3()  end
  #         end
  #      
  #         A.instance_methods                #=> ["method1"]
  #         B.instance_methods(false)         #=> ["method2"]
  #         C.instance_methods(false)         #=> ["method3"]
  #         C.instance_methods(true).length   #=> 43
  # 
  def instance_methods(arg0, arg1, *rest)
  end

  # ------------------------------------------------- Module#class_variables
  #      mod.class_variables   => array
  # ------------------------------------------------------------------------
  #      Returns an array of the names of class variables in _mod_ and the
  #      ancestors of _mod_.
  # 
  #         class One
  #           @@var1 = 1
  #         end
  #         class Two < One
  #           @@var2 = 2
  #         end
  #         One.class_variables   #=> ["@@var1"]
  #         Two.class_variables   #=> ["@@var2", "@@var1"]
  # 
  def class_variables
  end

  # ------------------------------------------------- Module#method_defined?
  #      mod.method_defined?(symbol)    => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named method is defined by _mod_ (or its
  #      included modules and, if _mod_ is a class, its ancestors). Public
  #      and protected methods are matched.
  # 
  #         module A
  #           def method1()  end
  #         end
  #         class B
  #           def method2()  end
  #         end
  #         class C < B
  #           include A
  #           def method3()  end
  #         end
  #      
  #         A.method_defined? :method1    #=> true
  #         C.method_defined? "method1"   #=> true
  #         C.method_defined? "method2"   #=> true
  #         C.method_defined? "method3"   #=> true
  #         C.method_defined? "method4"   #=> false
  # 
  def method_defined?(arg0)
  end

  # ------------------------------------------------------- Module#const_set
  #      mod.const_set(sym, obj)    => obj
  # ------------------------------------------------------------------------
  #      Sets the named constant to the given object, returning that object.
  #      Creates a new constant if no constant with the given name
  #      previously existed.
  # 
  #         Math.const_set("HIGH_SCHOOL_PI", 22.0/7.0)   #=> 3.14285714285714
  #         Math::HIGH_SCHOOL_PI - Math::PI              #=> 0.00126448926734968
  # 
  def const_set(arg0, arg1)
  end

  # -------------------------------------------- Module#private_class_method
  #      mod.private_class_method(symbol, ...)   => mod
  # ------------------------------------------------------------------------
  #      Makes existing class methods private. Often used to hide the
  #      default constructor +new+.
  # 
  #         class SimpleSingleton  # Not thread safe
  #           private_class_method :new
  #           def SimpleSingleton.create(*args, &block)
  #             @me = new(*args, &block) if ! @me
  #             @me
  #           end
  #         end
  # 
  def private_class_method(arg0, arg1, *rest)
  end

  # ------------------------------------------------ Module#included_modules
  #      mod.included_modules -> array
  # ------------------------------------------------------------------------
  #      Returns the list of modules included in _mod_.
  # 
  #         module Mixin
  #         end
  #      
  #         module Outer
  #           include Mixin
  #         end
  #      
  #         Mixin.included_modules   #=> []
  #         Outer.included_modules   #=> [Mixin]
  # 
  def included_modules
  end

  # ---------------------------------------- Module#private_instance_methods
  #      mod.private_instance_methods(include_super=true)    => array
  # ------------------------------------------------------------------------
  #      Returns a list of the private instance methods defined in _mod_. If
  #      the optional parameter is not +false+, the methods of any ancestors
  #      are included.
  # 
  #         module Mod
  #           def method1()  end
  #           private :method1
  #           def method2()  end
  #         end
  #         Mod.instance_methods           #=> ["method2"]
  #         Mod.private_instance_methods   #=> ["method1"]
  # 
  def private_instance_methods(arg0, arg1, *rest)
  end

  # --------------------------------------- Module#protected_method_defined?
  #      mod.protected_method_defined?(symbol)   => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the named protected method is defined by _mod_
  #      (or its included modules and, if _mod_ is a class, its ancestors).
  # 
  #         module A
  #           def method1()  end
  #         end
  #         class B
  #           protected
  #           def method2()  end
  #         end
  #         class C < B
  #           include A
  #           def method3()  end
  #         end
  #      
  #         A.method_defined? :method1              #=> true
  #         C.protected_method_defined? "method1"   #=> false
  #         C.protected_method_defined? "method2"   #=> true
  #         C.method_defined? "method2"             #=> true
  # 
  def protected_method_defined?(arg0)
  end

end
