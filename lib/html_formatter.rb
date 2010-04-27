# note, if you modify this file you have to restart the server or console
module HtmlFormatter
  include SanitizeParams

  @@allowed_tags_default = ['a', 'abbr', 'acronym', 'address', 'alt', 'b', 'big', 'blockquote', 'br', 'caption', 'center', 'cite', 'class', 'code', 'col', 'colgroup', 'datetime', 'dd', 'del', 'dfn', 'div', 'dl', 'dt', 'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'height', 'hr', 'href', 'i', 'img', 'ins', 'kbd', 'li', 'name', 'ol', 'p', 'pre', 'q', 'samp', 'small', 'span', 'src', 'strike', 'strong', 'sub', 'sup', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'title', 'tr', 'tt', 'u', 'ul', 'var', 'width']

  @@all_html_tags = ['a', 'abbr', 'acronym', 'address', 'area', 'b', 'base', 'bdo', 'big', 'blockquote', 'body', 'br', 'button', 'caption', 'center', 'cite', 'code', 'col', 'colgroup', 'dd', 'del', 'dfn', 'div', 'dl', 'dt', 'em', 'fieldset', 'font', 'form', 'frame', 'frameset', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'hr', 'html', 'i', 'iframe', 'img', 'input', 'ins', 'kbd', 'label', 'legend', 'li', 'link', 'map', 'menu', 'meta', 'noframes', 'noscript', 'object', 'ol', 'optgroup', 'option', 'p', 'paragraphm', 'pre', 'q', 's', 'samp', 'script', 'select', 'small', 'span', 'strike', 'strong', 'style', 'sub', 'sup', 'table', 'tbody', 'td', 'textarea', 'tfoot', 'th', 'thead', 'title', 'tr', 'tt', 'u', 'ul', 'var']

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
  def sanitize_limit_and_format_for_display(text, options = {:tags => ['a', 'b', 'big', 'blockquote', 'br', 'center', 'cite', 'code', 'del', 'em', 'i', 'img', 'ins', 'p', 'pre', 'q', 'small', 'strike', 'strong',  'sub', 'sup', 'u']})
    return "" if text.nil?
    text = sanitize_and_format_for_display(text, options)
  end

  # Limited display option for the pseud description field. 
  def sanitize_description_for_display(text, options = {:tags => ['a', 'em', 'strong', 'b', 'i']})
    return "" if text.nil?
    sanitize_and_format_for_display(text, options)
  end
  
    # A more limited display option which strips obtrusive tags for index views.
  def sanitize_strip_images_and_format_for_display(text, options = {:tags => ['a', 'b', 'big', 'blockquote', 'br', 'center', 'cite', 'code', 'del', 'em', 'i', 'ins', 'p', 'pre', 'q', 'small', 'strike', 'strong', 'sub', 'sup', 'u']})
    return "" if text.nil?
    sanitize_and_format_for_display(text, options)
  end

  def clean_fully(text_input, allowed_tags=@@allowed_tags_default, sanitize=true, tidy=true, block_container=true)
    return "" if text_input.nil?
    return "" if text_input.empty?
    # text is assumed to have been sanitised by the HTML parser.

    # The actual program
    # 1. Parse text into HTML 'tree' as a series of nested nodes
    raw_nodes = parse_text(text_input)
    raise text_input.inspect if raw_nodes.nil?
    nodes = raw_nodes
    # 2. Sanitize the text and comment nodes and deal with
    # tags that are unclosed or not allowed
    if sanitize
      nodes = sanitize_nodes(nodes, allowed_tags)
      raise raw_nodes.inspect if nodes.nil?
    end
    # 3. Add paragraphs and linebreaks
    if tidy
      nodes = tidy_nodes(nodes, block_container)
      raise raw_nodes.inspect if nodes.nil?
    end
    # 4. Render and return
    return nodes.map(&:render).join('')
  end

  # The various functions that do the real work. Some of these used to be
  # recursive, but have been reduced to a monolithic loop and a state stack
  # which is unlimited, unlike the function stack.
  # Some are still recursive. 'tidy_nodes' in particular cannot deal with a
  # html element depth of maybe 800, but that's going to involve another
  # fiddly loop optimisation that I don't want to do unless it's necessary.
  #
  # A node object represents a node of text, such as a paragraph, a link, or an image
  # Nodes are nested within each other in order to duplicate the nested
  # nature of html documents. A plain text paragraph, for example, would be represented
  # by a parent node with node.node_type set to :html and node.tag_name set to 'p', with
  # node.children as an array containing a text node whose contents are equal to the 
  # text of the paragraph.
  #
  # The state stack is a way of keeping track of open tags. Each open, non-self-closing
  # html tag has its node added to the stack, along with whatever the nodes array is at the
  # time, so that each item in the state stack array has the format [node, nodes]. Each time
  # you hit a closing tag, end_node is called, and it pops the last entry off the stack.
  # If there are open nodes in the stack when you've reached the end of the text (badly nested html!),
  # we simply loop through them and close all the tags. 
  def parse_text(text)

    return [], '' if text.nil?
    nodes = []
    state_stack = []

    end_node = lambda do |tag, text2|
      text = text2
      unless tag.self_closing?
        # the state stack would only be empty if there were no open tags
        if state_stack.empty?
          # Record bogus end node
          nodes << tag
          return true
        else
          node, nodes = state_stack.pop
          closing = nil
          if text.blank? && tag && !tag.children.nil?
            # End of stream. This tag has no closing tag.
            closing = "!#{node.tag_name}"
          elsif !tag.nil? && tag.tag_name != node.tag_name
            # Tag does not match opening tag
            closing = "-#{tag.tag_name}"
          end
          node.contents = closing
          nodes << node
        end
      end
    end

    single_quote = "'"
    double_quote = '"'

    # Loop through the text until you reach the end, creating text, comment and html nodes
    until text.blank?
      # If it doesn't start with an opening bracket, it's a text node.
      if text.first != '<'
        # Find out where the next opening tag begins
        pos = text.index '<'
        # if there are no brackets in the text, add a text node to the nodes array
        # with the current text and set the text variable to an empty string so that the loop ends
        if pos.nil?
          value, rest = text, ''
        # if there is an opening bracket in the text, add a text node to the nodes array
        # with the current text up to the point where the bracket is and set the text variable
        # to the current text minus the text before the bracket
        else
          value, rest = text[0...pos], text[pos...text.length]
        end
        nodes << Node.new(:node_type => :text, :contents => value)
        text = rest
        next
      # If the text begins with a bracket, it may be an html tag
      else
        # We identify the first type of quote used because we want to avoid interpreting brackets
        # used inside quoted text
        double_quote_pos = text.index(double_quote)
        single_quote_pos = text.index(single_quote)
        first_quote_type = single_quote
        # if there's a double-quote in the text, and it comes before
        # any single quotes, then the first quote type is double_quote
        if !double_quote_pos.nil? && (single_quote_pos == nil || single_quote_pos > double_quote_pos)
          first_quote_type = double_quote
        end
        
        pos = text.index('<') #should always equal 0
        second_pos = text.index('<', pos+1)
        close_pos = text.index('>', pos+1)
        
        # if the first closing bracket after the opening bracket falls
        # between two quotes, don't count that as the end of the tag
        # count the next one if it exists and comes before the next opening bracket
        # otherwise, the close_pos value is set to nil, which will cause the 
        # rest of the text to be interpreted as a text node
        if close_pos
          while text[0...close_pos].count(first_quote_type) % 2 == 1
            close_pos = text.index('>', close_pos+1)
            break unless close_pos
            if second_pos && second_pos < close_pos
              close_pos = text.index('>', pos+1)
              break
            end
          end
        end

        if !close_pos
          # if there is no closing bracket in the text, treat it as a text node 
          nodes << Node.new(:node_type => :text, :contents => text)
          text = ''
          next
        # if the text begins with "<!--", it's an html comment
        elsif text[1..1] == '!'
          if text[2..3] == '--' 
            # if the comment ends properly, add a comment node to the nodes array
            # with the comment text in it, and set the text variable to the rest
            # of the text
            if text.index('-->')
              value, rest = text.split('-->', 2)
            # if the comment never ends, treat the whole text like a comment
            else
              value, rest = text, ''
            end
            # strip "<!--" from the beginning of the comment text
            # and add it as a comment node
            value = value[4..value.length]
            nodes << Node.new(:node_type => :comment, :contents => value)
            text = rest
            next
          # if the text begins with "<!" without the dashes, drop everything
          # between the brackets and set the text variable to whatever comes
          # after that
          else
            text = text.split('>', 2).last
            next
          end
        # if the text begins with "<?", it's an xml declaration
        # drop everything between the brackets
        # and set the text variable to whatever comes after that
        elsif text[1..1] == '?'
          text = text.split('>', 2).last
          next
        # if the text begins with "</", it should be a closing tag
        elsif text[1..1] == '/'
          name, rest = text.split('>', 2)
          # name becomes the name of the tag with the bracket and slash stripped off
          name = name[2..name.length].strip
          # setting the children to nil is what lets end_node know it's a closing tag
          new_node = Node.new(:node_type => :html, :tag_name => name)
          if new_node.self_closing?
            text = rest
            next
          else
            new_node.children = nil
            new_node.contents = nil
            end_node.call(new_node, rest) and next or break
          end
        # anything else should be an opening html tag
        else 
          # if there is a second "<" in the text
          if second_pos
            # if there's an unclosed quote in the text before the next opening bracket,
            # move forward until you hit an opening bracket before which there are an even
            # number of quotes. if that never happens, second_pos is set to nil
            while !second_pos.nil? && (text[0...second_pos].count(first_quote_type) % 2 == 1)
              second_pos = text.index('<', second_pos+1)
            end
            # if the next opening bracket comes before the first closing bracket,
            # treat the text between the two opening brackets as a text node
            # and set the text variable to the text that begins with the next
            # opening bracket
            if second_pos && second_pos < close_pos
              nodes << Node.new(:node_type => :text, :contents => text[0...second_pos])
              text = text[second_pos...text.length]
              next
            end
          end
          # The tag is either an open tag or a self closing tag.          
          # the tag variable contains everything between the opening bracket and
          # the first closing bracket, which is hopefully an html tag
          # the text variable is set to the remainder of the text, if it exists
          tag, text = text.split('>', 2)
          text ||= ''
          # get rid of the opening bracket
          tag = tag[1..tag.length]
          # tag name = contents of the tag before any spaces
          # attributes = anything else
          tag_name, attrs = tag.split(' ', 2)
          attrs ||= ''
          attrs.strip!

          # Check to see if this is a self-closing tag
          self_closing = false
          # if the tag ends with "/>", it's a self-closing tag, such as img or br
          # remove the slash && set self_closing to true
          if attrs.end_with? '/'
            self_closing = true
            attrs = attrs.strip[0...attrs.length-1]
          elsif tag_name.end_with? '/'
            self_closing = true
            tag_name = tag_name.strip[0...tag_name.length-1]
          # if the tag should be a self-closing tag but isn't closed, treat
          # it as a self-closing tag anyway
          elsif Node::SELF_CLOSING_TAGS.include?(tag_name)
            self_closing = true
          end
          
          # Handle any attributes
          attr_hash = {}
          attrs.strip!
          while !attrs.empty?
            # only continue if the attributes are assigned properly
            equals_pos = attrs.index('=')
            break if equals_pos == nil
            # the first attribute name is the text up to the first =
            attr_name = attrs[0...equals_pos].strip
            # rest is everything after the =
            # should be the attribute value
            rest = attrs[equals_pos+1...attrs.length].strip
            # if the first character is a quote (it should be)
            if rest.first == double_quote || rest.first == single_quote
              # find the position of the closing quote
              attr_value_end = rest.index(rest.first, 1)
              # if there isn't a closing quote, consider the full value of rest
              # (minus the opening quote) to be the attribute value
              if attr_value_end == nil                  
                attr_hash[attr_name] = rest[1...rest.length]
                attrs = ''
              # if there is a closing quote, make the value of the attribute
              # the text between the quotes
              # run the loop on the remaining text to parse any more attributes
              else
                attr_hash[attr_name] = rest[1...attr_value_end]
                attrs = rest[attr_value_end+1...attrs.length].strip
              end
            else
              # An unquoted value - dangerous to make assumptions...
              # I think the best thing to do is to take a single word if
              # there is no space after the equals, or drop the attribute
              # if there is a space.
              space_pos = rest.index(' ')
              if space_pos == nil
                attr_hash[attr_name] = rest
                attrs = ''
              elsif space_pos == 0
                attrs = rest.lstrip
              else
                attr_hash[attr_name], attrs = rest[0...space_pos], rest[space_pos...rest.length].strip
              end
            end
          end
          
          # The node for the tag
          node = Node.new(:node_type => :html, :tag_name => tag_name, :tag_attributes => attr_hash, :contents => '-NOT-SET-')
          if self_closing
            node.contents = nil
            nodes << node
            next
          # add the current open node and the array of nodes to the state_stack
          else
            state_stack << [node, nodes]
            # this should be what allows nesting - when you add something to nodes,
            # you're adding it to the children of the last open tag
            nodes = node.children
            next
          end
        end
      end
    end # end of "until text.blank?"
    
    # if there are still open nodes in the state stack when we hit
    # the end of the text, loop through and close them all
    # tag is just a dummy node in this context
    while !state_stack.empty?
      tag = Node.new(:node_type => :none, :contents => nil)
      end_node.call(tag, '')
      next
    end

    return nodes
  end  

  # sanitize_nodes basically sanitizes text and comment content,
  # comments out tags that are not allowed and empancipates their children,
  # deals with unclosed tags and emancipates their children,
  # and passes valid, nested tags and content through itself recursively
  # Nodes are removed from the front of the work_list and added back on to
  # the end until they're all processed and marked included
  def sanitize_nodes(nodes, allowed_tags=@@allowed_tags_default)
    # Clean up nodes we don't want, and put appropriate escapes into the
    # text nodes.
    sanitized_nodes = []
    work_list = []
    
    # Sets the node as included and adds the node and out_list back to the work_list
    push_node = lambda do |out_list, node|
      node.included = true
      work_list << [node, out_list]
    end
    
    # Start by adding all the nodes to the work list
    for node in nodes
      work_list << [node, sanitized_nodes]
    end
    
    # Loops through the work list repeatedly until all nodes are either
    # included and added to the out_list, or removed
    while !work_list.empty?
      # pops off the first array in the work_list
      # set the node to its first element and out_list to its second
      node, out_list = work_list.shift
      next if node.nil?
      if node.included
        out_list << node
      elsif node.node_type == :text
        # Escape '<' and '>'
        node.contents.gsub!('<', '&lt;')
        node.contents.gsub!('>', '&gt;')
        # Escape any non-entity ampersands
        node.contents.gsub!(/&(?!(?:[a-z]+|#[0-9]+);)(.*?;?)/, '&amp;\1')
        push_node[out_list, node]
      elsif node.node_type == :comment
        node.contents.gsub!('--', '- - ') # double dash is illegal in comments
        push_node[out_list, node]
      elsif node.node_type == :html && !allowed_tags.include?(node.tag_name) && node.children
        if true # "<!--xxx-->" comment bad nodes
          new_node = Node.new(:node_type => :comment, :contents => "<#{node.tag_name}>")
          push_node[out_list, new_node]
          for n in node.children
            work_list << [n, out_list]
          end
          new_node = Node.new(:node_type => :comment, :contents => "</#{node.tag_name}>")
          push_node[out_list, new_node]
        else # "&gt;xxx&lt;" escape bad nodes
          new_node = Node.new(:node_type => :text, :contents => "&lt;#{node.tag_name}&gt;")
          push_node[out_list, new_node]
          for n in node.children
            work_list << [n, out_list]
          end
          new_node = Node.new(:node_type => :text, :contents => "&lt;/#{node.tag_name}&gt;")
          push_node[out_list, new_node]
        end
      elsif !node.contents.nil? && node.contents.first == '!'
        # Unmatched tag - assume not to have contents
        children = []
        new_node = node.clone
        new_node.children = children
        new_node.contents = nil
        push_node[out_list, new_node]
        if node.inline_tag?
          child_list = children
        else
          child_list = out_list
        end
        for n in node.children
          child_list = out_list unless n.node_type == :text
          work_list << [n, child_list]
        end
      # a valid html tag
      else
        unless node.children.nil?
          child_nodes = node.children
          node.children = []
          push_node[out_list, node]
          for n in child_nodes
            work_list << [n, node.children]
          end
        end
      end
    end
    for n in sanitized_nodes
      raise [n, sanitized_nodes, text_input].inspect if n.children == nil
    end
    return sanitized_nodes
  end


  # This function restructures and adds paragraphs and linebreaks. 
  # Unless block_container is set to false, it assumes that its outer container is a block
  # container and thus should have paragraph tags around its text content.
  def tidy_nodes(nodes, block_container=true, inline=false)

    # All completed paragraphs
    paragraphs = []

    # The current_paragraph node is a new node to which text can be added
    # Every time tidy_nodes is run, a new paragraph is created.
    current_paragraph = Node.new_paragraph
    
    # cleans up whitespace, closes the current_paragraph and opens a new one
    new_paragraph = lambda do
      
      # Remove extra whitespace from the beginning and end of a paragraph
      fix_whitespace = lambda do
        # loop through current_paragraph's children
        # remove any from the top that are empty text nodes
        if current_paragraph.paragraph_tag?
          children = current_paragraph.children
          while !children.empty? && (children.first.text? && children.first.contents.strip.empty?)
            children.shift
          end
          # loop through current_paragraph's children
          # remove any from the end that are empty text nodes
          while !children.empty? && (children.last.text? && children.last.contents.strip.empty?)
            children.pop
          end
        end
      end
      
      fix_whitespace.call()
      # loop through children and remove br nodes from the top
      while !current_paragraph.children.empty? && current_paragraph.children.first.tag_name == 'br'
        current_paragraph.children.shift
        fix_whitespace.call()
      end
      # loop through children and remove br nodes from the end
      while !current_paragraph.children.empty? && current_paragraph.children.last.tag_name == 'br'
        current_paragraph.children.pop
        fix_whitespace.call()
      end
      # unless current_paragraph is already an empty paragraph, close it and make a new one
      if !current_paragraph.paragraph_tag? || !current_paragraph.children.empty?
        paragraphs << current_paragraph
        current_paragraph = Node.new(:node_type => :html, :tag_name => 'p', :contents => nil)
      end
    end
    
    # This inner function handles paragraph reorganisation within a block
    # element, and it sometimes recurses to flatten the structure.
    handle_nodes = lambda do |nodes|
      for node in nodes
        # Skip comments
        # pass them on to the current paragraph's children, if it has any,
        # or to the paragraphs array
        if node.comment?
          if current_paragraph.children.empty?
            paragraphs << node
          else
            current_paragraph.children << node
          end
          next
        end
        # If it's a text node, add paragraphs and line breaks
        if node.text?
          # Text nodes are to be split in to paragraphs at double line breaks,
          # and <br> tags inserted at single line breaks
          text_paragraphs = node.contents.gsub("\n\n\n+", "\n\n").split("\n\n", -1)
          first = true
          
          # If this weren't commented out, it would get rid of any empty paragraphs
          # text_paragraphs = text_paragraphs.select{|paragraph| !paragraph.strip.empty?}
          
          text_paragraphs.each do |paragraph|
            # If we're working in inline mode, don't create new paragraphs, just add
            # each text node to the parent and put linebreaks between them
            new_paragraph.call() unless first || inline
            first_line = true
            # Create an array of lines from each paragraph, splitting on every newline.
            # String#split method doesn't work as one might expect here.
            # I think "".split('x') should give [""], not []
            if paragraph == ''
              lines = [paragraph]
            else
              lines = paragraph.split("\n", -1)
            end
            for line in lines
              # Unless this is the first line in the paragraph, add a br before it
              unless first_line
                new_node = Node.new(:node_type => :html, :tag_name => 'br', :contents => nil)
                current_paragraph.children << new_node 
              end
              # Turn the line into a text node and add it to the array of children for this paragraph
              if line
                new_node = Node.new(:node_type => :text, :contents => line)
                current_paragraph.children << new_node 
              end
              first_line = false
            end
            first = false
          end
          next
        # If the current node is already a paragraph, process the text and
        # add any brs
        elsif node.paragraph_tag?
          new_paragraph.call()
          # Just handle the contents
          handle_nodes.call(node.children)
          # A dummy value to preserve the paragraph break.
          current_paragraph.children << Node.new(:node_type => :text, :contents => '')
        elsif node.block_tag?
          inline = !node.allow_child_paragraphs?
          if inline
            new_paragraph.call()
            current_paragraph = node.clone
            new_paragraph.call()
          end
          node.children = tidy_nodes(node.children, block_container, inline)
          if node.block_container_tag?
            new_paragraph.call()
            current_paragraph = node.clone
            new_paragraph.call()
          else
            #current_paragraph.children << node
          end
        else
          if node.self_closing?
            new_node = Node.new(:node_type => :html, :tag_name => node.tag_name, :tag_attributes => node.tag_attributes, :contents => nil)
            current_paragraph.children << new_node
            handle_nodes.call(node.children)
          else
            # Inline elements are handled here
            # An inline tag should never be alone in a paragraph because of us. :(
            current_paragraph.children << node
            if node.inline_tag?
              #node.children = tidy_nodes(node.children, block_container, inline=true)
              node.add_paragraph_tags_to_children(inline=true)
            end
          end
        end
      end
    end

    handle_nodes.call(nodes)
    new_paragraph.call()
    unless block_container
      # If our container is a block container, then remove outer <p> tag.
      out_nodes = []
      for paragraph in paragraphs
        for node in paragraph.children
          out_nodes << node
        end
      end
      return out_nodes
    end
    return paragraphs
  end

  # adds paragraphs and newlines, then gets rid of doubled ones
  def add_paragraph_tags_for_display(text)
    return clean_fully(text, @@all_html_tags)
  end

end