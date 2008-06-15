=begin
-------------------------------------------------- Class: Class < Module
     Classes in Ruby are first-class objects---each is an instance of
     class +Class+.

     When a new class is created (typically using +class Name ... end+),
     an object of type +Class+ is created and assigned to a global
     constant (+Name+ in this case). When +Name.new+ is called to create
     a new object, the +new+ method in +Class+ is run by default. This
     can be demonstrated by overriding +new+ in +Class+:

        class Class
           alias oldNew  new
           def new(*args)
             print "Creating a new ", self.name, "\n"
             oldNew(*args)
           end
         end
     
         class Name
         end
     
         n = Name.new

     _produces:_

        Creating a new Name

     Classes, modules, and objects are interrelated. In the diagram that
     follows, the vertical arrows represent inheritance, and the
     parentheses meta-classes. All metaclasses are instances of the
     class `Class'.

                               +------------------+
                               |                  |
                 Object---->(Object)              |
                  ^  ^        ^  ^                |
                  |  |        |  |                |
                  |  |  +-----+  +---------+      |
                  |  |  |                  |      |
                  |  +-----------+         |      |
                  |     |        |         |      |
           +------+     |     Module--->(Module)  |
           |            |        ^         ^      |
      OtherClass-->(OtherClass)  |         |      |
                                 |         |      |
                               Class---->(Class)  |
                                 ^                |
                                 |                |
                                 +----------------+

------------------------------------------------------------------------
     Allows attributes to be shared within an inheritance hierarchy, but
     where each descendant gets a copy of their parents' attributes,
     instead of just a pointer to the same. This means that the child
     can add elements to, for example, an array without those additions
     being shared with either their parent, siblings, or children, which
     is unlike the regular class-level attributes that are shared across
     the entire hierarchy.

------------------------------------------------------------------------


Class methods:
--------------
     new


Instance methods:
-----------------
     allocate, inherited, new, superclass, to_yaml

=end
class Class < Module

  # --------------------------------------------------------- Class#allocate
  #      class.allocate()   =>   obj
  # ------------------------------------------------------------------------
  #      Allocates space for a new object of _class_'s class. The returned
  #      object must be an instance of _class_.
  # 
  def allocate
  end

  # ------------------------------------------------------- Class#superclass
  #      class.superclass -> a_super_class or nil
  # ------------------------------------------------------------------------
  #      Returns the superclass of _class_, or +nil+.
  # 
  #         File.superclass     #=> IO
  #         IO.superclass       #=> Object
  #         Object.superclass   #=> nil
  # 
  def superclass
  end

  # -------------------------------------------------------------- Class#new
  #      class.new(args, ...)    =>  obj
  # ------------------------------------------------------------------------
  #      Calls +allocate+ to create a new object of _class_'s class, then
  #      invokes that object's +initialize+ method, passing it _args_. This
  #      is the method that ends up getting called whenever an object is
  #      constructed using .new.
  # 
  def new(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- Class#to_yaml
  #      to_yaml( opts = {} )
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml(arg0, arg1, *rest)
  end

end
