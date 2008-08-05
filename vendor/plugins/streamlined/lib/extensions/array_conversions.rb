module ArrayConversions
  def to_2d_array
    if is_a?(Array) && !first.is_a?(Array)
      collect { |e| [e, e] }
    elsif is_a?(Hash)
      collect { |k,v| [k, v] }
    else
      self
    end
  end
end

Hash.send(:include, ArrayConversions)
Array.send(:include, ArrayConversions)