=begin
----------------------------------------------------------- Class: Array
     Arrays are ordered, integer-indexed collections of any object.
     Array indexing starts at 0, as in C or Java. A negative index is
     assumed to be relative to the end of the array---that is, an index
     of -1 indicates the last element of the array, -2 is the next to
     last element in the array, and so on.

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
     [], new


Instance methods:
-----------------
     &, *, +, -, <<, <=>, ==, [], []=, abbrev, assoc, at, clear,
     collect, collect!, compact, compact!, concat, dclone, delete,
     delete_at, delete_if, each, each_index, empty?, eql?, fetch, fill,
     first, flatten, flatten!, frozen?, hash, include?, index, indexes,
     indices, initialize_copy, insert, inspect, join, last, length, map,
     map!, nitems, pack, pop, pretty_print, pretty_print_cycle, push,
     quote, rassoc, reject, reject!, replace, reverse, reverse!,
     reverse_each, rindex, select, shift, size, slice, slice!, sort,
     sort!, to_a, to_ary, to_s, to_yaml, transpose, uniq, uniq!,
     unshift, values_at, yaml_initialize, zip, |

=end
class Array < Object
  include Enumerable

  # -------------------------------------------------------------- Array::[]
  #      Array::[](...)
  # ------------------------------------------------------------------------
  #      Returns a new array populated with the given objects.
  # 
  #        Array.[]( 1, 'a', /^A/ )
  #        Array[ 1, 'a', /^A/ ]
  #        [ 1, 'a', /^A/ ]
  # 
  def self.[](arg0, arg1, *rest)
  end

  def self.yaml_tag_subclasses?
  end

  # ---------------------------------------------------------- Array#indexes
  #      array.indexes( i1, i2, ... iN )   -> an_array
  #      array.indices( i1, i2, ... iN )   -> an_array
  # ------------------------------------------------------------------------
  #      Deprecated; use +Array#values_at+.
  # 
  def indexes(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------------- Array#&
  #      array & other_array
  # ------------------------------------------------------------------------
  #      Set Intersection---Returns a new array containing elements common
  #      to the two arrays, with no duplicates.
  # 
  #         [ 1, 1, 3, 5 ] & [ 1, 2, 3 ]   #=> [ 1, 3 ]
  # 
  def &(arg0)
  end

  # ------------------------------------------------------------- Array#map!
  #      array.collect! {|item| block }   ->   array
  #      array.map!     {|item| block }   ->   array
  # ------------------------------------------------------------------------
  #      Invokes the block once for each element of _self_, replacing the
  #      element with the value returned by _block_. See also
  #      +Enumerable#collect+.
  # 
  #         a = [ "a", "b", "c", "d" ]
  #         a.collect! {|x| x + "!" }
  #         a             #=>  [ "a!", "b!", "c!", "d!" ]
  # 
  def map!
  end

  # ------------------------------------------------------------- Array#last
  #      array.last     ->  obj or nil
  #      array.last(n)  ->  an_array
  # ------------------------------------------------------------------------
  #      Returns the last element(s) of _self_. If the array is empty, the
  #      first form returns +nil+.
  # 
  #         [ "w", "x", "y", "z" ].last   #=> "z"
  # 
  def last(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- Array#empty?
  #      array.empty?   -> true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _self_ array contains no elements.
  # 
  #         [].empty?   #=> true
  # 
  def empty?
  end

  # ------------------------------------------------------------ Array#assoc
  #      array.assoc(obj)   ->  an_array  or  nil
  # ------------------------------------------------------------------------
  #      Searches through an array whose elements are also arrays comparing
  #      _obj_ with the first element of each contained array using obj.==.
  #      Returns the first contained array that matches (that is, the first
  #      associated array), or +nil+ if no match is found. See also
  #      +Array#rassoc+.
  # 
  #         s1 = [ "colors", "red", "blue", "green" ]
  #         s2 = [ "letters", "a", "b", "c" ]
  #         s3 = "foo"
  #         a  = [ s1, s2, s3 ]
  #         a.assoc("letters")  #=> [ "letters", "a", "b", "c" ]
  #         a.assoc("foo")      #=> nil
  # 
  def assoc(arg0)
  end

  # ----------------------------------------------------------- Array#rindex
  #      array.rindex(obj)    ->  int or nil
  # ------------------------------------------------------------------------
  #      Returns the index of the last object in _array_ +==+ to _obj_.
  #      Returns +nil+ if no match is found.
  # 
  #         a = [ "a", "b", "b", "b", "c" ]
  #         a.rindex("b")   #=> 3
  #         a.rindex("z")   #=> nil
  # 
  def rindex(arg0)
  end

  # ----------------------------------------------------------- Array#reject
  #      array.reject {|item| block }  -> an_array
  # ------------------------------------------------------------------------
  #      Returns a new array containing the items in _self_ for which the
  #      block is not true.
  # 
  def reject
  end

  # -------------------------------------------------------- Array#values_at
  #      array.values_at(selector,... )  -> an_array
  # ------------------------------------------------------------------------
  #      Returns an array containing the elements in _self_ corresponding to
  #      the given selector(s). The selectors may be either integer indices
  #      or ranges. See also +Array#select+.
  # 
  #         a = %w{ a b c d e f }
  #         a.values_at(1, 3, 5)
  #         a.values_at(1, 3, 5, 7)
  #         a.values_at(-1, -3, -5, -7)
  #         a.values_at(1..3, 2...5)
  # 
  def values_at(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------- Array#to_s
  #      array.to_s -> string
  # ------------------------------------------------------------------------
  #      Returns _self_+.join+.
  # 
  #         [ "a", "e", "i", "o" ].to_s   #=> "aeio"
  # 
  def to_s
  end

  # --------------------------------------------------------- Array#reverse!
  #      array.reverse!   -> array 
  # ------------------------------------------------------------------------
  #      Reverses _self_ in place.
  # 
  #         a = [ "a", "b", "c" ]
  #         a.reverse!       #=> ["c", "b", "a"]
  #         a                #=> ["c", "b", "a"]
  # 
  def reverse!
  end

  # ------------------------------------------------------------ Array#sort!
  #      array.sort!                   -> array
  #      array.sort! {| a,b | block }  -> array 
  # ------------------------------------------------------------------------
  #      Sorts _self_. Comparisons for the sort will be done using the +<=>+
  #      operator or using an optional code block. The block implements a
  #      comparison between _a_ and _b_, returning -1, 0, or +1. See also
  #      +Enumerable#sort_by+.
  # 
  #         a = [ "d", "a", "e", "c", "b" ]
  #         a.sort                    #=> ["a", "b", "c", "d", "e"]
  #         a.sort {|x,y| y <=> x }   #=> ["e", "d", "c", "b", "a"]
  # 
  def sort!
  end

  # ------------------------------------------------------------- Array#sort
  #      array.sort                   -> an_array 
  #      array.sort {| a,b | block }  -> an_array 
  # ------------------------------------------------------------------------
  #      Returns a new array created by sorting _self_. Comparisons for the
  #      sort will be done using the +<=>+ operator or using an optional
  #      code block. The block implements a comparison between _a_ and _b_,
  #      returning -1, 0, or +1. See also +Enumerable#sort_by+.
  # 
  #         a = [ "d", "a", "e", "c", "b" ]
  #         a.sort                    #=> ["a", "b", "c", "d", "e"]
  #         a.sort {|x,y| y <=> x }   #=> ["e", "d", "c", "b", "a"]
  # 
  def sort
  end

  # ------------------------------------------------------- Array#each_index
  #      array.each_index {|index| block }  ->  array
  # ------------------------------------------------------------------------
  #      Same as +Array#each+, but passes the index of the element instead
  #      of the element itself.
  # 
  #         a = [ "a", "b", "c" ]
  #         a.each_index {|x| print x, " -- " }
  # 
  #      produces:
  # 
  #         0 -- 1 -- 2 --
  # 
  def each_index
  end

  # ------------------------------------------------------------- Array#each
  #      array.each {|item| block }   ->   array
  # ------------------------------------------------------------------------
  #      Calls _block_ once for each element in _self_, passing that element
  #      as a parameter.
  # 
  #         a = [ "a", "b", "c" ]
  #         a.each {|x| print x, " -- " }
  # 
  #      produces:
  # 
  #         a -- b -- c --
  # 
  def each
  end

  # --------------------------------------------------------- Array#include?
  #      array.include?(obj)   -> true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the given object is present in _self_ (that is,
  #      if any object +==+ _anObject_), +false+ otherwise.
  # 
  #         a = [ "a", "b", "c" ]
  #         a.include?("b")   #=> true
  #         a.include?("z")   #=> false
  # 
  def include?(arg0)
  end

  # ------------------------------------------------------------ Array#slice
  #      array[index]                -> obj      or nil
  #      array[start, length]        -> an_array or nil
  #      array[range]                -> an_array or nil
  #      array.slice(index)          -> obj      or nil
  #      array.slice(start, length)  -> an_array or nil
  #      array.slice(range)          -> an_array or nil
  # ------------------------------------------------------------------------
  #      Element Reference---Returns the element at _index_, or returns a
  #      subarray starting at _start_ and continuing for _length_ elements,
  #      or returns a subarray specified by _range_. Negative indices count
  #      backward from the end of the array (-1 is the last element).
  #      Returns nil if the index (or starting index) are out of range.
  # 
  #         a = [ "a", "b", "c", "d", "e" ]
  #         a[2] +  a[0] + a[1]    #=> "cab"
  #         a[6]                   #=> nil
  #         a[1, 2]                #=> [ "b", "c" ]
  #         a[1..3]                #=> [ "b", "c", "d" ]
  #         a[4..7]                #=> [ "e" ]
  #         a[6..10]               #=> nil
  #         a[-3, 3]               #=> [ "c", "d", "e" ]
  #         # special cases
  #         a[5]                   #=> nil
  #         a[5, 1]                #=> []
  #         a[5..10]               #=> []
  # 
  def slice(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------------- Array#*
  #      array * int     ->    an_array
  #      array * str     ->    a_string
  # ------------------------------------------------------------------------
  #      Repetition---With a String argument, equivalent to self.join(str).
  #      Otherwise, returns a new array built by concatenating the _int_
  #      copies of _self_.
  # 
  #         [ 1, 2, 3 ] * 3    #=> [ 1, 2, 3, 1, 2, 3, 1, 2, 3 ]
  #         [ 1, 2, 3 ] * ","  #=> "1,2,3"
  # 
  def *(arg0)
  end

  # ------------------------------------------------------------ Array#fetch
  #      array.fetch(index)                    -> obj
  #      array.fetch(index, default )          -> obj
  #      array.fetch(index) {|index| block }   -> obj
  # ------------------------------------------------------------------------
  #      Tries to return the element at position _index_. If the index lies
  #      outside the array, the first form throws an +IndexError+ exception,
  #      the second form returns _default_, and the third form returns the
  #      value of invoking the block, passing in the index. Negative values
  #      of _index_ count from the end of the array.
  # 
  #         a = [ 11, 22, 33, 44 ]
  #         a.fetch(1)               #=> 22
  #         a.fetch(-1)              #=> 44
  #         a.fetch(4, 'cat')        #=> "cat"
  #         a.fetch(4) { |i| i*i }   #=> 16
  # 
  def fetch(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ Array#clear
  #      array.clear    ->  array
  # ------------------------------------------------------------------------
  #      Removes all elements from _self_.
  # 
  #         a = [ "a", "b", "c", "d", "e" ]
  #         a.clear    #=> [ ]
  # 
  def clear
  end

  # ---------------------------------------------------------------- Array#+
  #      array + other_array   -> an_array
  # ------------------------------------------------------------------------
  #      Concatenation---Returns a new array built by concatenating the two
  #      arrays together to produce a third array.
  # 
  #         [ 1, 2, 3 ] + [ 4, 5 ]    #=> [ 1, 2, 3, 4, 5 ]
  # 
  def +(arg0)
  end

  # -------------------------------------------------- Array#yaml_initialize
  #      yaml_initialize( tag, val )
  # ------------------------------------------------------------------------
  #      (no description...)
  def yaml_initialize(arg0, arg1)
  end

  # ----------------------------------------------------------- Array#concat
  #      array.concat(other_array)   ->  array
  # ------------------------------------------------------------------------
  #      Appends the elements in other_array to _self_.
  # 
  #         [ "a", "b" ].concat( ["c", "d"] ) #=> [ "a", "b", "c", "d" ]
  # 
  def concat(arg0)
  end

  # ------------------------------------------------------------ Array#shift
  #      array.shift   ->   obj or nil
  # ------------------------------------------------------------------------
  #      Returns the first element of _self_ and removes it (shifting all
  #      other elements down by one). Returns +nil+ if the array is empty.
  # 
  #         args = [ "-m", "-q", "filename" ]
  #         args.shift   #=> "-m"
  #         args         #=> ["-q", "filename"]
  # 
  def shift
  end

  # ------------------------------------------------------------- Array#size
  #      size()
  # ------------------------------------------------------------------------
  #      Alias for #length
  # 
  def size
  end

  # --------------------------------------------------------- Array#flatten!
  #      array.flatten! -> array or nil
  # ------------------------------------------------------------------------
  #      Flattens _self_ in place. Returns +nil+ if no modifications were
  #      made (i.e., _array_ contains no subarrays.)
  # 
  #         a = [ 1, 2, [3, [4, 5] ] ]
  #         a.flatten!   #=> [1, 2, 3, 4, 5]
  #         a.flatten!   #=> nil
  #         a            #=> [1, 2, 3, 4, 5]
  # 
  def flatten!
  end

  # ------------------------------------------------------------- Array#join
  #      array.join(sep=$,)    -> str
  # ------------------------------------------------------------------------
  #      Returns a string created by converting each element of the array to
  #      a string, separated by _sep_.
  # 
  #         [ "a", "b", "c" ].join        #=> "abc"
  #         [ "a", "b", "c" ].join("-")   #=> "a-b-c"
  # 
  def join(arg0, arg1, *rest)
  end

  def taguri
  end

  # ----------------------------------------------------------- Array#to_ary
  #      array.to_ary -> array
  # ------------------------------------------------------------------------
  #      Returns _self_.
  # 
  def to_ary
  end

  # ---------------------------------------------------------------- Array#-
  #      array - other_array    -> an_array
  # ------------------------------------------------------------------------
  #      Array Difference---Returns a new array that is a copy of the
  #      original array, removing any items that also appear in other_array.
  #      (If you need set-like behavior, see the library class Set.)
  # 
  #         [ 1, 1, 2, 2, 3, 3, 4, 5 ] - [ 1, 2, 4 ]  #=>  [ 3, 3, 5 ]
  # 
  def -(arg0)
  end

  # ------------------------------------------------------------- Array#eql?
  #      array.eql?(other)  -> true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _array_ and _other_ are the same object, or are
  #      both arrays with the same content.
  # 
  def eql?(arg0)
  end

  # ---------------------------------------------------------- Array#reverse
  #      array.reverse -> an_array
  # ------------------------------------------------------------------------
  #      Returns a new array containing _self_'s elements in reverse order.
  # 
  #         [ "a", "b", "c" ].reverse   #=> ["c", "b", "a"]
  #         [ 1 ].reverse               #=> [1]
  # 
  def reverse
  end

  # ---------------------------------------------------------- Array#indices
  #      array.indexes( i1, i2, ... iN )   -> an_array
  #      array.indices( i1, i2, ... iN )   -> an_array
  # ------------------------------------------------------------------------
  #      Deprecated; use +Array#values_at+.
  # 
  def indices(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- Array#nitems
  #      array.nitems -> int
  # ------------------------------------------------------------------------
  #      Returns the number of non-+nil+ elements in _self_. May be zero.
  # 
  #         [ 1, nil, 3, nil, 5 ].nitems   #=> 3
  # 
  def nitems
  end

  # ----------------------------------------------------------- Array#insert
  #      array.insert(index, obj...)  -> array
  # ------------------------------------------------------------------------
  #      Inserts the given values before the element with the given index
  #      (which may be negative).
  # 
  #         a = %w{ a b c d }
  #         a.insert(2, 99)         #=> ["a", "b", 99, "c", "d"]
  #         a.insert(-2, 1, 2, 3)   #=> ["a", "b", 99, "c", 1, 2, 3, "d"]
  # 
  def insert(arg0, arg1, *rest)
  end

  # --------------------------------------------------------- Array#compact!
  #      array.compact!    ->   array  or  nil
  # ------------------------------------------------------------------------
  #      Removes +nil+ elements from array. Returns +nil+ if no changes were
  #      made.
  # 
  #         [ "a", nil, "b", nil, "c" ].compact! #=> [ "a", "b", "c" ]
  #         [ "a", "b", "c" ].compact!           #=> nil
  # 
  def compact!
  end

  # ------------------------------------------------------------- Array#push
  #      array.push(obj, ... )   -> array
  # ------------------------------------------------------------------------
  #      Append---Pushes the given object(s) on to the end of this array.
  #      This expression returns the array itself, so several appends may be
  #      chained together.
  # 
  #         a = [ "a", "b", "c" ]
  #         a.push("d", "e", "f")
  #                 #=> ["a", "b", "c", "d", "e", "f"]
  # 
  def push(arg0, arg1, *rest)
  end

  # --------------------------------------------------------------- Array#[]
  #      array[index]                -> obj      or nil
  #      array[start, length]        -> an_array or nil
  #      array[range]                -> an_array or nil
  #      array.slice(index)          -> obj      or nil
  #      array.slice(start, length)  -> an_array or nil
  #      array.slice(range)          -> an_array or nil
  # ------------------------------------------------------------------------
  #      Element Reference---Returns the element at _index_, or returns a
  #      subarray starting at _start_ and continuing for _length_ elements,
  #      or returns a subarray specified by _range_. Negative indices count
  #      backward from the end of the array (-1 is the last element).
  #      Returns nil if the index (or starting index) are out of range.
  # 
  #         a = [ "a", "b", "c", "d", "e" ]
  #         a[2] +  a[0] + a[1]    #=> "cab"
  #         a[6]                   #=> nil
  #         a[1, 2]                #=> [ "b", "c" ]
  #         a[1..3]                #=> [ "b", "c", "d" ]
  #         a[4..7]                #=> [ "e" ]
  #         a[6..10]               #=> nil
  #         a[-3, 3]               #=> [ "c", "d", "e" ]
  #         # special cases
  #         a[5]                   #=> nil
  #         a[5, 1]                #=> []
  #         a[5..10]               #=> []
  # 
  def [](arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- Array#rassoc
  #      array.rassoc(key) -> an_array or nil
  # ------------------------------------------------------------------------
  #      Searches through the array whose elements are also arrays. Compares
  #      _key_ with the second element of each contained array using +==+.
  #      Returns the first contained array that matches. See also
  #      +Array#assoc+.
  # 
  #         a = [ [ 1, "one"], [2, "two"], [3, "three"], ["ii", "two"] ]
  #         a.rassoc("two")    #=> [2, "two"]
  #         a.rassoc("four")   #=> nil
  # 
  def rassoc(arg0)
  end

  # ---------------------------------------------------------- Array#inspect
  #      array.inspect  -> string
  # ------------------------------------------------------------------------
  #      Create a printable version of _array_.
  # 
  def inspect
  end

  # ---------------------------------------------------------- Array#replace
  #      array.replace(other_array)  -> array
  # ------------------------------------------------------------------------
  #      Replaces the contents of _self_ with the contents of _other_array_,
  #      truncating or expanding if necessary.
  # 
  #         a = [ "a", "b", "c", "d", "e" ]
  #         a.replace([ "x", "y", "z" ])   #=> ["x", "y", "z"]
  #         a                              #=> ["x", "y", "z"]
  # 
  def replace(arg0)
  end

  # -------------------------------------------------------------- Array#[]=
  #      array[index]         = obj                     ->  obj
  #      array[start, length] = obj or an_array or nil  ->  obj or an_array
  #      or nil
  #      array[range]         = obj or an_array or nil  ->  obj or an_array
  #      or nil
  # ------------------------------------------------------------------------
  #      Element Assignment---Sets the element at _index_, or replaces a
  #      subarray starting at _start_ and continuing for _length_ elements,
  #      or replaces a subarray specified by _range_. If indices are greater
  #      than the current capacity of the array, the array grows
  #      automatically. A negative indices will count backward from the end
  #      of the array. Inserts elements if _length_ is zero. If +nil+ is
  #      used in the second and third form, deletes elements from _self_. An
  #      +IndexError+ is raised if a negative index points past the
  #      beginning of the array. See also +Array#push+, and +Array#unshift+.
  # 
  #         a = Array.new
  #         a[4] = "4";                 #=> [nil, nil, nil, nil, "4"]
  #         a[0, 3] = [ 'a', 'b', 'c' ] #=> ["a", "b", "c", nil, "4"]
  #         a[1..2] = [ 1, 2 ]          #=> ["a", 1, 2, nil, "4"]
  #         a[0, 2] = "?"               #=> ["?", 2, nil, "4"]
  #         a[0..2] = "A"               #=> ["A", "4"]
  #         a[-1]   = "Z"               #=> ["A", "Z"]
  #         a[1..-1] = nil              #=> ["A"]
  # 
  def []=(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------------- Array#|
  #      array | other_array     ->  an_array
  # ------------------------------------------------------------------------
  #      Set Union---Returns a new array by joining this array with
  #      other_array, removing duplicates.
  # 
  #         [ "a", "b", "c" ] | [ "c", "d", "a" ]
  #                #=> [ "a", "b", "c", "d" ]
  # 
  def |(arg0)
  end

  def taguri=(arg0)
  end

  # ---------------------------------------------------------- Array#collect
  #      array.collect {|item| block }  -> an_array
  #      array.map     {|item| block }  -> an_array
  # ------------------------------------------------------------------------
  #      Invokes _block_ once for each element of _self_. Creates a new
  #      array containing the values returned by the block. See also
  #      +Enumerable#collect+.
  # 
  #         a = [ "a", "b", "c", "d" ]
  #         a.collect {|x| x + "!" }   #=> ["a!", "b!", "c!", "d!"]
  #         a                          #=> ["a", "b", "c", "d"]
  # 
  def collect
  end

  # -------------------------------------------------------- Array#delete_at
  #      array.delete_at(index)  -> obj or nil
  # ------------------------------------------------------------------------
  #      Deletes the element at the specified index, returning that element,
  #      or +nil+ if the index is out of range. See also +Array#slice!+.
  # 
  #         a = %w( ant bat cat dog )
  #         a.delete_at(2)    #=> "cat"
  #         a                 #=> ["ant", "bat", "dog"]
  #         a.delete_at(99)   #=> nil
  # 
  def delete_at(arg0)
  end

  # ---------------------------------------------------------- Array#flatten
  #      array.flatten -> an_array
  # ------------------------------------------------------------------------
  #      Returns a new array that is a one-dimensional flattening of this
  #      array (recursively). That is, for every element that is an array,
  #      extract its elements into the new array.
  # 
  #         s = [ 1, 2, 3 ]           #=> [1, 2, 3]
  #         t = [ 4, 5, 6, [7, 8] ]   #=> [4, 5, 6, [7, 8]]
  #         a = [ s, t, 9, 10 ]       #=> [[1, 2, 3], [4, 5, 6, [7, 8]], 9, 10]
  #         a.flatten                 #=> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10
  # 
  def flatten
  end

  # --------------------------------------------------------- Array#collect!
  #      array.collect! {|item| block }   ->   array
  #      array.map!     {|item| block }   ->   array
  # ------------------------------------------------------------------------
  #      Invokes the block once for each element of _self_, replacing the
  #      element with the value returned by _block_. See also
  #      +Enumerable#collect+.
  # 
  #         a = [ "a", "b", "c", "d" ]
  #         a.collect! {|x| x + "!" }
  #         a             #=>  [ "a!", "b!", "c!", "d!" ]
  # 
  def collect!
  end

  # --------------------------------------------------------------- Array#<<
  #      array << obj            -> array
  # ------------------------------------------------------------------------
  #      Append---Pushes the given object on to the end of this array. This
  #      expression returns the array itself, so several appends may be
  #      chained together.
  # 
  #         [ 1, 2 ] << "c" << "d" << [ 3, 4 ]
  #                 #=>  [ 1, 2, "c", "d", [ 3, 4 ] ]
  # 
  def <<(arg0)
  end

  # ---------------------------------------------------------- Array#frozen?
  #      array.frozen?  -> true or false
  # ------------------------------------------------------------------------
  #      Return +true+ if this array is frozen (or temporarily frozen while
  #      being sorted).
  # 
  def frozen?
  end

  # ----------------------------------------------------- Array#reverse_each
  #      array.reverse_each {|item| block } 
  # ------------------------------------------------------------------------
  #      Same as +Array#each+, but traverses _self_ in reverse order.
  # 
  #         a = [ "a", "b", "c" ]
  #         a.reverse_each {|x| print x, " " }
  # 
  #      produces:
  # 
  #         c b a
  # 
  def reverse_each
  end

  # ---------------------------------------------------------- Array#to_yaml
  #      to_yaml( opts = {} )
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ Array#first
  #      array.first   ->   obj or nil
  #      array.first(n) -> an_array
  # ------------------------------------------------------------------------
  #      Returns the first element, or the first +n+ elements, of the array.
  #      If the array is empty, the first form returns +nil+, and the second
  #      form returns an empty array.
  # 
  #         a = [ "q", "r", "s", "t" ]
  #         a.first    #=> "q"
  #         a.first(1) #=> ["q"]
  #         a.first(3) #=> ["q", "r", "s"]
  # 
  def first(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------- Array#fill
  #      array.fill(obj)                                -> array
  #      array.fill(obj, start [, length])              -> array
  #      array.fill(obj, range )                        -> array
  #      array.fill {|index| block }                    -> array
  #      array.fill(start [, length] ) {|index| block } -> array
  #      array.fill(range) {|index| block }             -> array
  # ------------------------------------------------------------------------
  #      The first three forms set the selected elements of _self_ (which
  #      may be the entire array) to _obj_. A _start_ of +nil+ is equivalent
  #      to zero. A _length_ of +nil+ is equivalent to _self.length_. The
  #      last three forms fill the array with the value of the block. The
  #      block is passed the absolute index of each element to be filled.
  # 
  #         a = [ "a", "b", "c", "d" ]
  #         a.fill("x")              #=> ["x", "x", "x", "x"]
  #         a.fill("z", 2, 2)        #=> ["x", "x", "z", "z"]
  #         a.fill("y", 0..1)        #=> ["y", "y", "z", "z"]
  #         a.fill {|i| i*i}         #=> [0, 1, 4, 9]
  #         a.fill(-2) {|i| i*i*i}   #=> [0, 1, 8, 27]
  # 
  def fill(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------- Array#hash
  #      array.hash   -> fixnum
  # ------------------------------------------------------------------------
  #      Compute a hash-code for this array. Two arrays with the same
  #      content will have the same hash code (and will compare using
  #      +eql?+).
  # 
  def hash
  end

  # ------------------------------------------------------------ Array#uniq!
  #      array.uniq! -> array or nil
  # ------------------------------------------------------------------------
  #      Removes duplicate elements from _self_. Returns +nil+ if no changes
  #      are made (that is, no duplicates are found).
  # 
  #         a = [ "a", "a", "b", "b", "c" ]
  #         a.uniq!   #=> ["a", "b", "c"]
  #         b = [ "a", "b", "c" ]
  #         b.uniq!   #=> nil
  # 
  def uniq!
  end

  # ----------------------------------------------------------- Array#select
  #      array.select {|item| block } -> an_array
  # ------------------------------------------------------------------------
  #      Invokes the block passing in successive elements from _array_,
  #      returning an array containing those elements for which the block
  #      returns a true value (equivalent to +Enumerable#select+).
  # 
  #         a = %w{ a b c d e f }
  #         a.select {|v| v =~ /[aeiou]/}   #=> ["a", "e"]
  # 
  def select
  end

  # ------------------------------------------------------------- Array#to_a
  #      array.to_a     -> array
  # ------------------------------------------------------------------------
  #      Returns _self_. If called on a subclass of Array, converts the
  #      receiver to an Array object.
  # 
  def to_a
  end

  # ---------------------------------------------------------- Array#reject!
  #      array.reject! {|item| block }  -> array or nil
  # ------------------------------------------------------------------------
  #      Equivalent to +Array#delete_if+, deleting elements from _self_ for
  #      which the block evaluates to true, but returns +nil+ if no changes
  #      were made. Also see +Enumerable#reject+.
  # 
  def reject!
  end

  # ------------------------------------------------------------ Array#index
  #      array.index(obj)   ->  int or nil
  # ------------------------------------------------------------------------
  #      Returns the index of the first object in _self_ such that is +==+
  #      to _obj_. Returns +nil+ if no match is found.
  # 
  #         a = [ "a", "b", "c" ]
  #         a.index("b")   #=> 1
  #         a.index("z")   #=> nil
  # 
  def index(arg0)
  end

  # ------------------------------------------------------------- Array#pack
  #      arr.pack ( aTemplateString ) -> aBinaryString
  # ------------------------------------------------------------------------
  #      Packs the contents of _arr_ into a binary sequence according to the
  #      directives in _aTemplateString_ (see the table below) Directives
  #      ``A,'' ``a,'' and ``Z'' may be followed by a count, which gives the
  #      width of the resulting field. The remaining directives also may
  #      take a count, indicating the number of array elements to convert.
  #      If the count is an asterisk (``+*+''), all remaining array elements
  #      will be converted. Any of the directives ``+sSiIlL+'' may be
  #      followed by an underscore (``+_+'') to use the underlying
  #      platform's native size for the specified type; otherwise, they use
  #      a platform-independent size. Spaces are ignored in the template
  #      string. See also +String#unpack+.
  # 
  #         a = [ "a", "b", "c" ]
  #         n = [ 65, 66, 67 ]
  #         a.pack("A3A3A3")   #=> "a  b  c  "
  #         a.pack("a3a3a3")   #=> "a\000\000b\000\000c\000\000"
  #         n.pack("ccc")      #=> "ABC"
  # 
  #      Directives for +pack+.
  # 
  #       Directive    Meaning
  #       ---------------------------------------------------------------
  #           @     |  Moves to absolute position
  #           A     |  ASCII string (space padded, count is width)
  #           a     |  ASCII string (null padded, count is width)
  #           B     |  Bit string (descending bit order)
  #           b     |  Bit string (ascending bit order)
  #           C     |  Unsigned char
  #           c     |  Char
  #           D, d  |  Double-precision float, native format
  #           E     |  Double-precision float, little-endian byte order
  #           e     |  Single-precision float, little-endian byte order
  #           F, f  |  Single-precision float, native format
  #           G     |  Double-precision float, network (big-endian) byte order
  #           g     |  Single-precision float, network (big-endian) byte order
  #           H     |  Hex string (high nibble first)
  #           h     |  Hex string (low nibble first)
  #           I     |  Unsigned integer
  #           i     |  Integer
  #           L     |  Unsigned long
  #           l     |  Long
  #           M     |  Quoted printable, MIME encoding (see RFC2045)
  #           m     |  Base64 encoded string
  #           N     |  Long, network (big-endian) byte order
  #           n     |  Short, network (big-endian) byte-order
  #           P     |  Pointer to a structure (fixed-length string)
  #           p     |  Pointer to a null-terminated string
  #           Q, q  |  64-bit number
  #           S     |  Unsigned short
  #           s     |  Short
  #           U     |  UTF-8
  #           u     |  UU-encoded string
  #           V     |  Long, little-endian byte order
  #           v     |  Short, little-endian byte order
  #           w     |  BER-compressed integer\fnm
  #           X     |  Back up a byte
  #           x     |  Null byte
  #           Z     |  Same as ``a'', except that null is added with *
  # 
  def pack(arg0)
  end

  # ---------------------------------------------------------- Array#unshift
  #      array.unshift(obj, ...)  -> array
  # ------------------------------------------------------------------------
  #      Prepends objects to the front of _array_. other elements up one.
  # 
  #         a = [ "b", "c", "d" ]
  #         a.unshift("a")   #=> ["a", "b", "c", "d"]
  #         a.unshift(1, 2)  #=> [ 1, 2, "a", "b", "c", "d"]
  # 
  def unshift(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- Array#zip
  #      array.zip(arg, ...)                   -> an_array
  #      array.zip(arg, ...) {| arr | block }  -> nil
  # ------------------------------------------------------------------------
  #      Converts any arguments to arrays, then merges elements of _self_
  #      with corresponding elements from each argument. This generates a
  #      sequence of +self.size+ _n_-element arrays, where _n_ is one more
  #      that the count of arguments. If the size of any argument is less
  #      than +enumObj.size+, +nil+ values are supplied. If a block given,
  #      it is invoked for each output array, otherwise an array of arrays
  #      is returned.
  # 
  #         a = [ 4, 5, 6 ]
  #         b = [ 7, 8, 9 ]
  #      
  #         [1,2,3].zip(a, b)      #=> [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
  #         [1,2].zip(a,b)         #=> [[1, 4, 7], [2, 5, 8]]
  #         a.zip([1,2],[8])       #=> [[4,1,8], [5,2,nil], [6,nil,nil]]
  # 
  def zip(arg0, arg1, *rest)
  end

  # ---------------------------------------------------------- Array#compact
  #      array.compact     ->  an_array
  # ------------------------------------------------------------------------
  #      Returns a copy of _self_ with all +nil+ elements removed.
  # 
  #         [ "a", nil, "b", nil, "c", nil ].compact
  #                           #=> [ "a", "b", "c" ]
  # 
  def compact
  end

  # -------------------------------------------------------- Array#transpose
  #      array.transpose -> an_array
  # ------------------------------------------------------------------------
  #      Assumes that _self_ is an array of arrays and transposes the rows
  #      and columns.
  # 
  #         a = [[1,2], [3,4], [5,6]]
  #         a.transpose   #=> [[1, 3, 5], [2, 4, 6]]
  # 
  def transpose
  end

  # --------------------------------------------------------------- Array#at
  #      array.at(index)   ->   obj  or nil
  # ------------------------------------------------------------------------
  #      Returns the element at _index_. A negative index counts from the
  #      end of _self_. Returns +nil+ if the index is out of range. See also
  #      +Array#[]+. (+Array#at+ is slightly faster than +Array#[]+, as it
  #      does not accept ranges and so on.)
  # 
  #         a = [ "a", "b", "c", "d", "e" ]
  #         a.at(0)     #=> "a"
  #         a.at(-1)    #=> "e"
  # 
  def at(arg0)
  end

  # -------------------------------------------------------------- Array#<=>
  #      array <=> other_array   ->  -1, 0, +1
  # ------------------------------------------------------------------------
  #      Comparison---Returns an integer (-1, 0, or +1) if this array is
  #      less than, equal to, or greater than other_array. Each object in
  #      each array is compared (using <=>). If any value isn't equal, then
  #      that inequality is the return value. If all the values found are
  #      equal, then the return is based on a comparison of the array
  #      lengths. Thus, two arrays are ``equal'' according to +Array#<=>+ if
  #      and only if they have the same length and the value of each element
  #      is equal to the value of the corresponding element in the other
  #      array.
  # 
  #         [ "a", "a", "c" ]    <=> [ "a", "b", "c" ]   #=> -1
  #         [ 1, 2, 3, 4, 5, 6 ] <=> [ 1, 2 ]            #=> +1
  # 
  def <=>(arg0)
  end

  # -------------------------------------------------------------- Array#pop
  #      array.pop  -> obj or nil
  # ------------------------------------------------------------------------
  #      Removes the last element from _self_ and returns it, or +nil+ if
  #      the array is empty.
  # 
  #         a = [ "a", "m", "z" ]
  #         a.pop   #=> "z"
  #         a       #=> ["a", "m"]
  # 
  def pop
  end

  # --------------------------------------------------------------- Array#==
  #      array == other_array   ->   bool
  # ------------------------------------------------------------------------
  #      Equality---Two arrays are equal if they contain the same number of
  #      elements and if each element is equal to (according to Object.==)
  #      the corresponding element in the other array.
  # 
  #         [ "a", "c" ]    == [ "a", "c", 7 ]     #=> false
  #         [ "a", "c", 7 ] == [ "a", "c", 7 ]     #=> true
  #         [ "a", "c", 7 ] == [ "a", "d", "f" ]   #=> false
  # 
  def ==(arg0)
  end

  # ----------------------------------------------------------- Array#slice!
  #      array.slice!(index)         -> obj or nil
  #      array.slice!(start, length) -> sub_array or nil
  #      array.slice!(range)         -> sub_array or nil 
  # ------------------------------------------------------------------------
  #      Deletes the element(s) given by an index (optionally with a length)
  #      or by a range. Returns the deleted object, subarray, or +nil+ if
  #      the index is out of range. Equivalent to:
  # 
  #         def slice!(*args)
  #           result = self[*args]
  #           self[*args] = nil
  #           result
  #         end
  #      
  #         a = [ "a", "b", "c" ]
  #         a.slice!(1)     #=> "b"
  #         a               #=> ["a", "c"]
  #         a.slice!(-1)    #=> "c"
  #         a               #=> ["a"]
  #         a.slice!(100)   #=> nil
  #         a               #=> ["a"]
  # 
  def slice!(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- Array#length
  #      array.length -> int
  # ------------------------------------------------------------------------
  #      Returns the number of elements in _self_. May be zero.
  # 
  #         [ 1, 2, 3, 4, 5 ].length   #=> 5
  # 
  # 
  #      (also known as size)
  def length
  end

  # ------------------------------------------------------------- Array#uniq
  #      array.uniq   -> an_array
  # ------------------------------------------------------------------------
  #      Returns a new array by removing duplicate values in _self_.
  # 
  #         a = [ "a", "a", "b", "b", "c" ]
  #         a.uniq   #=> ["a", "b", "c"]
  # 
  def uniq
  end

  # -------------------------------------------------------- Array#delete_if
  #      array.delete_if {|item| block }  -> array
  # ------------------------------------------------------------------------
  #      Deletes every element of _self_ for which _block_ evaluates to
  #      +true+.
  # 
  #         a = [ "a", "b", "c" ]
  #         a.delete_if {|x| x >= "b" }   #=> ["a"]
  # 
  def delete_if
  end

  # ----------------------------------------------------------- Array#delete
  #      array.delete(obj)            -> obj or nil 
  #      array.delete(obj) { block }  -> obj or nil
  # ------------------------------------------------------------------------
  #      Deletes items from _self_ that are equal to _obj_. If the item is
  #      not found, returns +nil+. If the optional code block is given,
  #      returns the result of _block_ if the item is not found.
  # 
  #         a = [ "a", "b", "b", "b", "c" ]
  #         a.delete("b")                   #=> "b"
  #         a                               #=> ["a", "c"]
  #         a.delete("z")                   #=> nil
  #         a.delete("z") { "not found" }   #=> "not found"
  # 
  def delete(arg0)
  end

  # -------------------------------------------------------------- Array#map
  #      array.collect {|item| block }  -> an_array
  #      array.map     {|item| block }  -> an_array
  # ------------------------------------------------------------------------
  #      Invokes _block_ once for each element of _self_. Creates a new
  #      array containing the values returned by the block. See also
  #      +Enumerable#collect+.
  # 
  #         a = [ "a", "b", "c", "d" ]
  #         a.collect {|x| x + "!" }   #=> ["a!", "b!", "c!", "d!"]
  #         a                          #=> ["a", "b", "c", "d"]
  # 
  def map
  end

end
