# Hook up core extenstions (need to define them as main level, hence 
# the :: prefix)
class ::String # :nodoc: 
  include Globalize::CoreExtensions::String
end

class ::Symbol # :nodoc:  
  include Globalize::CoreExtensions::Symbol
end

class ::Object # :nodoc:  
  include Globalize::CoreExtensions::Object
end

class ::Fixnum # :nodoc:
  include Globalize::CoreExtensions::Integer 
end

class ::Bignum # :nodoc:
  include Globalize::CoreExtensions::Integer
end

class ::Float # :nodoc:
  include Globalize::CoreExtensions::Float  
end

class ::Time # :nodoc:
  include Globalize::CoreExtensions::Time
end

class ::Date # :nodoc:
  include Globalize::CoreExtensions::Date
end
