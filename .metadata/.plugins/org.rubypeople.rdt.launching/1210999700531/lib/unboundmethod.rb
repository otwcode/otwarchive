=begin
--------------------------------------------------- Class: UnboundMethod
     Ruby supports two forms of objectified methods. Class +Method+ is
     used to represent methods that are associated with a particular
     object: these method objects are bound to that object. Bound method
     objects for an object can be created using +Object#method+.

     Ruby also supports unbound methods; methods objects that are not
     associated with a particular object. These can be created either by
     calling +Module#instance_method+ or by calling +unbind+ on a bound
     method object. The result of both of these is an +UnboundMethod+
     object.

     Unbound methods can only be called after they are bound to an
     object. That object must be be a kind_of? the method's original
     class.

        class Square
          def area
            @side * @side
          end
          def initialize(side)
            @side = side
          end
        end
     
        area_un = Square.instance_method(:area)
     
        s = Square.new(12)
        area = area_un.bind(s)
        area.call   #=> 144

     Unbound methods are a reference to the method at the time it was
     objectified: subsequent changes to the underlying class will not
     affect the unbound method.

        class Test
          def test
            :original
          end
        end
        um = Test.instance_method(:test)
        class Test
          def test
            :modified
          end
        end
        t = Test.new
        t.test            #=> :modified
        um.bind(t).call   #=> :original

------------------------------------------------------------------------


Instance methods:
-----------------
     ==, arity, bind, clone, inspect, to_s

=end
class UnboundMethod < Object

  # ------------------------------------------------------- UnboundMethod#==
  #      meth == other_meth  => true or false
  # ------------------------------------------------------------------------
  #      Two method objects are equal if that are bound to the same object
  #      and contain the same body.
  # 
  def ==
  end

  # ----------------------------------------------------- UnboundMethod#to_s
  #      meth.to_s      =>  string
  #      meth.inspect   =>  string
  # ------------------------------------------------------------------------
  #      Show the name of the underlying method.
  # 
  #        "cat".method(:count).inspect   #=> "#<Method: String#count>"
  # 
  def to_s
  end

  # ----------------------------------------------------- UnboundMethod#bind
  #      umeth.bind(obj) -> method
  # ------------------------------------------------------------------------
  #      Bind _umeth_ to _obj_. If +Klass+ was the class from which _umeth_
  #      was obtained, +obj.kind_of?(Klass)+ must be true.
  # 
  #         class A
  #           def test
  #             puts "In test, class = #{self.class}"
  #           end
  #         end
  #         class B < A
  #         end
  #         class C < B
  #         end
  #      
  #         um = B.instance_method(:test)
  #         bm = um.bind(C.new)
  #         bm.call
  #         bm = um.bind(B.new)
  #         bm.call
  #         bm = um.bind(A.new)
  #         bm.call
  # 
  #      _produces:_
  # 
  #         In test, class = C
  #         In test, class = B
  #         prog.rb:16:in `bind': bind argument must be an instance of B (TypeError)
  #          from prog.rb:16
  # 
  def bind
  end

  # ---------------------------------------------------- UnboundMethod#clone
  #      clone()
  # ------------------------------------------------------------------------
  #      MISSING: documentation
  # 
  def clone
  end

  # ---------------------------------------------------- UnboundMethod#arity
  #      meth.arity    => fixnum
  # ------------------------------------------------------------------------
  #      Returns an indication of the number of arguments accepted by a
  #      method. Returns a nonnegative integer for methods that take a fixed
  #      number of arguments. For Ruby methods that take a variable number
  #      of arguments, returns -n-1, where n is the number of required
  #      arguments. For methods written in C, returns -1 if the call takes a
  #      variable number of arguments.
  # 
  #         class C
  #           def one;    end
  #           def two(a); end
  #           def three(*a);  end
  #           def four(a, b); end
  #           def five(a, b, *c);    end
  #           def six(a, b, *c, &d); end
  #         end
  #         c = C.new
  #         c.method(:one).arity     #=> 0
  #         c.method(:two).arity     #=> 1
  #         c.method(:three).arity   #=> -1
  #         c.method(:four).arity    #=> 2
  #         c.method(:five).arity    #=> -3
  #         c.method(:six).arity     #=> -3
  #      
  #         "cat".method(:size).arity      #=> 0
  #         "cat".method(:replace).arity   #=> 1
  #         "cat".method(:squeeze).arity   #=> -1
  #         "cat".method(:count).arity     #=> -1
  # 
  def arity
  end

  # -------------------------------------------------- UnboundMethod#inspect
  #      meth.to_s      =>  string
  #      meth.inspect   =>  string
  # ------------------------------------------------------------------------
  #      Show the name of the underlying method.
  # 
  #        "cat".method(:count).inspect   #=> "#<Method: String#count>"
  # 
  def inspect
  end

end
