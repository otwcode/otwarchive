# Add some nice to haves from ActiveSupport

module Kernel
  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end
end

module HashExtensions
  def reverse_merge(other_hash)
    other_hash.merge(self)
  end

  def reverse_merge!(other_hash)
    replace(reverse_merge(other_hash))
  end
end

module ArrayExtensions
  # Converts the array to comma-seperated sentence where the last element is joined by the connector word. Options:
  # * <tt>:connector</tt>: The word used to join the last element in arrays with two or more elements (default: "and")
  # * <tt>:skip_last_comma</tt>: Set to true to return "a, b and c" instead of "a, b, and c".
  def to_sentence(options = {})
    options.reverse_merge! :connector => 'and', :skip_last_comma => false
    
    case length
    	when 0
    		""
      when 1
        self[0]
      when 2
        "#{self[0]} #{options[:connector]} #{self[1]}"
      else
        "#{self[0...-1].join(', ')}#{options[:skip_last_comma] ? '' : ','} #{options[:connector]} #{self[-1]}"
    end
  end
  
end

Array.send(:include, ArrayExtensions) unless Array.respond_to?(:to_sentence)
Hash.send(:include, HashExtensions) unless Hash.respond_to?(:reverse_merge) && Hash.respond_to?(:reverse_merge!)