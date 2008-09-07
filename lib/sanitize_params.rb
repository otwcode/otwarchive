# grabbed from http://code.google.com/p/sanitizeparams/ and tweaked
module SanitizeParams

  def get_white_list_sanitizer
    @white_list_sanitizer = HTML::WhiteListSanitizer.new    
  end

  def sanitize_params(params = params)
    get_white_list_sanitizer
    params = walk_hash(params) if params
  end

  def walk_hash(hash)
    hash.keys.each do |key|
      if hash[key].is_a? String
        hash[key] = @white_list_sanitizer.sanitize(hash[key])
      elsif hash[key].is_a? Hash
        hash[key] = walk_hash(hash[key])
      elsif hash[key].is_a? Array
        hash[key] = walk_array(hash[key])
      end
    end
    hash
  end

  def walk_array(array)
    array.each_with_index do |el,i|
      if el.is_a? String
        array[i] = @white_list_sanitizer.sanitize(el)
      elsif el.is_a? Hash
        array[i] = walk_hash(el)
      elsif el.is_a? Array
        array[i] = walk_array(el)
      end
    end
    array
  end

end
