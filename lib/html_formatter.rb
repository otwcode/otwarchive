# note, if you modify this file you have to restart the server or console
module HtmlFormatter
  include SanitizeParams

  @@allowed_tags_default = ['a', 'abbr', 'acronym', 'address', 'alt', 'b', 'big', 'blockquote', 'br', 'caption', 'center', 'cite', 'class', 'code', 'col', 'colgroup', 'datetime', 'dd', 'del', 'dfn', 'div', 'dl', 'dt', 'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'height', 'hr', 'href', 'i', 'img', 'ins', 'kbd', 'li', 'name', 'ol', 'p', 'pre', 'q', 'samp', 'small', 'span', 'src', 'strike', 'strong', 'sub', 'sup', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'title', 'tr', 'tt', 'u', 'ul', 'var', 'width']

  @@all_html_tags = ['a', 'abbr', 'acronym', 'address', 'area', 'b', 'base', 'bdo', 'big', 'blockquote', 'body', 'br', 'button', 'caption', 'center', 'cite', 'code', 'col', 'colgroup', 'dd', 'del', 'dfn', 'div', 'dl', 'dt', 'em', 'fieldset', 'font', 'form', 'frame', 'frameset', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'hr', 'html', 'i', 'iframe', 'img', 'input', 'ins', 'kbd', 'label', 'legend', 'li', 'link', 'map', 'menu', 'meta', 'noframes', 'noscript', 'object', 'ol', 'optgroup', 'option', 'p', 'param', 'pre', 'q', 's', 'samp', 'script', 'select', 'small', 'span', 'strike', 'strong', 'style', 'sub', 'sup', 'table', 'tbody', 'td', 'textarea', 'tfoot', 'th', 'thead', 'title', 'tr', 'tt', 'u', 'ul', 'var']

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
    _text = '#text'
    _comment = '#comment'

    # Some data:
    block_tags_list = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'hr', 'br', 'div', 'blockquote', 'ul', 'ol', 'dl', 'pre', 'table', 'center']
    # These tags will cause paragraphs to end before them, and new paragraphs
    # to begin afterwards
    block_cont_tags_list = ['div', 'blockquote', 'hr', 'center', 'ul', 'ol', 'dl']
    #These tags act as containers and can't have <br> or <p> tags preceding
    cont_tags_list = ['tbody','col','tr','caption']
    # These tags are forced to self-close with no content.
    always_self_close_list = ['br', 'hr', 'img']
    # These non-block tags will have extra paragraph tags wrapped around their
    # content. This feature was added because the previous code seemed to be
    # trying to do this, but I've disabled the feature lower down in the code,
    # beause it looks much tidier that way! (This list, therefore, does nothing)
    inl_cont_tags_list = ['h1','h2','h3','h4','h5','h6','i','em','big','small','cite','b','strong','del','ins','caption','code']

    # The various (recursive) functions that do the real work
    parse_text = lambda do |text|
      return [], '' if text.nil?
      # Takes a snippet of html. returns: nodes, leftover_text
      # nodes is a list where each node takes the form:
      # (tagname, attribute_hash, child_list, text_value)
      # with the special tagnames '#text' and '#comment' having a text_value.
      if text[0..0] == '<'
        # A tag
        if (pos = text.index('<', 1)) and pos < text.index('>')
          # If another lt before gt then it's a text node.
          return [[_text, {}, [], text[0...pos]], text[pos...text.length]]
        elsif text[1..1] == '!'
          # It's a comment or we drop it
          if text[2..3] == '--'
            value, rest = text.split('-->', 2)
            value = value[4..value.length]
            return [[_comment, {}, [], value], rest]
          else
            return parse_text.call(text.split('>', 2)[1])
          end
        elsif text[1..1] == '/'
          # A closing tag
          name, rest = text.split('>', 2)
          name = name[2..name.length].strip
          return [[name, {}, nil, nil], rest]
        else
          # Either an open tag or a self closing tag.
          # Attributes
          tag, text = text.split('>', 2)
          tag = tag[1..tag.length]
          tag_name, attrs = tag.split(' ', 2)
          attrs = (attrs or '').strip
          self_closing = false
          if attrs.end_with? '/'
            # Self closing tag
            self_closing = true
            attrs = attrs.strip[0...attrs.length-1]
          elsif tag_name.end_with? '/'
            # Self closing tag
            self_closing = true
            tag_name = tag_name.strip[0...tag_name.length-1]
          elsif always_self_close_list.include? tag_name
            # Treat as a self closing tag
            self_closing = true
          elsif tag_name == 'br'
            self_closing = true
          end
          attr_hash = {}
          for attr in attrs.split(' ')
            attr = attr.strip
            next if attr.empty?
            k, v = attr.split('="')
            next if v.nil?
            attr_hash[k] = v[0...v.length-1]
          end
          # Children
          children = []
          while not text.empty? \
          and ((new_child, text = parse_text.call(text))[0][2] != nil \
          or (new_child and always_self_close_list.include? new_child[0].downcase))
            children.push new_child if new_child[2] != nil
          end unless self_closing
          closing = nil
          if (text.nil? or text.empty?) and new_child and new_child[2] != nil
            # End of stream. This tag has no closing tag.
            closing = "!#{tag_name}" unless self_closing
          elsif not new_child.nil? and new_child[0] != tag_name
            # Tag does not match opening tag
            closing = "-#{new_child[0]}"
          end
          return [[tag_name, attr_hash, children, closing], text]
        end
      else
        # A text node
        pos = text.index '<'
        if pos.nil?
          value, rest = text, ''
        else
          value, rest = text[0...pos], text[pos...text.length]
        end
        return [[_text, {}, [], value], rest]
      end
      raise "processing broke on " + text.inspect
    end
    def render_node(node)
      # Converts the node tree format parsed above back into html.
      if node[0] == '#comment'
        return "<!--#{node[3]}-->"
      elsif node[0] == '#text'
        return node[3]
      elsif node[0] == 'br'
        return '<br/>'
      else
        attrs = node[1].entries.map{|x,y| "#{x}=\"#{y}\""}
        attrs = ' ' + attrs.join(' ') unless attrs.empty?
        content = node[2].map{|x| render_node(x)}.join('')
        return "<#{node[0]}#{attrs}>#{content}</#{node[0]}>"
      end
    end
    sanitize_nodes = lambda do |nodes|
      # Clean up nodes we don't want, and put appropriate escapes into the
      # text nodes.
      out_nodes = []
      for node in nodes
        name = node[0].downcase
        if name == _text
          # Escape '<' and '>'
          node[3].gsub!('<', '&lt;')
          node[3].gsub!('>', '&gt;')
          # Escape any non-entity ampersands
          node[3].gsub!(/&(?!(?:[a-z]+|#[0-9]+);)(.*?;?)/, '&amp;\1')
          out_nodes.push(node)
        elsif name == _comment
          node[3].gsub!('--', '- - ') # double dash is illegal in comments
          out_nodes.push(node)
        elsif not allowed_tags.include? name
          if true # "<!--xxx-->" comment bad nodes
            out_nodes.push([_comment, {}, [], "<#{name}>"])
            for node in sanitize_nodes.call(node[2])
              out_nodes.push(node)
            end
            out_nodes.push([_comment, {}, [], "</#{name}>"])
          else # "&gt;xxx&lt;" escape bad nodes
            out_nodes.push([_text, {}, [], "&lt;#{name}&gt;"])
            for node in sanitize_nodes.call(node[2])
              out_nodes.push(node)
            end
            out_nodes.push([_text, {}, [], "&lt;/#{name}&gt;"])
          end
        elsif not node[3].nil? and node[3].start_with? '!'
          # Unmatched tag - assume not to have contents
          out_nodes.push [node[0], node[1], [], nil]
          sanitize_nodes.call(node[2]).each {|x|
            out_nodes.push x
          }
        else
          node[2].replace(sanitize_nodes.call(node[2]))
          out_nodes.push(node)
        end
      end
      return out_nodes
    end
    tidy_nodes = lambda do |nodes|
      # This function restructures and tidies by copying what we need into
      # these output variables. It assumes that it's outer container is a block
      # container and thus should have para tags around it's text content.

      # All completed paragraphs
      paras = []

      # The current paragraph
      # current_para[0] => tag name
      # current_para[1] => hash or attributes. never nil
      # current_para[2] => array of children. nil for a lone closing tag
      # current_para[3] => text value of text or comment node, nil otherwise
      current_para = ['p', {}, [], nil]

      new_para = lambda do
        fix_ws = lambda do
          while current_para[0] == 'p' and (not current_para[2].empty?) and (current_para[2].first[0] == _text and current_para[2].first[3].strip.empty?)
            current_para[2].shift
          end
          while current_para[0] == 'p' and (not current_para[2].empty?) and (current_para[2].last[0] == _text and current_para[2].last[3].strip.empty?)
            current_para[2].pop
          end
        end
        fix_ws.call()
        while (not current_para[2].empty?) and current_para[2].first[0] == 'br'
          current_para[2].shift
          fix_ws.call()
        end
        while (not current_para[2].empty?) and current_para[2].last[0] == 'br'
          current_para[2].pop
          fix_ws.call()
        end
        if current_para[0] != 'p' or not current_para[2].empty?
          paras.push current_para
          current_para = ['p', {}, [], nil]
        end
      end
      # This inner function handles paragraph reorganisation within a block
      # element, and it sometimes recurses to flatten the structure.
      handle_nodes = lambda do |nodes|
        for node in nodes
          # Skip comments
          if node[0] == _comment
            if current_para[2].empty?
              paras.push node
            else
              current_para[2].push node
            end
            next
          end
          if node[0] == _text
            # Text nodes are to be split in to paras at double line breaks,
            # and <br> tags inserted at single line breaks
            text_paras = node[3].split("\n\n")
            first = true
            # text_paras = text_paras.select{|para| not para.strip.empty?}
            text_paras.each do |para|
              new_para.call() if not first
              first_line = true
              for line in para.split("\n")
                if (true or not line.empty?)
                  if (not first_line)
                    current_para[2].push(['br', {}, [], nil])
                  end
                  current_para[2].push([_text, {}, [], line])
                  first_line = false
                end
              end
              first = false
            end
            next
          end
          if node[0] == 'p'
            new_para.call()
            # Just handle the contents
            handle_nodes.call(node[2])
            # A dummy value to preserve the paragraph break.
            current_para.push [_text, {}, [], '']
            next
          end
          name = node[0].downcase
          if block_tags_list.include? name
            # All block tags require new paras inside
            sub_nodes = tidy_nodes.call(node[2])
            node[2].replace(sub_nodes)
            # handle contents
            if block_cont_tags_list.include? name
              # Block level containers should be paragraph siblings
              # End the current para, and overwrite the generated new para with a
              # sibling #{node}, then start a new para
              new_para.call()
              current_para.replace(node)
              new_para.call()
            else
              # Otherwise, add to the text
              current_para[2].push node
            end
          else
            if always_self_close_list.include? name
              current_para[2].push [name, node[1], [], nil]
              handle_nodes[node[2]]
            else
              # Inline elements are handled here
              # An inline tag should never be alone in a para because of us. :(
              current_para[2].push(node)
              if false and inl_cont_tags_list.include? name
                # Inline containers need further paras, according to the
                # previouss code, but it looks tidier to me without, hence
                # the 'false' in the condition above.
                node[2].replace(tidy_nodes.call(node[2]))
              end
            end
          end
        end
      end
      handle_nodes.call(nodes)
      new_para.call()
      if not block_container
        # If our container is a block container, then remove outer <p> tag.
        out_nodes = []
        for para in paras
          for node in para[2]
            out_nodes.push(node)
          end
        end
        return out_nodes
      end
      return paras
    end
    parse_html = lambda do |html_text|
      nodes = []
      return nodes if html_text.nil?
      while not (html_text.nil? or html_text.empty?)
        node, html_text = parse_text.call(html_text)
        unless node[2].nil?
          # Don't record the stray end tags, but keep looping to get as much
          # data as possible from the fragment.
          nodes.push node
        end
      end
      # Check for any unclosed wrapper tags that might indicate a stray
      # opening tag near the start, and turn them into self-closing tags.
      prefix_nodes = []
      while not nodes.empty? and not [_text, _comment].include? nodes.first[0] \
      and not nodes.first[3].nil? and nodes.first[3].start_with? '!'
        # A node that is not a text or comment but has a '-...' value in the
        # fourth field is an unmatched closing tag. A '!...' value indicates
        # an unclosed opening tag.
        unclosed = nodes.shift
        unclosed[2].reverse.each{|x| nodes.insert(0, x)}
        prefix_nodes.insert(0, [node[0], node[1], [], nil])
      end
      return prefix_nodes + nodes
    end

    # The actual program
    # 1. Parse text into HTML 'tree'
    raw_nodes = parse_html.call(text_input)
    raise text_input.inspect if raw_nodes.nil?
    nodes = raw_nodes
    # 2. Do our tidying up
    if sanitize
      nodes = sanitize_nodes.call(nodes)
      raise raw_nodes.inspect if nodes.nil?
    end
    if tidy
      nodes = tidy_nodes.call(nodes)
      raise raw_nodes.inspect if nodes.nil?
    end
    # 3. Render and return
    return nodes.map{|x| render_node(x)}.join('')
  end

  # adds paragraphs and newlines, then gets rid of doubled ones
  def add_paragraph_tags_for_display(text)
    return clean_fully(text, @@all_html_tags)
  end

end

