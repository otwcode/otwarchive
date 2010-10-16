# note, if you modify this file you have to restart the server or console
module HtmlCleaner

  # If we aren't sure that this field hasn't been sanitized since the last sanitizer version, 
  # we sanitize it before we allow it to pass through (and save it if possible).
  def sanitize_field(object, fieldname)
    if object.respond_to?("#{fieldname}_sanitizer_version")
      if object.send("#{fieldname}_sanitizer_version") < ArchiveConfig.SANITIZER_VERSION
        # sanitize and save it
        Rails.logger.info "Sanitizing and saving #{fieldname} on #{object.class.name} (id #{object.id})"
        object.update_attribute(fieldname, sanitize_value(fieldname, object.send("#{fieldname}")))
        object.update_attribute("#{fieldname}_sanitizer_version", ArchiveConfig.SANITIZER_VERSION)
      end
      # return the field without sanitizing
      Rails.logger.info "Already sanitized #{fieldname} on #{object.class.name} (id #{object.id})"
      object.send("#{fieldname}")
    else
      # no sanitizer version information, so re-sanitize 
      Rails.logger.info "Sanitizing without saving #{fieldname} on #{object.class.name} (id #{object.id})"
      sanitize_value(fieldname, object.send("#{fieldname}"))
    end
  end 

  def get_white_list_sanitizer
    @white_list_sanitizer ||= HTML::WhiteListSanitizer.new
  end

  def get_full_sanitizer
    @full_sanitizer ||= HTML::FullSanitizer.new
  end

  # replace evil msword curly quotes
  def fix_quotes(text)
    return "" if text.nil?
    text.gsub! "<3", "&#60;3"
    # maybe these will work instead? D:
    # text.gsub! /[\u201C\u201D\u201E\u201F\u2033\u2036]/u, '"'
    # text.gsub! /[\u2018\u2019\u201A\u201B\u2032\u2035]/u, "'"
    # FIXME - uncommented gets incompatible encoding regexp match error
    #    text.gsub! "\342\200\230", "'"
    #    text.gsub! "\342\200\231", "'"
    #    text.gsub! "\342\200\234", '"'
    #    text.gsub! "\342\200\235", '"'
    # these were commented out before
    #    text.gsub! "\221", "'"
    #    text.gsub! "\222", "'"
    #    text.gsub! "\223", '"'
    #    text.gsub! "\224", '"'
    return text
  end
  
  def sanitize_value(field, value)
    value.strip!
    if field.to_s == 'title'
      # prevent invisible titles
      value.gsub!("<", "&lt;")
      value.gsub!(">", "&gt;")
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
      value = Sanitize.clean(add_paragraphs_to_text(fix_quotes(value)), 
                             Sanitize::Config::ARCHIVE.merge(:transformers => transformers))
    else
      # clean out all tags
      value = Sanitize.clean(value)
    end    
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
        array[i] = Sanitize.clean(el)
      elsif el.is_a? Hash
        array[i] = walk_hash(el)
      elsif el.is_a? Array
        array[i] = walk_array(el)
      end
    end
    array
  end


  # Simplified parser/formatter steps:
  #
  # 1. Insert <p> and <br/> tags based on a few rules:
  #    a. If user has double <br/> tags, convert them to <p>
  #    b. If user has put in her own paragraph breaks, do not add.
  #    c. Otherwise: 
  #       Convert 3+ blank lines into extra whitespace lines using &nbsp;
  #       Convert double blank lines into <p> 
  #
  #    d. If user has put in her own <br/> tags, do not add.
  #    e. Otherwise:
  #       If we have <p> tags added, convert single linebreaks into <br/> tags.
  #       If not, convert single linebreaks into <p> tags.
  #
  # 2. Parse document with Nokogiri and export xhtml to get pretty-printed and
  #    well-formed (not necessarily validating!) xhtml with all tags closed.
  #
  def add_paragraphs_to_text(text)
    
    # convert double br tags into p tags
    source = text.gsub(/<br\s*?\/?>\s*<br\s*?\/?>/, '<p>')

    # parse the text with Nokogiri
    parsed = Nokogiri::HTML::DocumentFragment.parse(source)

    # see if we have any paragraph tags
    num_ptags = parsed.css('p').count

    if num_ptags > 0
      # Assume the user has put in her own desired paragraph breaks
    else
      # If we have three newlines, assume user wants a blank line
      source.gsub!(/\n\s*?\n\s*?\n/, "\n\n&nbsp;\n\n")
      
      # Convert double newlines into single paragraph break
      source.gsub!(/\n+\s*?\n+/, '<p>')
      parsed = Nokogiri::HTML::DocumentFragment.parse(source)
    end

    # check for paragraph and linebreak tags
    num_ptags = parsed.css('p').count
    num_brtags = parsed.css('br').count
    if num_brtags > 0
        # Assume user has put in her own desired linebreaks
    elsif num_ptags > 0
      # we've got paragraph breaks so treat linebreaks as breaks
      # and convert them into br tags
      source.gsub!(/\n/, '<br />')
    else
      # treat single linebreaks as paragraphs
      source.gsub!(/\n/, '<p>')
    end

    # Reparse as an entire document
    parsed = Nokogiri::HTML.parse(source)
    parsed.encoding = 'UTF-8'
    
    # add paragraphs where necessary
    body = parsed.at_css('body')
    add_paragraphs_to_nodes(body.children) unless body.nil?

    # yank out empty paragraphs
    clean_up_paragraphs(body.children) unless body.nil?

    # Get out the nice well-formed XHTML
    body = parsed.css("body")
    body.nil? ? "" : body.to_xhtml
  end    

  INLINE_HTML_TAGS = %w(a abbr acronym b big br cite code del dfn em i img ins kbd q s samp small span strike strong sub sup tt u var)
  BLOCK_HTML_TAGS = %w(div address blockquote center ul ol li dl dt dd table tbody tfoot thead td tr th)
  NO_PARAGRAPHS_REQUIRED = %w(caption dt h1 h2 h3 h4 h5 h6 hr pre)
  
  # Ensure that all text that isn't a heading is contained in a paragraph
  def add_paragraphs_to_nodes(nodes)
    parent = nil
    for node in nodes
      if NO_PARAGRAPHS_REQUIRED.include?(node.node_name) || node.node_name == 'p'
        parent = nil
      else
        if BLOCK_HTML_TAGS.include?(node.node_name)
          parent = nil
          add_paragraphs_to_nodes(node.children)
        else
          unless parent
            node.after("<p></p>")
            parent = node.next
          end
          node.unlink
          parent.add_child(node)
        end
      end
    end
  end
  
  # Pop off empty paragraphs
  def clean_up_paragraphs(nodes)
    for node in nodes
      if node.node_name == 'p'
        child_types = node.children.collect(&:node_name).uniq - ["text", "br"]         
        if child_types.blank? && node.content.blank?
          node.remove
        end
      end
    end
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
  
end