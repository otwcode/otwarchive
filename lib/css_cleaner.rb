# Use css parser to break up style blocks
require 'css_parser'
include CssParser

module CssCleaner

  # For use in ActiveRecord models 
  # We parse and clean the CSS line by line in order to provide more helpful error messages.
  # The prefix is used if you want to make sure a particular prefix appears on all the selectors in 
  # this block of css, eg ".userstuff p" instead of just "p"
  def clean_css_code(css_code, prefix = "")
    return "" if !css_code.match(/\w/) # only spaces of various kinds
    clean_css = ""
    parser = CssParser::Parser.new
    parser.add_block!(css_code)
    prefix = prefix + " " unless prefix.blank?
    
    if parser.to_s.blank?
      errors.add(:base, ts("We couldn't find any valid CSS rules in that code."))
    else
      parser.each_rule_set do |rs|
        selectors = rs.selectors.map do |selector|
          if selector.match(/@font-face/i)
            errors.add(:base, ts("We don't allow the @font-face feature."))
            next
          end
          sel = selector.gsub(/\n/, '').strip
          sel = sel.match(/^\s*#{prefix}/) ? sel : prefix + sel
        end
        clean_declarations = ""
        rs.each_declaration do |property, value, is_important|
          if property.blank? || value.blank?
            errors.add(:base, ts("The code for #{rs.selectors.join(',')} doesn't seem to be a valid CSS rule."))
          elsif sanitize_css_property(property).blank?
            errors.add(:base, ts("We don't currently allow the CSS property #{property} -- please notify support if you think this is an error."))
          elsif (cleanval = sanitize_css_declaration_value(property, value)).blank?
            errors.add(:base, ts("The #{property} property in #{rs.selectors.join(', ')} cannot have the value #{value}, sorry!"))
          else
            clean_declarations += "  #{property}: #{cleanval}#{is_important ? ' !important' : ''};\n"
          end
        end
        if clean_declarations.blank?
          errors.add(:base, ts("There don't seem to be any rules for #{rs.selectors.join(',')}"))
        else
          # everything looks ok, add it to the css
          clean_css += "#{selectors.join(",\n")} {\n"
          clean_css += clean_declarations
          clean_css += "}\n\n"
        end
      end
    end
    return clean_css
  end
  
  def sanitize_css_property(property)
    if ArchiveConfig.SUPPORTED_CSS_PROPERTIES.include?(property) ||
      property.match(/#{ArchiveConfig.SUPPORTED_CSS_SHORTHAND_PROPERTIES.join('|')}/)
        return property
    end
    return ""
  end
  
  
  # A declaration must match the format:   property: value;
  # All properties must appear in ArchiveConfig.SUPPORTED_CSS_PROPERTIES or ArchiveConfig.SUPPORTED_CSS_SHORTHAND_PROPERTIES, 
  # or that property and its value will be omitted.
  # All values are sanitized. If any values in a declaration are invalid, the value will be blanked out and an
  #   empty property returned.
  def sanitize_css_declaration_value(property, value)
    clean = ""
    property.downcase!
    if property == "font-family"
      if !sanitize_css_font(value).blank?
        # preserve the original capitalization
        clean = value
      end
    elsif property == "content"
      clean = sanitize_css_content(value)
    elsif property.match(/#{ArchiveConfig.SUPPORTED_CSS_SHORTHAND_PROPERTIES.join('|')}/)
      if value.match(/#{ArchiveConfig.SUPPORTED_CSS_FUNCTIONS.join('|')}/)
        clean = sanitize_css_function(value)
      else
        clean = sanitize_css_shorthand_value(value)
      end
    elsif ArchiveConfig.SUPPORTED_CSS_PROPERTIES.include?(property)
      if property == "content"
        # sanitize content here
      else 
        clean = sanitize_css_value(value)
      end
    end
    clean.strip
  end


  # sanitize a CSS function, eg, gradient
  # background:-moz-linear-gradient(bottom, rgba(120,120,120,1) 5%, rgba(94,94,94,1) 50%, rgba(108,108,108,1) 55%, rgba(137,137,137,1) 100%) ;
  def sanitize_css_function(value)
    if value.match(/^([a-z\-]+)\((.*)\)/)
      function = $1
      cleaned_interior = sanitize_css_shorthand_value($2)
      if function.match(/#{ArchiveConfig.SUPPORTED_CSS_FUNCTIONS.join('|')}/) && !cleaned_interior.blank?
        return "#{function}(#{cleaned_interior});"
      end
    end
    return ""
  end


  # Shorthand rule -- might have multiple space-separated and/or comma-separated values 
  # AND might have rgba values in there also, aagh
  def sanitize_css_shorthand_value(value)
    cleanval = []
    rgba_value = ""
    # get rid of spaces after commas
    value.split(", ").join(",").split(",").each do |value_section|        
      # Rejoin rgba values before checking
      if rgba_value.blank? && value_section.match(/rgba?\(/)
        rgba_value = value_section
        next
      elsif !rgba_value.blank?
        rgba_value += "," + value_section
        if rgba_value.match(/rgba?\(.*\)/)
          # we've completed the rgba value, go ahead and sanitize it
          value_section = rgba_value
          rgba_value = ""
        else
          next
        end
      end
      
      clean_section = []
      value_section.split.each do |keyword|
        if sanitize_css_value(keyword).blank?
          # bad value somewhere, break
          clean_section = []
          break
        else
          clean_section << sanitize_css_value(keyword) 
        end
      end
      if clean_section.empty?
        cleanval = []
        break
      else
        cleanval << clean_section.join(' ')
      end
    end
    cleanval.join(', ')
  end


  # all values must either appear in ArchiveConfig.SUPPORTED_CSS_KEYWORDS, be urls of the format url(http://url/) or be 
  # rgba(), hex (#), or numeric values, or a comma-separated list of same
  def sanitize_css_value(value)
    value_stripped = value.downcase.gsub(/(!important)/, '').strip

    # handle urls if we want to support them
    if value_stripped.match(/\burl\b/)
      if ArchiveConfig.SUPPORTED_CSS_KEYWORDS.include?("url")
        return sanitize_css_url(value)
      else
        return ""
      end
    end

    # If it's an ordinary alphabetic string, it's fine
    return value if value_stripped.split(',').all? {|subval| subval.strip =~ /^[a-z\-]+$/}

    # If it's explicitly in our keywords it's fine
    return value if value_stripped.split(',').all? {|subval| ArchiveConfig.SUPPORTED_CSS_KEYWORDS.include?(subval.strip)}

    # if it's an rgba, hex, percentage, or numeric value it's fine
    return value if value_stripped =~ /^(#[0-9a-f]+|rgba?\(\d+%?,? ?\d*%?,? ?\d*%?,? ?\d{0,3}?\.?\d{0,3}?\)|\-?\d{0,3}\.?\d{0,3}(deg|cm|em|ex|in|mm|pc|pt|px|s|%|,)?)$/

    return ""
  end


  def sanitize_css_content(value)
    # For now we only allow a single completely quoted string
    return value if value =~ /^\'([^\']*)\'$/      
    return value if value =~ /^\"([^\"]*)\"$/
    
    return ""
  end


  # Font family names may be alphanumeric values with dashes
  def sanitize_css_font(value)
    value_stripped = value.downcase.gsub(/(!important)/, '').strip
    if value_stripped.split(',').all? {|fontname| fontname.strip =~ /^(\'?[a-z0-9\- ]+\'?|\"?[a-z0-9\- ]+\"?)$/}
      return value
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
    if value.downcase.match(/^\s*url\s*\(\s*([\"|\'])?(https?:\/\/[\-\w\.\/]+)([\"|\'])?\s*\)\s*$/)
      url = $2
      # make sure url ends in an allowed type and quotes are balanced if present
      if $1 == $3 && url.match(/\.(#{ArchiveConfig.SUPPORTED_EXTERNAL_URLS.join('|')})$/)
        return value
      end
    else
      return ""
    end
  end
  
end