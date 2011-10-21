# note, if you modify this file you have to restart the server or console
module HtmlCleaner

  XSL = Nokogiri::XSLT(File.open("#{Rails.root.to_s}/lib/html_cleaner.xsl"))

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
    text = text.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")
    
    text.gsub! "<3", "&lt;3"

    # convert carriage returns to newlines
    text.gsub!(/\r\n?/, "\n")
    
    # replace curlyquotes
    # note: turns out not to be necessary?
    # text.gsub! "\xE2\x80\x98", "'"
    # text.gsub! "\xE2\x80\x99", "'"
    # text.gsub! "\xE2\x80\x9C", '"'
    # text.gsub! "\xE2\x80\x9D", '"'
    
    # argh, get rid of ____spacer____ inserts
    text.gsub! "____spacer____", ""
    
    # trash a whole bunch of crappy non-printing format characters stuck 
    # in most commonly by MS Word
    # \p{Cf} matches all unicode char in the "other, format" category
    text.gsub!(/\p{Cf}/u, '')

    return text
  end
  
  def sanitize_value(field, value)
    if ArchiveConfig.NONZERO_INTEGER_PARAMETERS.has_key?(field.to_s)
      return (value.to_i > 0) ? value.to_i : ArchiveConfig.NONZERO_INTEGER_PARAMETERS[field.to_s]
    end
    return "" if value.blank?
    value.strip!
    if field.to_s == 'title'
      # prevent invisible titles
      value.gsub!("<", "&lt;")
      value.gsub!(">", "&gt;")
    end
    if ArchiveConfig.FIELDS_ALLOWING_LESS_THAN.include?(field.to_s)
      value.gsub!("<", "&lt;")
    end
    if ArchiveConfig.FIELDS_ALLOWING_HTML.include?(field.to_s)
      # We're allowing users to use HTML in this field
      transformers = []
      if ArchiveConfig.FIELDS_ALLOWING_VIDEO_EMBEDS.include?(field.to_s)
        transformers << Sanitize::Transformers::ALLOW_VIDEO_EMBEDS 
      end
      if ArchiveConfig.FIELDS_ALLOWING_CSS.include?(field.to_s)
        transformers << Sanitize::Transformers::ALLOW_USER_CLASSES
      end   
      value = Sanitize.clean(add_paragraphs_to_text(fix_bad_characters(value)), 
                             Sanitize::Config::ARCHIVE.merge(:transformers => transformers))
    else
      # clean out all tags
      value = Sanitize.clean(fix_bad_characters(value))
    end

    # Plain text fields can't contain &amp; entities:
    value.gsub!(/&amp;/, '&') unless (ArchiveConfig.FIELDS_ALLOWING_HTML_ENTITIES + ArchiveConfig.FIELDS_ALLOWING_HTML).include?(field.to_s)
    value
  end

  # grabbed from http://code.google.com/p/sanitizeparams/ and tweaked
  def sanitize_params(params = params)
    params = walk_hash(params) if params
  end

  def walk_hash(hash)
    hash.keys.each do |key|
      if hash[key].is_a? String
        hash[key] = sanitize_value(key, hash[key])
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
        array[i] = sanitize_value("", el)
      elsif el.is_a? Hash
        array[i] = walk_hash(el)
      elsif el.is_a? Array
        array[i] = walk_array(el)
      end
    end
    array
  end
  
  DONT_TOUCH_TAGS = %w(dl h1 h2 h3 h4 h5 h6 hr ol p pre table ul)

  def open_tag(node)
    attr = ""
    self_closing = node.children.empty? ? "/" : ""
    node.attribute_nodes.each { |n| attr += " #{n.name}='#{n.value}'" }
    return "<#{node.name}#{attr}#{self_closing}>"
  end

  def close_tag(node)
    node.children.empty? ? "" : "</#{node.name}>"
  end

  def traverse_nodes(node, parentpath=nil, out_html=nil)
    parentpath = parentpath || []
    out_html = out_html || ""

    p parentpath
    return [parentpath, out_html + node.to_s] if DONT_TOUCH_TAGS.include?(node.name)

    
    out_html += open_tag(node) unless node.text?

    out_html += node.text if node.text?
    # if node.children.empty?
    #   if node.text? && node.text.include?("\n")
    #     replacement = Nokogiri::XML::NodeSet.new(newdoc)
    #     parts = node.text.split("\n")
    #     parts.each_with_index do |text, i|
    #       replacement << Nokogiri::XML::Text.new(text, newdoc) unless text.empty?
    #       replacement << Nokogiri::XML::Node.new("br", newdoc) unless i == parts.size-1
    #     end
    #     p node.path
    #     p newdoc.xpath(node.path)
    #     newnode = newdoc.xpath(node.path)[0]
    #     newnode.replace(replacement)
    #   end
    #   return
    # end
    parentpath << [node.name]
    node.children.each do |child|
      parentpath, out_html = traverse_nodes(child, parentpath, out_html)
    end

    out_html += close_tag(node) unless node.text?
    parentpath.pop
    return [parentpath, out_html]
  end

  def add_paragraphs_to_text(text)
    puts "====="
    puts text
    doc = Nokogiri::HTML.parse(text)
    dummy, out_html = traverse_nodes(doc.at_css("body"))
    out_html =  Nokogiri::HTML.parse(out_html).at_css("body").children.to_xhtml
    puts out_html
    return out_html
  end
  
  
  # tags that we need to reopen if users have them crossing paragraph breaks.
  # bad users, no biscuit :(
  HTML_TAGS_TO_REOPEN = %w(b big cite code del em i s small strike strong sub sup tt u)

  # Simplified parser/formatter steps:
  # 1. Convert newlines into paragraph/break tags based on some simple rules
  # 2. Parse document with Nokogiri and export xhtml to get pretty-printed and
  #    well-formed (not necessarily validating!) xhtml with all tags closed.
  #
  def add_paragraphs_to_text2(text)

    # get rid of spaces and newlines-before/after-paragraphs and linebreaks
    # this enables us to avoid converting newlines into paras/breaks where we already have them
    source = text.gsub(/\s*(<p[^>]*>)\s*/, '\1')   # replace all whitespace before/after <p>
    source.gsub!(/\s*(<\/p>)\s*/, '\1')            # replace all whitespace before/after </p>
    source.gsub!(/\s*(<br\s*?\/?>)\s*/, '<br />')  # replace all whitespace before/after <br>  

    # do we have a paragraph to start and end
    source = '<p>' + source unless source.match(/^<p/)
    source = source + "</p>" unless source.match(/<\/p>$/)
    
    # If we have three newlines, assume user wants a blank line
    source.gsub!(/\n\s*?\n\s*?\n/, "\n\n&nbsp;\n\n")

    # Convert double newlines into single paragraph break
    source.gsub!(/\n+\s*?\n+/, '</p><p>')

    # Convert single newlines into br tags
    source.gsub!(/\n/, '<br />')
    
    # convert double br tags into p tags
    source.gsub!(/<br\s*?\/?>\s*<br\s*?\/?>/, '</p><p>')
    
    # if we have closed inline tags that cross a <p> tag, reopen them 
    # at the start of each paragraph before the end
    HTML_TAGS_TO_REOPEN.each do |tag|      
      source.gsub!(/(<#{tag}>)(.*?)(<\/#{tag}>)/) { $1 + reopen_tags($2, tag) + $3 }
    end
    
    # reopen paragraph tags that cross a <div> tag
    source.gsub!(/(<p[^>]*>)(.*?)(<\/p>)/) { $1 + reopen_tags($2, "p", "div") + $3 }
    
    # swap order of paragraphs around divs
    source.gsub!(/(<p[^>]*>)(<div[^>]*>)/, '\2\1')

    # Parse in Nokogiri
    parsed = Nokogiri::HTML.parse(source)
    parsed.encoding = 'UTF-8'
    
    # Get out the nice well-formed XHTML
    source = parsed.css("body").to_xhtml
    
    # trash empty paragraphs and leading spaces
    source.gsub!(/\s*<p[^>]*>\s*<\/p>\s*/, "")
    source.gsub!(/^\s*/, '')
    
    # get rid of the newlines-before/after-paragraphs inserted by to_xhtml,
    # so that when this is loaded up by strip_html_breaks in textarea fields,
    # 
    source.gsub!(/\s*(<p[^>]*>)\s*/, '\1')
    source.gsub!(/\s*(<\/p>)\s*/, '\1')
    
    # trash the body tag
    source.gsub!(/<\/?body>\s*/, '')
    
    # return the text
    source
  end
  
  def reopen_tags(string, tag_to_reopen, outer_tag = "p")
    return string.gsub(/(<\/#{outer_tag}><#{outer_tag}[^>]*?>)/, "</#{tag_to_reopen}>" + '\1' + "<#{tag_to_reopen}>")
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
  
end
