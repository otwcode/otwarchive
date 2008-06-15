=begin
---------------------------------------------------------- Class: Symbol
     +Symbol+ objects represent names and some strings inside the Ruby
     interpreter. They are generated using the +:name+ and +:"string"+
     literals syntax, and by the various +to_sym+ methods. The same
     +Symbol+ object will be created for a given name or string for the
     duration of a program's execution, regardless of the context or
     meaning of that name. Thus if +Fred+ is a constant in one context,
     a method in another, and a class in a third, the +Symbol+ +:Fred+
     will be the same object in all three contexts.

        module One
          class Fred
          end
          $f1 = :Fred
        end
        module Two
          Fred = 1
          $f2 = :Fred
        end
        def Fred()
        end
        $f3 = :Fred
        $f1.id   #=> 2514190
        $f2.id   #=> 2514190
        $f3.id   #=> 2514190

------------------------------------------------------------------------


Class methods:
--------------
     all_symbols, yaml_new


Instance methods:
-----------------
     ===, dclone, id2name, inspect, to_i, to_int, to_s, to_sym, to_yaml

=end
class Symbol < Object

  # ---------------------------------------------------- Symbol::all_symbols
  #      Symbol.all_symbols    => array
  # ------------------------------------------------------------------------
  #      Returns an array of all the symbols currently in Ruby's symbol
  #      table.
  # 
  #         Symbol.all_symbols.size    #=> 903
  #         Symbol.all_symbols[1,20]   #=> [:floor, :ARGV, :Binding, :symlink,
  #                                         :chown, :EOFError, :$;, :String,
  #                                         :LOCK_SH, :"setuid?", :$<,
  #                                         :default_proc, :compact, :extend,
  #                                         :Tms, :getwd, :$=, :ThreadGroup,
  #                                         :wait2, :$>]
  # 
  def self.all_symbols
  end

  # ------------------------------------------------------- Symbol::yaml_new
  #      Symbol::yaml_new( klass, tag, val )
  # ------------------------------------------------------------------------
  #      (no description...)
  def self.yaml_new(arg0, arg1, arg2)
  end

  def self.yaml_tag_subclasses?
  end

  # ------------------------------------------------------------ Symbol#to_s
  #      sym.id2name   => string
  #      sym.to_s      => string
  # ------------------------------------------------------------------------
  #      Returns the name or string corresponding to _sym_.
  # 
  #         :fred.id2name   #=> "fred"
  # 
  def to_s
  end

  # ---------------------------------------------------------- Symbol#to_sym
  #      sym.to_sym   => sym
  # ------------------------------------------------------------------------
  #      In general, +to_sym+ returns the +Symbol+ corresponding to an
  #      object. As _sym_ is already a symbol, +self+ is returned in this
  #      case.
  # 
  def to_sym
  end

  def taguri=(arg0)
  end

  # ------------------------------------------------------------- Symbol#===
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
  def ===(arg0)
  end

  # ------------------------------------------------------------ Symbol#to_i
  #      sym.to_i      => fixnum
  # ------------------------------------------------------------------------
  #      Returns an integer that is unique for each symbol within a
  #      particular execution of a program.
  # 
  #         :fred.to_i           #=> 9809
  #         "fred".to_sym.to_i   #=> 9809
  # 
  def to_i
  end

  # --------------------------------------------------------- Symbol#id2name
  #      sym.id2name   => string
  #      sym.to_s      => string
  # ------------------------------------------------------------------------
  #      Returns the name or string corresponding to _sym_.
  # 
  #         :fred.id2name   #=> "fred"
  # 
  def id2name
  end

  # ---------------------------------------------------------- Symbol#to_int
  #      to_int()
  # ------------------------------------------------------------------------
  #      :nodoc:
  # 
  def to_int
  end

  # --------------------------------------------------------- Symbol#inspect
  #      sym.inspect    => string
  # ------------------------------------------------------------------------
  #      Returns the representation of _sym_ as a symbol literal.
  # 
  #         :fred.inspect   #=> ":fred"
  # 
  def inspect
  end

  def taguri
  end

  # --------------------------------------------------------- Symbol#to_yaml
  #      to_yaml( opts = {} )
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml(arg0, arg1, *rest)
  end

end
