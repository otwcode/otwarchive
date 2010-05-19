# note, if you modify this file you have to restart the server or console
module HtmlFormatter
  include SanitizeParams

  @@allowed_tags_default = ['a', 'abbr', 'acronym', 'address', 'alt', 'b', 'big', 'blockquote', 'br', 'caption', 'center', 'cite', 'class', 'code', 'col', 'colgroup', 'datetime', 'dd', 'del', 'dfn', 'div', 'dl', 'dt', 'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'height', 'hr', 'href', 'i', 'img', 'ins', 'kbd', 'li', 'name', 'ol', 'p', 'pre', 'q', 's', 'samp', 'small', 'span', 'src', 'strike', 'strong', 'sub', 'sup', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'title', 'tr', 'tt', 'u', 'ul', 'var', 'width']

  @@all_html_tags = ['a', 'abbr', 'acronym', 'address', 'area', 'b', 'base', 'bdo', 'big', 'blockquote', 'body', 'br', 'button', 'caption', 'center', 'cite', 'code', 'col', 'colgroup', 'dd', 'del', 'dfn', 'div', 'dl', 'dt', 'em', 'fieldset', 'font', 'form', 'frame', 'frameset', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'hr', 'html', 'i', 'iframe', 'img', 'input', 'ins', 'kbd', 'label', 'legend', 'li', 'link', 'map', 'menu', 'meta', 'noframes', 'noscript', 'object', 'ol', 'optgroup', 'option', 'p', 'paragraphm', 'pre', 'q', 's', 'samp', 'script', 'select', 'small', 'span', 'strike', 'strong', 'style', 'sub', 'sup', 'table', 'tbody', 'td', 'textarea', 'tfoot', 'th', 'thead', 'title', 'tr', 'tt', 'u', 'ul', 'var']

  @@allowed_attribute_keys = %w(alt align border class height href name src title width)

  def cleanup_and_format(text)
    return clean_fully(text, @@all_html_tags, true, false)
  end

  def sanitize_and_format_for_display(text, options = {})
    if options[:tags]
      return clean_fully(text, options[:tags])
    else
      return clean_fully(text)
    end
  end

  # The "options[:tags]" parameter here is to preserve calling compatibility
  # with existing code.

  # This is future-planning - titles are currently stripped of all html in order to make sort and search simpler, so there should be no tags in titles which need sanitize in the view. 
  def sanitize_title_for_display(text, options = {:tags => ['a', 'b', 'br', 'p', 'i', 'em', 'strong', 'strike', 'u', 'ins', 'q', 'del', 'cite', 'blockquote', 'pre', 'code', 'small', 'sup', 'sub']})
    return "" if text.nil?
    return clean_fully(text, options[:tags], true, true, false)
  end
 
  # A more limited display option for comments and summaries
  def sanitize_limit_and_format_for_display(text, options = {:tags => ['a', 'b', 'big', 'blockquote', 'br', 'center', 'cite', 'code', 'del', 'em', 'i', 'img', 'ins', 'p', 'pre', 'q', 's', 'small', 'strike', 'strong', 'sub', 'sup', 'u']})
    return "" if text.nil?
    text = sanitize_and_format_for_display(text, options)
  end

  # Limited display option for the pseud description field. 
  def sanitize_description_for_display(text, options = {:tags => ['a', 'em', 'strong', 'b', 'i']})
    return "" if text.nil?
    sanitize_and_format_for_display(text, options)
  end
  
    # A more limited display option which strips obtrusive tags for index views.
  def sanitize_strip_images_and_format_for_display(text, options = {:tags => ['a', 'b', 'big', 'blockquote', 'br', 'center', 'cite', 'code', 'del', 'em', 'i', 'ins', 'p', 'pre', 'q', 's', 'small', 'strike', 'strong', 'sub', 'sup', 'u']})
    return "" if text.nil?
    sanitize_and_format_for_display(text, options)
  end
  
  INLINE_HTML_TAGS = %w(a b big br cite code del em i img q s small span strike strong sub sup tt u)
  BLOCK_HTML_TAGS = %w(div blockquote center ul ol li dl dt dd table tbody tfoot thead td tr th)
  NO_PARAGRAPHS_REQUIRED = %w(caption h1 h2 h3 h4 h5 h6 hr pre)
  
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
  
  # Turn newlines into paragraphs and linebreaks
  def add_paragraphs_to_text(parent_node, allowed_tags, working_parent=nil, block_container=true)
    working_parent ||= parent_node
    inline = INLINE_HTML_TAGS.include?(parent_node.node_name) || !block_container
    fakedoc = Nokogiri::HTML.parse("<br />")
    br_node = fakedoc.at_css('br')
    break_before_first_p = true
    first_node = true
    for node in parent_node.children
      # If it's a text node, add extra paragraphs and/or linebreaks 
      if node.text?
        text = node.content
        # Split the text on double newlines to create an array of paragraphs
        text_paragraphs = text.split("\n\n", -1)
        first_paragraph = true
        # If we don't unlink the node up here, the first line_node
        # gets created as a duplicate of it (??)
        node.unlink
        text_paragraphs.each do |p|
          # If we're inside an inline element, add two br tags between
          # paragraphs instead of using paragraph tags
          if inline && !first_paragraph
            working_parent.add_child(br_node.dup)
            working_parent.add_child(br_node.dup)
          # If the previous element was an inline element, we want to 
          # add the first bit of text to that paragraph instead of creating
          # a new one. Otherwise, create a new one.
          elsif !inline && (break_before_first_p || !first_paragraph)
            parent_node.before("<p></p>")
            working_parent = parent_node.previous
            copy_node_attributes(parent_node, working_parent)
          end          
          first_line = true
          # Create an array of lines, splitting on single newlines
          lines = (p.nil? || p.empty?) ? [''] : p.split("\n", -1)
          for line in lines
            # add a linebreak before any line that comes after a newline
            unless first_line
              working_parent.add_child(br_node.dup)
            end
            # Add the text to the current working tag
            unless line.empty? || line == "____spacer____"
              line_node = Nokogiri::XML::Text.new(line, fakedoc)
              line_node.unlink
              working_parent.add_child(line_node) 
              first_line = false
            end
          end
          first_paragraph = false
        end
      elsif !allowed_tags.include?(node.node_name) || (!block_container && node.node_name == 'p')
        add_paragraphs_to_text(node, allowed_tags, working_parent, block_container)
        node.unlink 
      # If this node is for an inline tag
      elsif INLINE_HTML_TAGS.include?(node.node_name)
        #clean up some deprecated tags
        if %w(s strike i b).include?(node.node_name)
          if node.node_name == 'b'
            node.node_name = 'strong'
          elsif node.node_name == 'i'
            node.node_name = 'em'
          else
            node.node_name = 'del'
          end
        end
        if first_node && !inline
          parent_node.before("<p></p>")
          working_parent = parent_node.previous
          copy_node_attributes(parent_node, working_parent)
        end
        # Have to create a new node to add the child nodes to
        # because if you accidentally put two text nodes next to 
        # one another, they're automatically combined
        clone_node = node.clone(0)
        copy_node_attributes(node, clone_node)
        
        working_parent.add_child(clone_node)
        working_parent = clone_node
        add_paragraphs_to_text(node, allowed_tags, working_parent)
        working_parent = working_parent.parent
        node.unlink
        break_before_first_p = false
      # A block tag inside an inline tag, argh
      elsif INLINE_HTML_TAGS.include?(parent_node.node_name)
        working_parent.add_child(node)
        add_paragraphs_to_text(node, allowed_tags, nil, false)
      # If this node is for a block tag
      else
        break_before_first_p = true
        parent_node.add_child(node)
        unless NO_PARAGRAPHS_REQUIRED.include?(node.node_name)
          add_paragraphs_to_text(node, allowed_tags, nil)
        end
      end
      first_node = false
    end
  end

  def clean_fully(text_input, allowed_tags=@@allowed_tags_default, sanitize=true, tidy=true, block_container=true)
    if text_input.blank?
      ""
    else
      # Standardize linebreaks
      text_input.gsub!("\r\n", "\n")
      text_input.gsub!("\n\n\n+", "\n\n")
      # Hack: Nokogiri eats linebreaks between self-closing tags and other tags.
      text_input.gsub!(/(<img[^\>]*\/?>\s*)$/, '\1' + "____spacer____\n")
      # Create a Nokogiri document
      doc = Nokogiri::HTML.parse(text_input)
      body = doc.at_css("body")
      # Make sure text is contained in paragraphs for consistent styling
      add_paragraphs_to_nodes(body.children) if block_container
      # Convert newlines into p and br tags
      add_paragraphs_to_text(body, allowed_tags, nil, block_container)
      # Remove empty paragraphs
      clean_up_paragraphs(doc.css("p"))
      return body.children.to_xhtml
    end
  end
  
  # Copy allowed attributes from one node to another
  def copy_node_attributes(source_node, target_node)
    unless source_node.attributes.empty?
      source_node.attributes.each_pair do |key, value|
        if @@allowed_attribute_keys.include?(key)
          target_node[key] = value
        end
      end
    end
  end

  # adds paragraphs and newlines, then gets rid of doubled ones
  def add_paragraph_tags_for_display(text)
    return clean_fully(text, @@all_html_tags)
  end

end