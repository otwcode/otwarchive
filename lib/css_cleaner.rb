# Use css parser to break up style blocks
require "css_parser"

module CssCleaner
  include CssParser

  # constant regexps for css values
  ALPHA_REGEX = Regexp.new('[a-z\-]+')
  UNITS_REGEX = Regexp.new('deg|cm|em|ex|in|mm|pc|pt|px|s|%', Regexp::IGNORECASE)
  NUMBER_REGEX = Regexp.new('-?\.?\d{1,3}\.?\d{0,3}')
  NUMBER_WITH_UNIT_REGEX = Regexp.new("#{NUMBER_REGEX}\s*#{UNITS_REGEX}?\s*,?\s*")
  PAREN_NUMBER_REGEX = Regexp.new('\(\s*' + NUMBER_WITH_UNIT_REGEX.to_s + '+\s*\)')
  PREFIX_REGEX = Regexp.new('moz|ms|o|webkit')

  FUNCTION_NAME_REGEX = Regexp.new('scalex?y?|translatex?y?|skewx?y?|rotatex?y?|matrix', Regexp::IGNORECASE)
  TRANSFORM_FUNCTION_REGEX = Regexp.new("#{FUNCTION_NAME_REGEX}#{PAREN_NUMBER_REGEX}")

  SHAPE_NAME_REGEX = Regexp.new('rect', Regexp::IGNORECASE)
  SHAPE_FUNCTION_REGEX = Regexp.new("#{SHAPE_NAME_REGEX}#{PAREN_NUMBER_REGEX}")

  RGBA_REGEX = Regexp.new("rgba?" + PAREN_NUMBER_REGEX.to_s, Regexp::IGNORECASE)
  HSLA_REGEX = Regexp.new("hsla?" + PAREN_NUMBER_REGEX.to_s, Regexp::IGNORECASE)
  COLOR_REGEX = Regexp.new("#[0-9a-f]{3,6}|" + ALPHA_REGEX.to_s + "|" + RGBA_REGEX.to_s + "|" + HSLA_REGEX.to_s)
  COLOR_STOP_FUNCTION_REGEX = Regexp.new('color-stop\s*\(' + NUMBER_WITH_UNIT_REGEX.to_s + '\s*\,?\s*' + COLOR_REGEX.to_s + '\s*\)', Regexp::IGNORECASE)
  
  # list of filter functions can be found at https://developer.mozilla.org/en-US/docs/Web/CSS/filter#syntax
  FILTER_NAME_REGEX = Regexp.new("blur|brightness|contrast|grayscale|hue-rotate|invert|opacity|saturate|sepia", Regexp::IGNORECASE)
  FILTER_FUNCTION_REGEX = Regexp.new("#{FILTER_NAME_REGEX}#{PAREN_NUMBER_REGEX}")

  # drop-shadow can take multiple values, which are a mix of numbers and colors
  DROP_SHADOW_NAME_REGEX = Regexp.new("drop-shadow", Regexp::IGNORECASE)
  DROP_SHADOW_VALUE_REGEX = Regexp.new("\\(\\s*(#{NUMBER_WITH_UNIT_REGEX}|#{COLOR_REGEX}\\s*)+\\s*\\)")
  DROP_SHADOW_FUNCTION_REGEX = Regexp.new("#{DROP_SHADOW_NAME_REGEX}#{DROP_SHADOW_VALUE_REGEX}")

  # Custom properties (variables) are declared using --name: value and accessed
  # using property: var(--name). The var() function can be more complex, e.g.,
  # var(--name, fallback value), but we're keeping our implementation simple.
  CUSTOM_PROPERTY_NAME_REGEXP = Regexp.new("\\-\\-[0-9a-z\\-_]+", Regexp::IGNORECASE)
  PAREN_CUSTOM_PROPERTY_REGEX = Regexp.new("\\(\\s*#{CUSTOM_PROPERTY_NAME_REGEXP}\\s*\\)", Regexp::IGNORECASE)
  VAR_FUNCTION_REGEX = Regexp.new("var#{PAREN_CUSTOM_PROPERTY_REGEX}", Regexp::IGNORECASE)

  # To allow the url() function, it is also necessary to include "url" in ArchiveConfig.SUPPORTED_CSS_KEYWORDS
  # from the ICANN list at http://www.icann.org/en/registries/top-level-domains.htm
  TOP_LEVEL_DOMAINS = %w(ac ad ae aero af ag ai al am an ao aq ar arpa as asia at au aw ax az ba bb bd be bf bg bh bi biz bj bm bn bo br bs bt bv bw by bz ca cat cc cd cf cg ch ci ck cl cm cn co com coop cr cu cv cx cy cz de dj dk dm do dz ec edu ee eg er es et eu fi fj fk fm fo fr ga gb gd ge gf gg gh gi gl gm gn gov gp gq gr gs gt gu gw gy hk hm hn hr ht hu id ie il im in info int io iq ir is it je jm jo jobs jp ke kg kh ki km kn kp kr kw ky kz la lb lc li lk lr ls lt lu lv ly ma mc md me mg mh mil mk ml mm mn mo mobi mp mq mr ms mt mu museum mv mw mx my mz na name nc ne net nf ng ni nl no np nr nu nz om org pa pe pf pg ph pk pl pm pn pr pro ps pt pw py qa re ro rs ru rw sa sb sc sd se sg sh si sj sk sl sm sn so sr st su sv sy sz tc td tel tf tg th tj tk tl tm tn to tp tr travel tt tv tw tz ua ug uk us uy uz va vc ve vg vi vn vu wf ws xn xxx ye yt za zm zw)
  DOMAIN_REGEX = Regexp.new('https?://\w[\w\-\.]+\.(' + TOP_LEVEL_DOMAINS.join('|') + ')')
  DOMAIN_OR_IMAGES_REGEX = Regexp.new('\/images|' + DOMAIN_REGEX.to_s)
  URI_REGEX = Regexp.new(DOMAIN_OR_IMAGES_REGEX.to_s + '/[\w\-\.\/]*[\w\-]\.(' + ArchiveConfig.SUPPORTED_EXTERNAL_URLS.join('|') + ')')
  URL_REGEX = Regexp.new(URI_REGEX.to_s + '|"' + URI_REGEX.to_s + '"|\'' + URI_REGEX.to_s + '\'')
  URL_FUNCTION_REGEX = Regexp.new('url\(\s*' + URL_REGEX.to_s + '\s*\)')

  VALUE_REGEX = Regexp.new("#{TRANSFORM_FUNCTION_REGEX}|#{URL_FUNCTION_REGEX}|#{COLOR_STOP_FUNCTION_REGEX}|#{COLOR_REGEX}|#{NUMBER_WITH_UNIT_REGEX}|#{ALPHA_REGEX}|#{SHAPE_FUNCTION_REGEX}|#{FILTER_FUNCTION_REGEX}|#{DROP_SHADOW_FUNCTION_REGEX}|#{VAR_FUNCTION_REGEX}")


  # For use in ActiveRecord models
  # We parse and clean the CSS line by line in order to provide more helpful error messages.
  # The prefix is used if you want to make sure a particular prefix appears on all the selectors in
  # this block of css, eg ".userstuff p" instead of just "p"
  def clean_css_code(css_code, options = {})
    return "" if !css_code.match(/\w/) # only spaces of various kinds
    clean_css = ""
    parser = CssParser::Parser.new
    parser.add_block!(css_code)

    prefix = options[:prefix] || ''
    caller_check = options[:caller_check]

    errors.add(:base, :no_valid_css) if parser.to_s.blank?

    parser.each_rule_set do |rs|
      selectors = rs.selectors.map do |selector|
        if selector.match(/@font-face/i)
          errors.add(:base, :font_face)
          next
        end
        # remove whitespace and convert &gt; entities back to the > direct child selector
        sel = selector.gsub(/\n/, "").gsub("&gt;", ">").strip
        (prefix.blank? || sel.start_with?(prefix)) ? sel : "#{prefix} #{sel}"
      end
      clean_declarations = ""
      # Do not internationalize the , used as a join in these errors -- it's reflective of the comma used in the list of selectors, which does not change based on locale.
      rs.each_declaration do |property, value, is_important|
        if property.blank? || value.blank?
          errors.add(:base, :no_valid_css_for_selectors, selectors: rs.selectors.join(", "))
        elsif sanitize_css_property(property).blank?
          # If it starts with --, assume the user was trying to define a custom property.
          if property.match(/\A--/)
            errors.add(:base, :invalid_custom_property_name, property: property, selectors: rs.selectors.join(", "))
          else
            errors.add(:base, :banned_property, property: property)
          end
        elsif (cleanval = sanitize_css_declaration_value(property, value)).blank?
          errors.add(:base, :banned_value_for_property, property: property, selectors: rs.selectors.join(", "), value: value)
        elsif !caller_check || caller_check.call(rs, property, value)
          clean_declarations += "  #{property}: #{cleanval}#{is_important ? ' !important' : ''};\n"
        end
      end
      if clean_declarations.blank?
        errors.add(:base, :no_rules_for_selectors, selectors: rs.selectors.join(", "))
      else
        # everything looks ok, add it to the css
        clean_css += "#{selectors.join(",\n")} {\n"
        clean_css += clean_declarations
        clean_css += "}\n\n"
      end
    end
    return clean_css
  end

  def legal_property?(property)
    ArchiveConfig.SUPPORTED_CSS_PROPERTIES.include?(property) ||
      property.match(/-(#{PREFIX_REGEX})-(#{ArchiveConfig.SUPPORTED_CSS_PROPERTIES.join('|')})/)
  end

  def legal_shorthand_property?(property)
    property.match(/#{ArchiveConfig.SUPPORTED_CSS_SHORTHAND_PROPERTIES.join('|')}/)
  end

  def custom_property?(property)
    property.match(/\A(#{CUSTOM_PROPERTY_NAME_REGEXP})\z/)
  end

  def sanitize_css_property(property)
    return property if legal_property?(property) || legal_shorthand_property?(property) || custom_property?(property)
  end

  # A declaration must match the format `property: value;` (space and semicolon
  # are optional in user input).
  # All properties must appear in ArchiveConfig.SUPPORTED_CSS_PROPERTIES or
  # ArchiveConfig.SUPPORTED_CSS_SHORTHAND_PROPERTIES, or that property and its
  # value will be removed and an error message will be given.
  # All values are sanitized. If any values in a declaration are invalid, the
  # value will be blanked out and an empty property returned, which will result
  # in an error.
  def sanitize_css_declaration_value(property, value)
    clean = ""
    if property == "font-family"
      # preserve the original capitalization
      clean = value if sanitize_css_font(value).present?
    elsif property == "content"
      # don't allow var() function
      clean = value.match(/\bvar\b/i) ? "" : sanitize_css_content(value)
    # The url() function can be used in the values for certain properties,
    # provided "url" is included in ArchiveConfig.SUPPORTED_CSS_KEYWORDS. If
    # those criteria are not met, we strip the value here. If they are met, the
    # value will undergo sanitization in tokenize_and_sanitize_css_value or
    # sanitize_css_value.
    elsif value.match(/\burl\b/i) && (ArchiveConfig.SUPPORTED_CSS_KEYWORDS.exclude?("url") || %w[background background-image border border-image list-style list-style-image].exclude?(property))
      clean = ""
    elsif legal_shorthand_property?(property) || custom_property?(property)
      clean = tokenize_and_sanitize_css_value(value)
    elsif legal_property?(property)
      clean = sanitize_css_value(value)
    end
    clean.strip
  end

  # divide a css value into tokens and clean them individually
  def tokenize_and_sanitize_css_value(value)
    cleanval = ""
    scanner = StringScanner.new(value)

    # we scan until we find either a space, a comma, or an open parenthesis
    while scanner.exist?(/\s+|,|\(/)
      # we have some tokens left to break up
      in_paren = 0
      token = scanner.scan_until(/\s+|,|\(/)
      if token.blank? || token == ","
        cleanval += token
        next
      end
      in_paren = 1 if token.match(/\($/)
      while in_paren > 0
        # scan until closing paren or another opening paren
        nextpart = scanner.scan_until(/\(|\)/)
        if nextpart
          token += nextpart
          in_paren += 1 if token.match(/\($/)
          in_paren -= 1 if token.match(/\)$/)
        else
          # mismatched parens
          return ""
        end
      end

      # we now have a single token
      separator = token.match(/(\s|,)$/) || ""
      token.strip!
      token.chomp!(',')
      cleantoken = sanitize_css_token(token)
      return "" if cleantoken.blank?
      cleanval += cleantoken + separator.to_s
    end

    token = scanner.rest
    if token && !token.blank?
      cleantoken = sanitize_css_token(token)
      return "" if cleantoken.blank?
      cleanval += cleantoken
    end

    return cleanval
  end

  def sanitize_css_token(token)
    if token.match?(/gradient/)
      sanitize_css_gradient(token)
    else
      sanitize_css_value(token)
    end
  end

  # sanitize a CSS gradient
  # background:-webkit-gradient( linear, left bottom, left top, color-stop(0, rgb(82,82,82)), color-stop(1, rgb(125,124,125)));
  # -moz-linear-gradient(bottom, rgba(120,120,120,1) 5%, rgba(94,94,94,1) 50%, rgba(108,108,108,1) 55%, rgba(137,137,137,1) 100%);
  def sanitize_css_gradient(value)
    if value.match(/^([a-z\-]+)\((.*)\)/)
      function = $1
      interior = $2
      cleaned_interior = tokenize_and_sanitize_css_value(interior)
      if function.match(/gradient/) && !cleaned_interior.blank?
        return "#{function}(#{cleaned_interior})"
      end
    end
    return ""
  end

  # All values must be either
  # - in ArchiveConfig.SUPPORTED_CSS_KEYWORDS
  # - URLs of the format url(http://url/)
  # - rgba(), hsla(), hex, or named colors
  # - numeric values
  # - transform, shape, filter, drop shadow, or variable functions
  # Comma-separated lists of these values are also allowed.
  def sanitize_css_value(value)
    value_stripped = strip_value(value)

    begin
      # If it's a comma-separated set of valid values, it's fine. However, we need
      # to downcase any var() functions to match the css_parser gem's downcasing
      # of property names.
      if value_stripped.match?(/^(#{VALUE_REGEX},?\s*)+$/i)
        return value unless value.match?(/#{VAR_FUNCTION_REGEX}/)

        return value.gsub(/#{VAR_FUNCTION_REGEX}/, &:downcase)
      end
    rescue Regexp::TimeoutError
      # If we fail to match within the timeframe, it is likely that the value is invalid.
    end

    # If the value is explicitly in our list of supported keywords, it's fine.
    # However, note that !important is always allowed (refer to the comments on
    # strip_value(value) and ArchiveConfig.SUPPORTED_CSS_KEYWORDS for more), and
    # that the url() function is allowed by the VALUE_REGEX above. Excluding
    # url() from SUPPORTED_CSS_KEYWORDS only strips it because of the check in
    # sanitize_css_declaration_value.
    return value if value_stripped.split(",").all? { |subval| ArchiveConfig.SUPPORTED_CSS_KEYWORDS.include?(subval.strip) }

    return ""
  end

  def sanitize_css_content(value)
    # For now we only allow a single completely quoted string
    return value if value =~ /^\'([^\']*)\'$/
    return value if value =~ /^\"([^\"]*)\"$/

    # or a valid img url
    return value if value.match(Regexp.new("^#{URL_FUNCTION_REGEX}$"))

    # or "none"
    return value if value == "none"

    return ""
  end

  # Font family names may be alphanumeric values with dashes
  def sanitize_css_font(value)
    value_stripped = strip_value(value)
    if value_stripped.split(',').all? {|fontname| fontname.strip =~ /^(\'?[a-z0-9\- ]+\'?|\"?[a-z0-9\- ]+\"?)$/}
      return value
    else
      return ""
    end
  end

  # Remove !important and trailing spaces from values to simplify sanitization.
  # In most cases, we return the original value after sanitizaiton, which
  # restores the !important keyword.
  # Note that this means !important is always allowed, regardless of whether it
  # is included in ArchiveConfig.SUPPORTED_CSS_KEYWORDS.
  def strip_value(value)
    value.downcase.gsub(/(!important)/, "").strip
  end
end
