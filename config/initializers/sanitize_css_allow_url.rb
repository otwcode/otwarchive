
# Update the default lists of CSS properties and keywords
HTML::WhiteListSanitizer.shorthand_css_properties.merge(ArchiveConfig.SUPPORTED_CSS_SHORTHAND_PROPERTIES)
HTML::WhiteListSanitizer.allowed_css_properties.merge(ArchiveConfig.SUPPORTED_CSS_PROPERTIES)
HTML::WhiteListSanitizer.allowed_css_keywords.merge(ArchiveConfig.SUPPORTED_CSS_KEYWORDS)

# Update sanitize_css to allow image file urls and -moz properties, 
module HTML
  class WhiteListSanitizer
    
    # rewriting sanitize_css extensively 
    # all chunks of code must match format property: value; (property: value; ... property: value;)
    # all properties must appear in allowed_css_properties or shorthand_css_properties
    def sanitize_css(style)
      style = style.to_s

      # gauntlet
      # if style !~ /^([:,;#%.\sa-zA-Z0-9!]|\w-\w|\-moz-|\'[\s\w]+\'|\"[\s\w]+\"|\([\d,\s]+\)|url\s*\(\s*[\"|\']?[\-\w\.]+[\"|\']?\s*\))*$/ ||
      if style !~ /^(\s*[-\w]+\s*:\s*([^:;]|https?:)*(;|$)\s*)*$/        
        return ''
      end

      clean = []
      style.scan(/([-\w]+)\s*:\s*([^;]*)/) do |prop,val|
        prop.downcase!
        if allowed_css_properties.include?(prop)
          if !sanitize_css_value(val).blank?
            clean << "#{prop}: #{val};"
          else
            clean << "#{prop}: ;"
          end
        elsif shorthand_css_properties.include?(prop.split('-')[0]) 
          cleanval = []
          val.split().each do |keyword|
            if sanitize_css_value(keyword).blank?
              # bad value somewhere, break
              cleanval = []
              break
            else
              cleanval << sanitize_css_value(keyword) 
            end
          end
          clean << "#{prop}: #{cleanval.join(' ')};"
        end
      end
      clean.join(' ')
    end

    # all values must either appear in allowed_css_keywords, be urls of the format url(http://url/) or be 
    # rgb(), hex (#), or numeric values, or a comma-separated list of same
    def sanitize_css_value(value)
      value_dc = value.downcase.gsub(/('|"|!important)/, '').strip
      if allowed_css_keywords.include?(value_dc) || 
        value_dc.split(',').all? {|subval| allowed_css_keywords.include?(subval.strip)} || 
        value_dc =~ /^(#[0-9a-f]+|rgb\(\d+%?,\d*%?,?\d*%?\)|\d{0,2}\.?\d{0,2}(cm|em|ex|in|mm|pc|pt|px|%|,)?)$/
        return value
      elsif value_dc.match(/\burl\b/) && allowed_css_keywords.include?("url")
        return sanitize_css_url(value_dc)
      else
        return ""
      end
    end
    
    
    # URL values must be of the format:
    # url(url name)
    # http:// or https:// protocol
    # can be inside single or double quotes but must match
    # extra space inside or outside the enclosing parentheses is fine
    # must end in an allowed type (eg, jpg, png, gif)
    def sanitize_css_url(value)
      if value.match(/^\s*url\s*\(\s*([\"|\'])?(https?:\/\/[\-\w\.\/]+)([\"|\'])?\s*\)\s*$/)
        url = $2
        # make sure url ends in an allowed type and quotes are balanced if present
        if url.match(/\.(#{ArchiveConfig.SUPPORTED_EXTERNAL_URLS.join('|')})$/) && $1 == $3
          return value
        end
      else
        return ""
      end
    end

  end
end
