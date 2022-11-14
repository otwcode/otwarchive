# note, if you modify this file you have to restart the server or console
module HtmlCleaner

  # Takes a Nokogiri node or a string/hash pair
  def open_tag(node, attributes=nil)
    begin
      name = node.name
      attributes = Hash[*(node.attribute_nodes.map { |n| [n.name, n.value] }.flatten)]
      self_closing = node.children.empty? ? "/" : ""
    rescue NameError
      name = node
      attributes ||= {}
      self_closing = ""
    end

    attr = ""
    attributes.each { |aname, avalue| attr += " #{aname}='#{avalue}'" }
    return "<#{name}#{attr}#{self_closing}>"
  end

  # Takes a Nokogiri node or a string
  def close_tag(node, attributes=nil)
    begin
      name = node.name
      self_closing = node.children.empty?
    rescue NameError
      name = node
      self_closing = false
    end

    self_closing ? "" : "</#{name}>"
  end

  class TagStack < Array
    include HtmlCleaner

    def inside_paragraph?
      flatten.include?("p")
    end

    def ignore_tag?(tag)
      ["text", "myroot", "#cdata-section"].include?(tag)
    end

    def open_paragraph_tags
      result = ""
      each do |tags|
        tags.each do |tag, attributes|
          next if result == "" && tag != "p"
          next if ignore_tag?(tag)
          result = "" if tag == "p"
          result += open_tag(tag, attributes)
        end
      end
      return result
    end

    def close_paragraph_tags
      return "" if !inside_paragraph?
      result = ""
      reverse.each do |tags|
        tags.reverse.each do |tag, attributes|
          next if ignore_tag?(tag)
          result += close_tag(tag, attributes)
          return result if tag == "p"
        end
      end
    end

    def close_and_pop_last
      result = ""
      pop.reverse.each do |tag, attributes|
        next if ignore_tag?(tag)
        result += "</#{tag}>"
      end
      return result
    end

    def add_p
      self[-1] = self[-1] + [["p", {}]]
      return "<p>"
    end
  end

  # If we aren't sure that this field hasn't been sanitized since the last sanitizer version,
  # we sanitize it before we allow it to pass through (and save it if possible).
  def sanitize_field(object, fieldname)
    return "" if object.send(fieldname).nil?
    if object.respond_to?("#{fieldname}_sanitizer_version")
      if object.send("#{fieldname}_sanitizer_version") < ArchiveConfig.SANITIZER_VERSION
        # sanitize and save it
        Rails.logger.debug "Sanitizing and saving #{fieldname} on #{object.class.name} (id #{object.id})"
        object.update_attribute(fieldname, sanitize_value(fieldname, object.send("#{fieldname}")))
        object.update_attribute("#{fieldname}_sanitizer_version", ArchiveConfig.SANITIZER_VERSION)
      end
      # return the field without sanitizing
      Rails.logger.debug "Already sanitized #{fieldname} on #{object.class.name} (id #{object.id})"
      object.send("#{fieldname}")
    else
      # no sanitizer version information, so re-sanitize
      Rails.logger.debug "Sanitizing without saving #{fieldname} on #{object.class.name} (id #{object.id})"
      sanitize_value(fieldname, object.send("#{fieldname}"))
    end
  end

  def get_white_list_sanitizer
    @white_list_sanitizer ||= HTML::WhiteListSanitizer.new
  end

  def get_full_sanitizer
    @full_sanitizer ||= HTML::FullSanitizer.new
  end

  # yank out bad end-of-line characters and evil msword curly quotes
  def fix_bad_characters(text)
    return "" if text.nil?

    # get the text into UTF-8 and get rid of invalid characters
    text = text.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")

    text.gsub! "<3", "&lt;3"

    # convert carriage returns to newlines
    text.gsub!(/\r\n?/, "\n")

    # argh, get rid of ____spacer____ inserts
    text.gsub! "____spacer____", ""

    # trash a whole bunch of crappy non-printing format characters stuck
    # in most commonly by MS Word
    # \p{Cf} matches all unicode char in the "other, format" category
    text.gsub!(/\p{Cf}/u, '')

    return text
  end

  def sanitize_value(field, value)
    return value if ArchiveConfig.FIELDS_WITHOUT_SANITIZATION.include?(field.to_s)
    if ArchiveConfig.NONZERO_INTEGER_PARAMETERS.has_key?(field.to_s)
      return (value.to_i > 0) ? value.to_i : ArchiveConfig.NONZERO_INTEGER_PARAMETERS[field.to_s]
    end
    return "" if value.blank?
    unfrozen_value = value&.dup
    unfrozen_value.strip!
    if field.to_s == 'title'
      # prevent invisible titles
      unfrozen_value.gsub!("<", "&lt;")
      unfrozen_value.gsub!(">", "&gt;")
    end
    if ArchiveConfig.FIELDS_ALLOWING_LESS_THAN.include?(field.to_s)
      unfrozen_value.gsub!("<", "&lt;")
    end
    if ArchiveConfig.FIELDS_ALLOWING_HTML.include?(field.to_s)
      # We're allowing users to use HTML in this field
      transformers = []
      if ArchiveConfig.FIELDS_ALLOWING_VIDEO_EMBEDS.include?(field.to_s)
        transformers << OtwSanitize::EmbedSanitizer.transformer
        transformers << OtwSanitize::MediaSanitizer.transformer
      end
      if ArchiveConfig.FIELDS_ALLOWING_CSS.include?(field.to_s)
        transformers << OtwSanitize::UserClassSanitizer.transformer
      end
      # Now that we know what transformers we need, let's sanitize the unfrozen value
      if ArchiveConfig.FIELDS_ALLOWING_CSS.include?(field.to_s)
        unfrozen_value = add_paragraphs_to_text(Sanitize.clean(fix_bad_characters(unfrozen_value),
                               Sanitize::Config::CSS_ALLOWED.merge(transformers: transformers)))
      else
        # the screencast field shouldn't be wrapped in <p> tags
        unfrozen_value = add_paragraphs_to_text(Sanitize.clean(fix_bad_characters(unfrozen_value),
                               Sanitize::Config::ARCHIVE.merge(transformers: transformers))) unless field.to_s == "screencast"
      end
      doc = Nokogiri::HTML::Document.new
      doc.encoding = "UTF-8"
      unfrozen_value = doc.fragment(unfrozen_value).to_xhtml

      # Hack! the herald angels sing
      # TODO: AO3-5801 Switch to an HTML5 serializer that doesn't add invalid closing tags
      # to track and source elements.
      unfrozen_value.gsub!(%r{</(source|track)>}, "")
    else
      # clean out all tags
      unfrozen_value = Sanitize.clean(fix_bad_characters(unfrozen_value))
    end

    # Plain text fields can't contain &amp; entities:
    unfrozen_value.gsub!(/&amp;/, '&') unless (ArchiveConfig.FIELDS_ALLOWING_HTML_ENTITIES + ArchiveConfig.FIELDS_ALLOWING_HTML).include?(field.to_s)
    unfrozen_value
  end

  # grabbed from http://code.google.com/p/sanitizeparams/ and tweaked
  def sanitize_params(new_params = params)
    walk_hash(new_params) if new_params
  end

  def walk_hash(hash)
    hash.keys.each do |key|
      if hash[key].is_a? String
        hash[key] = sanitize_value(key, hash[key])
      elsif hash[key].is_a?(ActionController::Parameters)
        hash[key] = hash[key].to_hash
      elsif hash[key].is_a?(Hash)
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
        array[i] = sanitize_value("", el)
      elsif el.is_a? Hash
        array[i] = walk_hash(el)
      elsif el.is_a? Array
        array[i] = walk_array(el)
      end
    end
    array
  end


  # Tags whose content we don't touch
  def dont_touch_content_tag?(tag)
    %w[a abbr acronym address audio br dl figure h1 h2 h3 h4 h5 h6 hr img ol p
       pre source table track video ul].include?(tag)
  end

  # Tags that don't contain content
  def self_closing_tag?(tag)
    %w(br col hr img).include?(tag)
  end

  # Tags that need to go inside p tags
  def put_inside_p_tag?(tag)
    %w(a abbr acronym address b big cite code del dfn em i ins
       kbd q s script samp small span strike strong style sub
       sup tt u var).include?(tag)
  end

  # Tags that can't be inside p tags
  def put_outside_p_tag?(tag)
    %w[audio dl figure h1 h2 h3 h4 h5 h6 hr ol p pre source table track ul video].include?(tag)
  end

  # Tags before and after which we don't want to convert linebreaks
  # into br's and p's
  def no_break_before_after_tag?(tag)
    %w[audio blockquote br center dl div figcaption h1 h2 h3 h4 h5 h6
       hr ol p pre source table track ul video].include?(tag)
  end

  # Traverse a Nokogiri document tree recursively in order to insert
  # linebreaks. Since the resulting document is going to have a
  # different document structure (we're adding p tags at various
  # levels!) we can't edit the document in place. Instead, we're
  # creating a string with the resulting html and keep track of the
  # changed path to the current element via a stack.
  def traverse_nodes(node, stack=nil, out_html=nil)
    stack = stack || TagStack.new
    out_html = out_html || ""

    # Convert double and triple br tags into paragraph breaks
    if node.name == "br" && node.previous_sibling && node.previous_sibling.name == "br" && node.previous_sibling.previous_sibling && node.previous_sibling.previous_sibling.name == "br"
      out_html += (stack.close_paragraph_tags + "<p>&nbsp;</p>" + stack.open_paragraph_tags)
      return [stack, out_html]
    end
    if node.name == "br" && node.previous_sibling && node.previous_sibling.name == "br"
      out_html += (stack.close_paragraph_tags + stack.open_paragraph_tags)
      return [stack, out_html]
    end
    if node.name == "br" && node.next_sibling && node.next_sibling.name == "br"
      return [stack, out_html]
    end

    # Don't descend into node if we don't want to touch the content of
    # this kind of tag
    if dont_touch_content_tag?(node.name)
      if put_inside_p_tag?(node.name) && !stack.inside_paragraph?
        return [stack, out_html + "<p>#{node.to_s}</p>"]
      end

      if put_outside_p_tag?(node.name) && stack.inside_paragraph?
        out_html += (stack.close_paragraph_tags + node.to_s + stack.open_paragraph_tags)
        return [stack, out_html]
      end

      return [stack, out_html + node.to_s]
    end

    if !node.text? && !node.cdata?
      out_html += stack.add_p if put_inside_p_tag?(node.name) && !stack.inside_paragraph?

      stack << [[node.name, Hash[*(node.attribute_nodes.map { |n| [n.name, n.value] }.flatten)]]]
      out_html += open_tag(node)

      # If we are the root node, pre-emptively open a paragraph
      if node.name == "myroot"
        out_html += stack.add_p
      end

      if no_break_before_after_tag?(node.name) and !stack.last.include?("p")
        out_html += stack.add_p
      end

    else
      text = node.to_s

      # Remove leading/trailing linebreaks if we don't want to add
      # additional linebreaks after the previous tag/before the next
      # tag
      prev_tag = node.previous_sibling.nil? ? "" : node.previous_sibling.name
      text.lstrip! if no_break_before_after_tag?(prev_tag)
      next_tag = node.next_sibling.nil? ? "" : node.next_sibling.name
      text.rstrip! if no_break_before_after_tag?(next_tag)

      out_html += stack.add_p if !stack.inside_paragraph? && text != ""
      stack << [[node.name, Hash[*(node.attribute_nodes.map { |n| [n.name, n.value] }.flatten)]]]

      # If we have three newlines, assume user wants a blank line
      text.gsub!(/\n\s*?\n\s*?\n/, "\n\n&nbsp;\n\n")

      # Convert double newlines into single paragraph break
      text.gsub!(/\n+\s*?\n+/, stack.close_paragraph_tags + stack.open_paragraph_tags)

      # Convert single newlines into br tags
      text.gsub!(/\n/, '<br/>')

      out_html += text
    end

    # decend into child nodes
    node.children.each do |child|
      stack, out_html = traverse_nodes(child, stack, out_html)
    end

    out_html += stack.close_and_pop_last
    return [stack, out_html]
  end


  # Close an unclosed tag within the given text in the line at
  # line_number, or before the next opening or closing tag if that
  # comes first
  def close_unclosed_tag(text, tag, line_number)
    return text if self_closing_tag?(tag)
    return text unless put_inside_p_tag?(tag)
    line_number = line_number.to_i
    lines = text.lines.to_a
    pattern = /(^.*<#{tag}\s*.*?>.*?)($|<\/?\w+.*?\/?>)/
    lines[line_number-1].gsub!(pattern, "\\1</#{tag}>\\2")
    return lines.join("")
  end

  def add_paragraphs_to_text(text)
    doc = Nokogiri::XML.parse("<myroot>#{text}</myroot>")
    doc.errors.each do |error|
      match = error.message.match(/Opening and ending tag mismatch: (\w+) line (\d+) and myroot/)
      text = close_unclosed_tag(text, match[1], match[2]) if match
    end

    # Adding paragraphs in place of linebreaks
    doc = Nokogiri::HTML.fragment("<myroot>#{text}</myroot>")
    out_html = traverse_nodes(doc.at_css("myroot"))[1]
    # Remove empty paragraphs
    out_html.gsub!(/<p>\s*?<\/p>/, "")
    out_html.gsub!(/(\A<myroot>)|(<\/myroot>\Z)|(\A<myroot\/>\Z)/, "")
    out_html
  end


  ### STRIPPING FOR DISPLAY ONLY
  # Regexps for stripping particular tags and attributes for display.
  # These assume they are running on well-formed XHTML, which we can do
  # because they will only be used on already-cleaned fields.

  # strip img tags
  def strip_images(value)
    value.gsub(/<img .*?>/, '')
  end

  # strip style attributes
  def strip_styles(value)
    strip_attribute(value, "style")
  end

  # strip class attributes
  def strip_classes(value)
    strip_attribute(value, "class")
  end

  def strip_attribute(value, attribname)
    value.gsub(/\s*#{attribname}=\".*?\"\s*/, "")
  end

  def strip_html_breaks_simple(value)
    return "" if value.blank?
    value.gsub(/\s*<br ?\/?>\s*/, "<br />\n").
          gsub(/\s*<p[^>]*>\s*&nbsp;\s*<\/p>\s*/, "\n\n\n").
          gsub(/\s*<p[^>]*>(.*?)<\/p>\s*/m, "\n\n" + '\1').
          strip
  end

  def add_break_between_paragraphs(value)
    return "" if value.blank?
    value.gsub(%r{\s*</p>\s*<p>\s*}, "</p><br /><p>")
  end
end
