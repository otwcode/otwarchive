# note, if you modify this file you have to restart the server or console
# grabbed from http://code.google.com/p/sanitizeparams/ and tweaked
module SanitizeParams

  def get_white_list_sanitizer
    @white_list_sanitizer ||= HTML::WhiteListSanitizer.new
  end

  def get_full_sanitizer
    @full_sanitizer ||= HTML::FullSanitizer.new
  end

  # strip comment and <!whatever> tags like DOCTYPE
  def strip_comments(text)
    text.gsub!(/<!--(.*?)-->[\n]?/m, "")
    text.gsub!(/<!(.*?)>[\n]?/m, "")
    return text
  end
  
  # strip all html 
  def sanitize_fully(text)
    get_full_sanitizer
    @full_sanitizer.sanitize(text)
  end  
  
  # strip dangerous html
  # if :tags => %w(list of tags) and :attributes => %w(list of attributes)
  # are passed as options, only those tags/attributes will be allowed. 
  def sanitize_whitelist(text, options = {})
    get_white_list_sanitizer
    @white_list_sanitizer.sanitize(text, options)
  end

  def sanitize_params(params = params)
    get_white_list_sanitizer
    get_full_sanitizer
    params = walk_hash(params) if params
  end

  def walk_hash(hash)
    hash.keys.each do |key|
      if hash[key].is_a? String
        if ArchiveConfig.FIELDS_ALLOWING_HTML.include?(key.to_s)
          hash[key] = @white_list_sanitizer.sanitize(strip_comments(hash[key]))
        else
          hash[key] = @full_sanitizer.sanitize(hash[key])
        end
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
        array[i] = @full_sanitizer.sanitize(el)
      elsif el.is_a? Hash
        array[i] = walk_hash(el)
      elsif el.is_a? Array
        array[i] = walk_array(el)
      end
    end
    array
  end

end
