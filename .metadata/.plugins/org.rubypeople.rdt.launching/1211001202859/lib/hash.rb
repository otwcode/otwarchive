=begin
------------------------------------------------------------ Class: Hash
     A +Hash+ is a collection of key-value pairs. It is similar to an
     +Array+, except that indexing is done via arbitrary keys of any
     object type, not an integer index. The order in which you traverse
     a hash by either key or value may seem arbitrary, and will
     generally not be in the insertion order.

     Hashes have a _default value_ that is returned when accessing keys
     that do not exist in the hash. By default, that value is +nil+.

     +Hash+ uses +key.eql?+ to test keys for equality. If you need to
     use instances of your own classes as keys in a +Hash+, it is
     recommended that you define both the +eql?+ and +hash+ methods. The
     +hash+ method must have the property that +a.eql?(b)+ implies
     +a.hash == b.hash+.

       class MyClass
         attr_reader :str
         def initialize(str)
           @str = str
         end
         def eql?(o)
           o.is_a?(MyClass) && str == o.str
         end
         def hash
           @str.hash
         end
       end
     
       a = MyClass.new("some string")
       b = MyClass.new("some string")
       a.eql? b  #=> true
     
       h = {}
     
       h[a] = 1
       h[a]      #=> 1
       h[b]      #=> 1
     
       h[b] = 2
       h[a]      #=> 2
       h[b]      #=> 2

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
     ==, [], []=, clear, default, default=, default_proc, delete,
     delete_if, each, each_key, each_pair, each_value, empty?, fetch,
     has_key?, has_value?, include?, index, indexes, indices,
     initialize_copy, inspect, invert, key?, keys, length, member?,
     merge, merge!, pretty_print, pretty_print_cycle, rehash, reject,
     reject!, replace, select, shift, size, sort, store, to_a, to_hash,
     to_s, to_yaml, update, value?, values, values_at, yaml_initialize

=end
class Hash < Object
  include Enumerable

  # --------------------------------------------------------------- Hash::[]
  #      Hash[ [key =>|, value]* ]   => hash
  # ------------------------------------------------------------------------
  #      Creates a new hash populated with the given objects. Equivalent to
  #      the literal +{ _key_, _value_, ... }+. Keys and values occur in
  #      pairs, so there must be an even number of arguments.
  # 
  #         Hash["a", 100, "b", 200]       #=> {"a"=>100, "b"=>200}
  #         Hash["a" => 100, "b" => 200]   #=> {"a"=>100, "b"=>200}
  #         { "a" => 100, "b" => 200 }     #=> {"a"=>100, "b"=>200}
  # 
  def self.[](arg0, arg1, *rest)
  end

  def self.yaml_tag_subclasses?
  end

  # ---------------------------------------------------------- Hash#default=
  #      hsh.default = obj     => hsh
  # ------------------------------------------------------------------------
  #      Sets the default value, the value returned for a key that does not
  #      exist in the hash. It is not possible to set the a default to a
  #      +Proc+ that will be executed on each key lookup.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.default = "Go fish"
  #         h["a"]     #=> 100
  #         h["z"]     #=> "Go fish"
  #         # This doesn't do what you might hope...
  #         h.default = proc do |hash, key|
  #           hash[key] = key + key
  #         end
  #         h[2]       #=> #<Proc:0x401b3948@-:6>
  #         h["cat"]   #=> #<Proc:0x401b3948@-:6>
  # 
  def default=(arg0)
  end

  # ------------------------------------------------------------- Hash#index
  #      hsh.index(value)    => key
  # ------------------------------------------------------------------------
  #      Returns the key for a given value. If not found, returns +nil+.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.index(200)   #=> "b"
  #         h.index(999)   #=> nil
  # 
  def index(arg0)
  end

  # ------------------------------------------------------------- Hash#clear
  #      hsh.clear -> hsh
  # ------------------------------------------------------------------------
  #      Removes all key-value pairs from _hsh_.
  # 
  #         h = { "a" => 100, "b" => 200 }   #=> {"a"=>100, "b"=>200}
  #         h.clear                          #=> {}
  # 
  def clear
  end

  # ------------------------------------------------------------ Hash#invert
  #      hsh.invert -> aHash
  # ------------------------------------------------------------------------
  #      Returns a new hash created by using _hsh_'s values as keys, and the
  #      keys as values.
  # 
  #         h = { "n" => 100, "m" => 100, "y" => 300, "d" => 200, "a" => 0 }
  #         h.invert   #=> {0=>"a", 100=>"n", 200=>"d", 300=>"y"}
  # 
  def invert
  end

  # ------------------------------------------------------------ Hash#merge!
  #      hsh.merge!(other_hash)                                 => hsh
  #      hsh.update(other_hash)                                 => hsh
  #      hsh.merge!(other_hash){|key, oldval, newval| block}    => hsh
  #      hsh.update(other_hash){|key, oldval, newval| block}    => hsh
  # ------------------------------------------------------------------------
  #      Adds the contents of _other_hash_ to _hsh_, overwriting entries
  #      with duplicate keys with those from _other_hash_.
  # 
  #         h1 = { "a" => 100, "b" => 200 }
  #         h2 = { "b" => 254, "c" => 300 }
  #         h1.merge!(h2)   #=> {"a"=>100, "b"=>254, "c"=>300}
  # 
  def merge!(arg0)
  end

  # -------------------------------------------------------------- Hash#key?
  #      hsh.has_key?(key)    => true or false
  #      hsh.include?(key)    => true or false
  #      hsh.key?(key)        => true or false
  #      hsh.member?(key)     => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the given key is present in _hsh_.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.has_key?("a")   #=> true
  #         h.has_key?("z")   #=> false
  # 
  def key?(arg0)
  end

  # -------------------------------------------------------- Hash#each_value
  #      hsh.each_value {| value | block } -> hsh
  # ------------------------------------------------------------------------
  #      Calls _block_ once for each key in _hsh_, passing the value as a
  #      parameter.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.each_value {|value| puts value }
  # 
  #      _produces:_
  # 
  #         100
  #         200
  # 
  def each_value
  end

  # ----------------------------------------------------------- Hash#reject!
  #      hsh.reject! {| key, value | block }  -> hsh or nil
  # ------------------------------------------------------------------------
  #      Equivalent to +Hash#delete_if+, but returns +nil+ if no changes
  #      were made.
  # 
  def reject!
  end

  # ------------------------------------------------------------ Hash#rehash
  #      hsh.rehash -> hsh
  # ------------------------------------------------------------------------
  #      Rebuilds the hash based on the current hash values for each key. If
  #      values of key objects have changed since they were inserted, this
  #      method will reindex _hsh_. If +Hash#rehash+ is called while an
  #      iterator is traversing the hash, an +IndexError+ will be raised in
  #      the iterator.
  # 
  #         a = [ "a", "b" ]
  #         c = [ "c", "d" ]
  #         h = { a => 100, c => 300 }
  #         h[a]       #=> 100
  #         a[0] = "z"
  #         h[a]       #=> nil
  #         h.rehash   #=> {["z", "b"]=>100, ["c", "d"]=>300}
  #         h[a]       #=> 100
  # 
  def rehash
  end

  # -------------------------------------------------------------- Hash#to_s
  #      hsh.to_s   => string
  # ------------------------------------------------------------------------
  #      Converts _hsh_ to a string by converting the hash to an array of
  #      +[+ _key, value_ +]+ pairs and then converting that array to a
  #      string using +Array#join+ with the default separator.
  # 
  #         h = { "c" => 300, "a" => 100, "d" => 400, "c" => 300  }
  #         h.to_s   #=> "a100c300d400"
  # 
  def to_s
  end

  # ---------------------------------------------------------------- Hash#==
  #      hsh == other_hash    => true or false
  # ------------------------------------------------------------------------
  #      Equality---Two hashes are equal if they each contain the same
  #      number of keys and if each key-value pair is equal to (according to
  #      +Object#==+) the corresponding elements in the other hash.
  # 
  #         h1 = { "a" => 1, "c" => 2 }
  #         h2 = { 7 => 35, "c" => 2, "a" => 1 }
  #         h3 = { "a" => 1, "c" => 2, 7 => 35 }
  #         h4 = { "a" => 1, "d" => 2, "f" => 35 }
  #         h1 == h2   #=> false
  #         h2 == h3   #=> true
  #         h3 == h4   #=> false
  # 
  def ==(arg0)
  end

  # ---------------------------------------------------------------- Hash#[]
  #      hsh[key]    =>  value
  # ------------------------------------------------------------------------
  #      Element Reference---Retrieves the _value_ object corresponding to
  #      the _key_ object. If not found, returns the a default value (see
  #      +Hash::new+ for details).
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h["a"]   #=> 100
  #         h["c"]   #=> nil
  # 
  def [](arg0)
  end

  # ------------------------------------------------------------- Hash#fetch
  #      hsh.fetch(key [, default] )       => obj
  #      hsh.fetch(key) {| key | block }   => obj
  # ------------------------------------------------------------------------
  #      Returns a value from the hash for the given key. If the key can't
  #      be found, there are several options: With no other arguments, it
  #      will raise an +IndexError+ exception; if _default_ is given, then
  #      that will be returned; if the optional code block is specified,
  #      then that will be run and its result returned.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.fetch("a")                            #=> 100
  #         h.fetch("z", "go fish")                 #=> "go fish"
  #         h.fetch("z") { |el| "go fish, #{el}"}   #=> "go fish, z"
  # 
  #      The following example shows that an exception is raised if the key
  #      is not found and a default value is not supplied.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.fetch("z")
  # 
  #      _produces:_
  # 
  #         prog.rb:2:in `fetch': key not found (IndexError)
  #          from prog.rb:2
  # 
  def fetch(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- Hash#size
  #      hsh.length    =>  fixnum
  #      hsh.size      =>  fixnum
  # ------------------------------------------------------------------------
  #      Returns the number of key-value pairs in the hash.
  # 
  #         h = { "d" => 100, "a" => 200, "v" => 300, "e" => 400 }
  #         h.length        #=> 4
  #         h.delete("a")   #=> 200
  #         h.length        #=> 3
  # 
  def size
  end

  # -------------------------------------------------------------- Hash#each
  #      hsh.each {| key, value | block } -> hsh
  # ------------------------------------------------------------------------
  #      Calls _block_ once for each key in _hsh_, passing the key and value
  #      to the block as a two-element array. Because of the assignment
  #      semantics of block parameters, these elements will be split out if
  #      the block has two formal parameters. Also see +Hash.each_pair+,
  #      which will be marginally more efficient for blocks with two
  #      parameters.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.each {|key, value| puts "#{key} is #{value}" }
  # 
  #      _produces:_
  # 
  #         a is 100
  #         b is 200
  # 
  def each
  end

  # -------------------------------------------------------------- Hash#keys
  #      hsh.keys    => array
  # ------------------------------------------------------------------------
  #      Returns a new array populated with the keys from this hash. See
  #      also +Hash#values+.
  # 
  #         h = { "a" => 100, "b" => 200, "c" => 300, "d" => 400 }
  #         h.keys   #=> ["a", "b", "c", "d"]
  # 
  def keys
  end

  # ------------------------------------------------------------- Hash#merge
  #      hsh.merge(other_hash)                              -> a_hash
  #      hsh.merge(other_hash){|key, oldval, newval| block} -> a_hash
  # ------------------------------------------------------------------------
  #      Returns a new hash containing the contents of _other_hash_ and the
  #      contents of _hsh_, overwriting entries in _hsh_ with duplicate keys
  #      with those from _other_hash_.
  # 
  #         h1 = { "a" => 100, "b" => 200 }
  #         h2 = { "b" => 254, "c" => 300 }
  #         h1.merge(h2)   #=> {"a"=>100, "b"=>254, "c"=>300}
  #         h1             #=> {"a"=>100, "b"=>200}
  # 
  def merge(arg0)
  end

  # ---------------------------------------------------------- Hash#include?
  #      hsh.has_key?(key)    => true or false
  #      hsh.include?(key)    => true or false
  #      hsh.key?(key)        => true or false
  #      hsh.member?(key)     => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the given key is present in _hsh_.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.has_key?("a")   #=> true
  #         h.has_key?("z")   #=> false
  # 
  def include?(arg0)
  end

  # -------------------------------------------------------- Hash#has_value?
  #      hsh.has_value?(value)    => true or false
  #      hsh.value?(value)        => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the given value is present for some key in _hsh_.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.has_value?(100)   #=> true
  #         h.has_value?(999)   #=> false
  # 
  def has_value?(arg0)
  end

  def taguri=(arg0)
  end

  # --------------------------------------------------- Hash#yaml_initialize
  #      yaml_initialize( tag, val )
  # ------------------------------------------------------------------------
  #      (no description...)
  def yaml_initialize(arg0, arg1)
  end

  # --------------------------------------------------------------- Hash#[]=
  #      hsh[key] = value        => value
  #      hsh.store(key, value)   => value
  # ------------------------------------------------------------------------
  #      Element Assignment---Associates the value given by _value_ with the
  #      key given by _key_. _key_ should not have its value changed while
  #      it is in use as a key (a +String+ passed as a key will be
  #      duplicated and frozen).
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h["a"] = 9
  #         h["c"] = 4
  #         h   #=> {"a"=>9, "b"=>200, "c"=>4}
  # 
  def []=(arg0, arg1)
  end

  # ------------------------------------------------------------ Hash#values
  #      hsh.values    => array
  # ------------------------------------------------------------------------
  #      Returns a new array populated with the values from _hsh_. See also
  #      +Hash#keys+.
  # 
  #         h = { "a" => 100, "b" => 200, "c" => 300 }
  #         h.values   #=> [100, 200, 300]
  # 
  def values
  end

  # ------------------------------------------------------ Hash#default_proc
  #      hsh.default_proc -> anObject
  # ------------------------------------------------------------------------
  #      If +Hash::new+ was invoked with a block, return that block,
  #      otherwise return +nil+.
  # 
  #         h = Hash.new {|h,k| h[k] = k*k }   #=> {}
  #         p = h.default_proc                 #=> #<Proc:0x401b3d08@-:1>
  #         a = []                             #=> []
  #         p.call(a, 2)
  #         a                                  #=> [nil, nil, 4]
  # 
  def default_proc
  end

  # -------------------------------------------------------------- Hash#sort
  #      hsh.sort                    => array 
  #      hsh.sort {| a, b | block }  => array 
  # ------------------------------------------------------------------------
  #      Converts _hsh_ to a nested array of +[+ _key, value_ +]+ arrays and
  #      sorts it, using +Array#sort+.
  # 
  #         h = { "a" => 20, "b" => 30, "c" => 10  }
  #         h.sort                       #=> [["a", 20], ["b", 30], ["c", 10]]
  #         h.sort {|a,b| a[1]<=>b[1]}   #=> [["c", 10], ["a", 20], ["b", 30]]
  # 
  def sort
  end

  # --------------------------------------------------------- Hash#values_at
  #      hsh.values_at(key, ...)   => array
  # ------------------------------------------------------------------------
  #      Return an array containing the values associated with the given
  #      keys. Also see +Hash.select+.
  # 
  #        h = { "cat" => "feline", "dog" => "canine", "cow" => "bovine" }
  #        h.values_at("cow", "cat")  #=> ["bovine", "feline"]
  # 
  def values_at(arg0, arg1, *rest)
  end

  # -------------------------------------------------------------- Hash#to_a
  #      hsh.to_a -> array
  # ------------------------------------------------------------------------
  #      Converts _hsh_ to a nested array of +[+ _key, value_ +]+ arrays.
  # 
  #         h = { "c" => 300, "a" => 100, "d" => 400, "c" => 300  }
  #         h.to_a   #=> [["a", 100], ["c", 300], ["d", 400]]
  # 
  def to_a
  end

  # ----------------------------------------------------------- Hash#indices
  #      hsh.indexes(key, ...)    => array
  #      hsh.indices(key, ...)    => array
  # ------------------------------------------------------------------------
  #      Deprecated in favor of +Hash#select+.
  # 
  def indices(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ Hash#length
  #      hsh.length    =>  fixnum
  #      hsh.size      =>  fixnum
  # ------------------------------------------------------------------------
  #      Returns the number of key-value pairs in the hash.
  # 
  #         h = { "d" => 100, "a" => 200, "v" => 300, "e" => 400 }
  #         h.length        #=> 4
  #         h.delete("a")   #=> 200
  #         h.length        #=> 3
  # 
  def length
  end

  # ------------------------------------------------------------ Hash#empty?
  #      hsh.empty?    => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if _hsh_ contains no key-value pairs.
  # 
  #         {}.empty?   #=> true
  # 
  def empty?
  end

  # ------------------------------------------------------------ Hash#reject
  #      hsh.reject {| key, value | block }  -> a_hash
  # ------------------------------------------------------------------------
  #      Same as +Hash#delete_if+, but works on (and returns) a copy of the
  #      _hsh_. Equivalent to +_hsh_.dup.delete_if+.
  # 
  def reject
  end

  # ----------------------------------------------------------- Hash#replace
  #      hsh.replace(other_hash) -> hsh
  # ------------------------------------------------------------------------
  #      Replaces the contents of _hsh_ with the contents of _other_hash_.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.replace({ "c" => 300, "d" => 400 })   #=> {"c"=>300, "d"=>400}
  # 
  def replace(arg0)
  end

  # ---------------------------------------------------------- Hash#has_key?
  #      hsh.has_key?(key)    => true or false
  #      hsh.include?(key)    => true or false
  #      hsh.key?(key)        => true or false
  #      hsh.member?(key)     => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the given key is present in _hsh_.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.has_key?("a")   #=> true
  #         h.has_key?("z")   #=> false
  # 
  def has_key?(arg0)
  end

  # --------------------------------------------------------- Hash#each_pair
  #      hsh.each_pair {| key_value_array | block } -> hsh
  # ------------------------------------------------------------------------
  #      Calls _block_ once for each key in _hsh_, passing the key and value
  #      as parameters.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.each_pair {|key, value| puts "#{key} is #{value}" }
  # 
  #      _produces:_
  # 
  #         a is 100
  #         b is 200
  # 
  def each_pair
  end

  # ----------------------------------------------------------- Hash#member?
  #      hsh.has_key?(key)    => true or false
  #      hsh.include?(key)    => true or false
  #      hsh.key?(key)        => true or false
  #      hsh.member?(key)     => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the given key is present in _hsh_.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.has_key?("a")   #=> true
  #         h.has_key?("z")   #=> false
  # 
  def member?(arg0)
  end

  # ------------------------------------------------------------- Hash#store
  #      hsh[key] = value        => value
  #      hsh.store(key, value)   => value
  # ------------------------------------------------------------------------
  #      Element Assignment---Associates the value given by _value_ with the
  #      key given by _key_. _key_ should not have its value changed while
  #      it is in use as a key (a +String+ passed as a key will be
  #      duplicated and frozen).
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h["a"] = 9
  #         h["c"] = 4
  #         h   #=> {"a"=>9, "b"=>200, "c"=>4}
  # 
  def store(arg0, arg1)
  end

  # ----------------------------------------------------------- Hash#default
  #      hsh.default(key=nil)   => obj
  # ------------------------------------------------------------------------
  #      Returns the default value, the value that would be returned by
  #      _hsh_[_key_] if _key_ did not exist in _hsh_. See also +Hash::new+
  #      and +Hash#default=+.
  # 
  #         h = Hash.new                            #=> {}
  #         h.default                               #=> nil
  #         h.default(2)                            #=> nil
  #      
  #         h = Hash.new("cat")                     #=> {}
  #         h.default                               #=> "cat"
  #         h.default(2)                            #=> "cat"
  #      
  #         h = Hash.new {|h,k| h[k] = k.to_i*10}   #=> {}
  #         h.default                               #=> 0
  #         h.default(2)                            #=> 20
  # 
  def default(arg0, arg1, *rest)
  end

  # ----------------------------------------------------------- Hash#indexes
  #      hsh.indexes(key, ...)    => array
  #      hsh.indices(key, ...)    => array
  # ------------------------------------------------------------------------
  #      Deprecated in favor of +Hash#select+.
  # 
  def indexes(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ Hash#select
  #      hsh.select {|key, value| block}   => array
  # ------------------------------------------------------------------------
  #      Returns a new array consisting of +[key,value]+ pairs for which the
  #      block returns true. Also see +Hash.values_at+.
  # 
  #         h = { "a" => 100, "b" => 200, "c" => 300 }
  #         h.select {|k,v| k > "a"}  #=> [["b", 200], ["c", 300]]
  #         h.select {|k,v| v < 200}  #=> [["a", 100]]
  # 
  def select(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ Hash#update
  #      hsh.merge!(other_hash)                                 => hsh
  #      hsh.update(other_hash)                                 => hsh
  #      hsh.merge!(other_hash){|key, oldval, newval| block}    => hsh
  #      hsh.update(other_hash){|key, oldval, newval| block}    => hsh
  # ------------------------------------------------------------------------
  #      Adds the contents of _other_hash_ to _hsh_, overwriting entries
  #      with duplicate keys with those from _other_hash_.
  # 
  #         h1 = { "a" => 100, "b" => 200 }
  #         h2 = { "b" => 254, "c" => 300 }
  #         h1.merge!(h2)   #=> {"a"=>100, "b"=>254, "c"=>300}
  # 
  def update(arg0)
  end

  # ---------------------------------------------------------- Hash#each_key
  #      hsh.each_key {| key | block } -> hsh
  # ------------------------------------------------------------------------
  #      Calls _block_ once for each key in _hsh_, passing the key as a
  #      parameter.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.each_key {|key| puts key }
  # 
  #      _produces:_
  # 
  #         a
  #         b
  # 
  def each_key
  end

  # ------------------------------------------------------------- Hash#shift
  #      hsh.shift -> anArray or obj
  # ------------------------------------------------------------------------
  #      Removes a key-value pair from _hsh_ and returns it as the two-item
  #      array +[+ _key, value_ +]+, or the hash's default value if the hash
  #      is empty.
  # 
  #         h = { 1 => "a", 2 => "b", 3 => "c" }
  #         h.shift   #=> [1, "a"]
  #         h         #=> {2=>"b", 3=>"c"}
  # 
  def shift
  end

  # ------------------------------------------------------------ Hash#delete
  #      hsh.delete(key)                   => value
  #      hsh.delete(key) {| key | block }  => value
  # ------------------------------------------------------------------------
  #      Deletes and returns a key-value pair from _hsh_ whose key is equal
  #      to _key_. If the key is not found, returns the _default value_. If
  #      the optional code block is given and the key is not found, pass in
  #      the key and return the result of _block_.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.delete("a")                              #=> 100
  #         h.delete("z")                              #=> nil
  #         h.delete("z") { |el| "#{el} not found" }   #=> "z not found"
  # 
  def delete(arg0)
  end

  # --------------------------------------------------------- Hash#delete_if
  #      hsh.delete_if {| key, value | block }  -> hsh
  # ------------------------------------------------------------------------
  #      Deletes every key-value pair from _hsh_ for which _block_ evaluates
  #      to +true+.
  # 
  #         h = { "a" => 100, "b" => 200, "c" => 300 }
  #         h.delete_if {|key, value| key >= "b" }   #=> {"a"=>100}
  # 
  def delete_if
  end

  # ----------------------------------------------------------- Hash#to_hash
  #      hsh.to_hash   => hsh
  # ------------------------------------------------------------------------
  #      Returns _self_.
  # 
  def to_hash
  end

  # ----------------------------------------------------------- Hash#inspect
  #      hsh.inspect  => string
  # ------------------------------------------------------------------------
  #      Return the contents of this hash as a string.
  # 
  def inspect
  end

  # ------------------------------------------------------------ Hash#value?
  #      hsh.has_value?(value)    => true or false
  #      hsh.value?(value)        => true or false
  # ------------------------------------------------------------------------
  #      Returns +true+ if the given value is present for some key in _hsh_.
  # 
  #         h = { "a" => 100, "b" => 200 }
  #         h.has_value?(100)   #=> true
  #         h.has_value?(999)   #=> false
  # 
  def value?(arg0)
  end

  def taguri
  end

  # ----------------------------------------------------------- Hash#to_yaml
  #      to_yaml( opts = {} )
  # ------------------------------------------------------------------------
  #      (no description...)
  def to_yaml(arg0, arg1, *rest)
  end

end
