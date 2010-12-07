# Use css parser to break up style blocks
require 'css_parser'
include CssParser

module CssCleaner

  # For use in ActiveRecord models
  # We parse and clean the CSS line by line in order to provide more helpful error messages.
  # The prefix is used if you want to make sure a particular prefix appears on all the selectors in
  # this block of css, eg "#work p" instead of just "p"
  def clean_css_code(css_code, prefix = "")
    clean_css = ""
    parser = CssParser::Parser.new
    parser.add_block!(css_code)
    prefix = prefix + " " unless prefix.blank?
    parser.each_rule_set do |rs|
      selectors = rs.selectors.map do |selector|
        sel = selector.gsub(/\n/, '').strip
        sel = sel.match(/^\s*#{prefix}/) ? sel : prefix + sel
      end
      clean_rule = "#{selectors.join(",\n")} {\n"
      rs.each_declaration do |property, value, is_important|
        declaration = "#{property}: #{value}#{is_important ? ' !important' : ''};"
        clean_declaration = sanitize_css_declaration(declaration)
        # if we differ in anything but case or whitespace, there's an issue
        if declaration.downcase.gsub(/\s+/, '') != clean_declaration.downcase.gsub(/\s+/, '')
          if clean_declaration.empty?
            if declaration !~ /^(\s*[-\w]+\s*:\s*[^:;]*(;|$)\s*)*$/
              errors.add(:base, ts("The code for #{rs.selectors.join(',')} doesn't seem to be a valid CSS rule."))
            else
              # the property is not allowed
              errors.add(:base, ts("The declarations for #{rs.selectors.join(',')} cannot use the property #{property}"))
            end
          else
            errors.add(:base, ts("The #{property} property in #{rs.selectors.join(',')} cannot have the value #{value}"))
          end
        else
          clean_rule += "  #{clean_declaration}\n"
        end
      end
      clean_rule += "}\n\n"
      clean_css += "#{clean_rule}"
    end
    return clean_css
  end

  # A declaration must match the format:   property: value; (property: value; ... property: value;)
  # All properties must appear in ArchiveConfig.SUPPORTED_CSS_PROPERTIES or ArchiveConfig.SUPPORTED_CSS_SHORTHAND_PROPERTIES,
  # or that property and its value will be omitted.
  # All values are sanitized. If any values in a declaration are invalid, the value will be blanked out and an
  #   empty property returned.
  def sanitize_css_declaration(declaration)
    declaration = declaration.to_s

    # basic check: make sure "declaration" has at least one valid css statement of the format property: value
    if declaration !~ /^(\s*[-\w]+\s*:\s*([^:;]|https?:)*(;|$)\s*)*$/
      return ''
    end

    clean = []
    declaration.scan(/([-\w]+)\s*:\s*([^;]*)/) do |prop,val|
      prop.downcase!
      if prop == "font-family"
        if !sanitize_css_font(val).blank?
          clean << "#{prop}: #{val};"
        else
          clean << "#{prop}: ;"
        end
      elsif ArchiveConfig.SUPPORTED_CSS_SHORTHAND_PROPERTIES.include?(prop) || ArchiveConfig.SUPPORTED_CSS_SHORTHAND_PROPERTIES.include?(prop.split(/\-([^-]*)$/).first)
        cleanval = []
        # squash together comma-plus-space before splitting on spaces
        val.split(", ").join(",").split.each do |keyword|
          if sanitize_css_value(keyword).blank?
            # bad value somewhere, break
            cleanval = []
            break
          else
            cleanval << sanitize_css_value(keyword)
          end
        end
        clean << "#{prop}: #{cleanval.join(' ')};"
      elsif ArchiveConfig.SUPPORTED_CSS_PROPERTIES.include?(prop)
        if !sanitize_css_value(val).blank?
          clean << "#{prop}: #{val};"
        else
          clean << "#{prop}: ;"
        end
      end
    end
    clean.join(' ')
  end

  # all values must either appear in ArchiveConfig.SUPPORTED_CSS_KEYWORDS, be urls of the format url(http://url/) or be
  # rgb(), hex (#), or numeric values, or a comma-separated list of same
  def sanitize_css_value(value)
    value_stripped = value.downcase.gsub(/(!important)/, '').strip
    if ArchiveConfig.SUPPORTED_CSS_KEYWORDS.include?(value_stripped) ||
      value_stripped.split(',').all? {|subval| ArchiveConfig.SUPPORTED_CSS_KEYWORDS.include?(subval.strip)} ||
      value_stripped =~ /^(#[0-9a-f]+|scale\(\d{0,2}\.?\d{0,2}\)|rgba?\(\d+%?,? ?\d*%?,? ?\d*%?,? ?\d{0,3}?\.?\d{0,3}?\)|\-?\d{0,3}\.?\d{0,3}(cm|em|ex|in|mm|pc|pt|px|s|%|,)?)$/
      # return original value
      return value
    elsif value_stripped.match(/\burl\b/) && ArchiveConfig.SUPPORTED_CSS_KEYWORDS.include?("url")
      return sanitize_css_url(value)
    else
      return ""
    end
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
