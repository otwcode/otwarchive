
class Array
  # Only flatten the first level of an array
  def _flatten_once
    self.inject([]) do |set, element| 
      set + Array(element)
    end
  end
  
  def _sum
    self.inject(0) do |acc, element|
      acc + element
    end
  end
end

class Object
  def _metaclass 
    class << self
      self
    end
  end
  
  def _deep_dup
    # Cause Ruby's clone/dup sucks.
    Marshal.load(Marshal.dump(self))
  end
end

#class HashWithIndifferentAccess
#  # Returns a regular Hash with all string keys. Much faster
#  # than HWIA#merge.
#  def _fast_merge(right)
#    left = Hash[self]
#    left.merge!(self.class.new(right))
#  end
#end

class Hash
  def _coerce_basic_types
    # XXX To remove
    Hash[*self.map do |key, value|
      [key.to_s,
        if value.respond_to?(:to_i) && value.to_i.to_s == value
          value.to_i
        elsif value == ""
          nil
        else
          value
        end]
      end._flatten_once]
  end
  
  # Delete by multiple keys
  def _delete(*args)
    args.map do |key|
      self.delete key
    end    
  end
  
  # Convert a hash to a Sphinx-style conf string
  def _to_conf_string(section = nil)
    inner = self.map do |key, value|
      "  #{key} = #{value}"
    end.join("\n")
    section ? "#{section} {\n#{inner}\n}\n" : inner
  end
  
  unless Hash.new.respond_to? :except
    # Rails 1.2.6 compatibility
    def except(*keys)
      rejected = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
      reject { |key,| rejected.include?(key) }
    end
    def except!(*keys)
      replace(except(*keys))
    end
  end 
  
end

### Filter type coercion methods

class String
  # XXX Not used enough to justify such a strange abstraction
  def _to_numeric
    zeroless = self.squeeze(" ").strip.sub(/^0+(\d)/, '\1')
    zeroless.sub!(/(\...*?)0+$/, '\1')
    if zeroless.to_i.to_s == zeroless
      zeroless.to_i
    elsif zeroless.to_f.to_s == zeroless
      zeroless.to_f
    elsif date = Chronic.parse(self.gsub(/(\d)([^\d\:\s])/, '\1 \2')) # Improve Chronic's flexibility a little
      date.to_i
    else
      raise Ultrasphinx::UsageError, "#{self.inspect} could not be coerced into a numeric value"
    end
  end
  
  def _interpolate(value)
    self.sub('?', value)
  end
end

module Ultrasphinx::NumericSelf
  def _to_numeric; self; end
end

module Ultrasphinx::DateSelf
  def _to_numeric; self.to_i; end
end

class Fixnum; include Ultrasphinx::NumericSelf; end
class Bignum; include Ultrasphinx::NumericSelf; end
class Float; include Ultrasphinx::NumericSelf; end
class Date; include Ultrasphinx::DateSelf; end
class Time; include Ultrasphinx::DateSelf; end
