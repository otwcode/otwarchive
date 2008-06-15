=begin
----------------------------------------------------------- Class: Range
     A +Range+ represents an interval---a set of values with a start and
     an end. Ranges may be constructed using the _s_+..+_e_ and
     _s_+...+_e_ literals, or with +Range::new+. Ranges constructed
     using +..+ run from the start to the end inclusively. Those created
     using +...+ exclude the end value. When used as an iterator, ranges
     return each value in the sequence.

        (-1..-5).to_a      #=> []
        (-5..-1).to_a      #=> [-5, -4, -3, -2, -1]
        ('a'..'e').to_a    #=> ["a", "b", "c", "d", "e"]
        ('a'...'e').to_a   #=> ["a", "b", "c", "d"]

     Ranges can be constructed using objects of any type, as long as the
     objects can be compared using their +<=>+ operator and they support
     the +succ+ method to return the next object in sequence.

        class Xs                # represent a string of 'x's
          include Comparable
          attr :length
          def initialize(n)
            @length = n
          end
          def succ
            Xs.new(@length + 1)
          end
          def <=>(other)
            @length <=> other.length
          end
          def to_s
            sprintf "%2d #{inspect}", @length
          end
          def inspect
            'x' * @length
          end
        end
     
        r = Xs.new(3)..Xs.new(6)   #=> xxx..xxxxxx
        r.to_a                     #=> [xxx, xxxx, xxxxx, xxxxxx]
        r.member?(Xs.new(5))       #=> true

     In the previous code example, class +Xs+ includes the +Comparable+
     module. This is because +Enumerable#member?+ checks for equality
     using +==+. Including +Comparable+ ensures that the +==+ method is
     defined in terms of the +<=>+ method implemented in +Xs+.

------------------------------------------------------------------------


Includes:
---------
     Enumerable(all?, any?, collect, detect, each_cons, each_slice,
     each_with_index, entries, enum_cons, enum_slice, enum_with_index,
     find, find_all, grep, group_by, include?, index_by, inject, map,
     max, member?, min, partition, reject, select, sort, sort_by, sum,
     to_a, to_set, zip)


Class methods:
--------------
     new, yaml_new


Instance methods:
-----------------
     ==, ===, begin, each, end, eql?, exclude_end?, first, hash,
     include?, inspect, last, member?, pretty_print, step, to_s, to_yaml

=end
class Range < Object
  include Enumerable

  # -------------------------------------------------------- Range::yaml_new
  #      Range::yaml_new( klass, tag, val )
  # ------------------------------------------------------------------------
  #      (no description...)
  def self.yaml_new(arg0, arg1, arg2)
  end

  def self.yaml_tag_subclasses?
  end

  # ------------------------------------------------------------- Range#eql?
  #      rng.eql?(obj)    => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ only if _obj_ is a Range, has equivalent beginning
  #      and end items (by comparing them with #eql?), and has the same
  #      #exclude_end? setting as _rng_.
  # 
  #        (0..2) == (0..2)            #=> true
  #        (0..2) == Range.new(0,2)    #=> true
  #        (0..2) == (0...2)           #=> false
  # 
  def eql?
  end

  # ------------------------------------------------------------- Range#step
  #      rng.step(n=1) {| obj | block }    => rng
  # ------------------------------------------------------------------------
  #      Iterates over _rng_, passing each _n_th element to the block. If
  #      the range contains numbers or strings, natural ordering is used.
  #      Otherwise +step+ invokes +succ+ to iterate through range elements.
  #      The following code uses class +Xs+, which is defined in the
  #      class-level documentation.
  # 
  #         range = Xs.new(1)..Xs.new(10)
  #         range.step(2) {|x| puts x}
  #         range.step(3) {|x| puts x}
  # 
  #      _produces:_
  # 
  #          1 x
  #          3 xxx
  #          5 xxxxx
  #          7 xxxxxxx
  #          9 xxxxxxxxx
  #          1 x
  #          4 xxxx
  #          7 xxxxxxx
  #         10 xxxxxxxxxx
  # 
  def step
  end

  # --------------------------------------------------------------- Range#==
  #      rng == obj    => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ only if _obj_ is a Range, has equivalent beginning
  #      and end items (by comparing them with +==+), and has the same
  #      #exclude_end? setting as <i>rng</t>.
  # 
  #        (0..2) == (0..2)            #=> true
  #        (0..2) == Range.new(0,2)    #=> true
  #        (0..2) == (0...2)           #=> false
  # 
  def ==
  end

  # ------------------------------------------------------------- Range#each
  #      rng.each {| i | block } => rng
  # ------------------------------------------------------------------------
  #      Iterates over the elements _rng_, passing each in turn to the
  #      block. You can only iterate if the start object of the range
  #      supports the +succ+ method (which means that you can't iterate over
  #      ranges of +Float+ objects).
  # 
  #         (10..15).each do |n|
  #            print n, ' '
  #         end
  # 
  #      _produces:_
  # 
  #         10 11 12 13 14 15
  # 
  def each
  end

  # -------------------------------------------------------------- Range#end
  #      rng.end    => obj
  #      rng.last   => obj
  # ------------------------------------------------------------------------
  #      Returns the object that defines the end of _rng_.
  # 
  #         (1..10).end    #=> 10
  #         (1...10).end   #=> 10
  # 
  def end
  end

  # ------------------------------------------------------------- Range#to_s
  #      rng.to_s   => string
  # ------------------------------------------------------------------------
  #      Convert this range object to a printable form.
  # 
  def to_s
  end

  # --------------------------------------------------------- Range#include?
  #      rng === obj       =>  true or false
  #      rng.member?(val)  =>  true or false
  #      rng.include?(val) =>  true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _obj_ is an element of _rng_, +false+ otherwise.
  #      Conveniently, +===+ is the comparison operator used by +case+
  #      statements.
  # 
  #         case 79
  #         when 1..50   then   print "low\n"
  #         when 51..75  then   print "medium\n"
  #         when 76..100 then   print "high\n"
  #         end
  # 
  #      _produces:_
  # 
  #         high
  # 
  def include?
  end

  def taguri=
  end

  # -------------------------------------------------------------- Range#===
  #      rng === obj       =>  true or false
  #      rng.member?(val)  =>  true or false
  #      rng.include?(val) =>  true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _obj_ is an element of _rng_, +false+ otherwise.
  #      Conveniently, +===+ is the comparison operator used by +case+
  #      statements.
  # 
  #         case 79
  #         when 1..50   then   print "low\n"
  #         when 51..75  then   print "medium\n"
  #         when 76..100 then   print "high\n"
  #         end
  # 
  #      _produces:_
  # 
  #         high
  # 
  def ===
  end

  # ------------------------------------------------------------- Range#hash
  #      rng.hash    => fixnum
  # ------------------------------------------------------------------------
  #      Generate a hash value such that two ranges with the same start and
  #      end points, and the same value for the "exclude end" flag, generate
  #      the same hash value.
  # 
  def hash
  end

  # ------------------------------------------------------------ Range#begin
  #      rng.first    => obj
  #      rng.begin    => obj
  # ------------------------------------------------------------------------
  #      Returns the first object in _rng_.
  # 
  def begin
  end

  # ----------------------------------------------------- Range#exclude_end?
  #      rng.exclude_end?    => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _rng_ excludes its end value.
  # 
  def exclude_end?
  end

  # ---------------------------------------------------------- Range#member?
  #      rng === obj       =>  true or false
  #      rng.member?(val)  =>  true or false
  #      rng.include?(val) =>  true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _obj_ is an element of _rng_, +false+ otherwise.
  #      Conveniently, +===+ is the comparison operator used by +case+
  #      statements.
  # 
  #         case 79
  #         when 1..50   then   print "low\n"
  #         when 51..75  then   print "medium\n"
  #         when 76..100 then   print "high\n"
  #         end
  # 
  #      _produces:_
  # 
  #         high
  # 
  def member?
  end

  # ------------------------------------------------------------- Range#last
  #      rng.end    => obj
  #      rng.last   => obj
  # ------------------------------------------------------------------------
  #      Returns the object that defines the end of _rng_.
  # 
  #         (1..10).end    #=> 10
  #         (1...10).end   #=> 10
  # 
  def last
  end

  # ------------------------------------------------------------ Range#first
  #      rng.first    => obj
  #      rng.begin    => obj
  # ------------------------------------------------------------------------
  #      Returns the first object in _rng_.
  # 
  def first
  end

  # ---------------------------------------------------------- Range#inspect
  #      rng.inspect  => string
  # ------------------------------------------------------------------------
  #      Convert this range object to a printable form (using +inspect+ to
  #      convert the start and end objects).
  # 
  def inspect
  end

  def taguri
  end

  # ---------------------------------------------------------- Range#to_yaml
  #      to_yaml( opts = {} )
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml
  end

end
