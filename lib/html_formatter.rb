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
    # UPDATE: These items, if found unclosed, will be assumed to contain all
    # following text nodes. Other nodes will be assumed to have no content.
    inl_cont_tags_list = ['h1','h2','h3','h4','h5','h6','i','em','big','small','cite','b','strong','del','ins','caption','code', 'li']

    # The various functions that do the real work. Some of these used to be
    # recursive, but have been reduced to a monolithic loop and a state stack
    # which is unlimited, unlike the function stack. See 'start_node' and
    # 'end_node' for stack pushing and popping.
    # Some are still recursive. 'tidy_nodes' in particular cannot deal with a
    # html element depth of maybe 800, but that's going to involve another
    # fiddly loop optimisation that I don't want to do unless it's necessary.
    parse_text = lambda do |text|
      return [], '' if text.nil?
      nodes = []
      state_stack = []
      return_node = lambda do |node, text2|
        nodes.push node unless node.nil?
        text = text2
        return true
      end
      start_node = lambda do |node, text2|
        state_stack.push [node, nodes]
        nodes = node[2]
        text = text2
      end
      end_node = lambda do |tag, text2|
        text = text2
        if state_stack.empty?
          # Discard bogus end node
          return true
        else
          node, nodes = state_stack.pop
          closing = nil
          if (text.nil? or text.empty?) and tag and tag[2] != nil
            # End of stream. This tag has no closing tag.
            closing = "!#{node[0]}"
          elsif not tag.nil? and tag[0] != node[0]
            # Tag does not match opening tag
            closing = "-#{tag[0]}"
          end
          node[3] = closing
          ret = return_node[node, text]
          return ret
        end
      end
      # Takes a snippet of html. returns: nodes, leftover_text
      # nodes is a list where each node takes the form:
      # (tagname, attribute_hash, child_list, text_value)
      # with the special tagnames '#text' and '#comment' having a text_value.
      while not text.nil? and not text.empty?
        if text[0..0] == '<'
          # A tag
          pos = text.index('<', 1)
          closing_bracket_pos = text.index('>')
          if pos && closing_bracket_pos && (pos < closing_bracket_pos)
            # If another lt before gt then it's a text node.
            return_node[[_text, {}, [], text[0...pos]], text[pos...text.length]] and next or break
          elsif text[1..1] == '!'
            # It's a comment or we drop it
            if text[2..3] == '--'
              value, rest = text.split('-->', 2)
              value = value[4..value.length]
              return_node[[_comment, {}, [], value], rest] and next or break
            else
              return_node[nil, text.split('>', 2)[1]] and next or break
            end
          elsif text[1..1] == '?'
            return_node[nil, text.split('>', 2)[1]] and next or break
          elsif text[1..1] == '/'
            # A closing tag
            name, rest = text.split('>', 2)
            name = name[2..name.length].strip
            end_node[[name, {}, nil, nil], rest] and next or break
          else
            # Either an open tag or a self closing tag.
            # Attributes
            tag, text = text.split('>', 2)
            tag = tag[1..tag.length]
            tag_name, attrs = tag.split(' ', 2) 
            # atempt to prevent nil errors from empty string split
            tag_name = (tag_name || '').strip || ''
            attrs = (attrs || '').strip || ''
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
              k, v = attr.split('="', 2)
              next if v.nil? or v.empty?
              attr_hash[k] = v[0...v.length-1]
            end
            # Children
            children = []
            node = [tag_name, attr_hash, children, '-NOT-SET-']
            if self_closing
              node[3] = nil
              return_node[node, text] and next or break
            else
              start_node[node, text]
              next
            end
          end
        else
          # A text node
          pos = text.index '<'
          if pos.nil?
            value, rest = text, '' 
          elsif !(text.index('>'))
            value, rest = text.gsub('<', '&#60;'), ''
          else
            value, rest = text[0...pos], text[pos...text.length]
          end
          return_node[[_text, {}, [], value], rest] and next or break
        end
      end
      while not state_stack.empty?
        end_node[['#none', {}, [], nil], '']
      end
      return nodes
    end
    def render_node(node)
      # Converts the node tree format parsed above back into html.
      if node[0] == '#comment'
        return "<!--#{node[3]}-->"
      elsif node[0] == '#text'
        return node[3]
      elsif node[0] == 'br'
        return '<br/>'
      elsif node[0] == 'hr'
        return '<hr/>'
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
      _include = '#include'
      out_nodes = []
      work_list = []
      push_node = lambda do |out_list, node|
        work_list.push [[_include, node], out_list]
      end
      push_work = lambda do |lst, node|
        work_list.push [node, lst]
      end
      for node in nodes
        push_work[out_nodes, node]
      end
      while not work_list.empty?
        node, out_list = work_list.shift
        next if node.nil?
        name = node[0].downcase
        if name == _include
          out_list.push node[1]
        elsif name == _text
          # Escape '<' and '>'
          node[3].gsub!('<', '&lt;')
          node[3].gsub!('>', '&gt;')
          # Escape any non-entity ampersands
          node[3].gsub!(/&(?!(?:[a-z]+|#[0-9]+);)(.*?;?)/, '&amp;\1')
          push_node[out_list, node]
        elsif name == _comment
          node[3].gsub!('--', '- - ') # double dash is illegal in comments
          push_node[out_list, node]
        elsif not allowed_tags.include? name
          if true # "<!--xxx-->" comment bad nodes
            push_node[out_list, [_comment, {}, [], "<#{name}>"]]
            for n in node[2]
              push_work[out_list, n]
            end
            push_node[out_list, [_comment, {}, [], "</#{name}>"]]
          else # "&gt;xxx&lt;" escape bad nodes
            push_node[out_list, [_text, {}, [], "&lt;#{name}&gt;"]]
            for n in node[2]
              push_work[out_list, n]
            end
            push_node[out_list, [_text, {}, [], "&lt;/#{name}&gt;"]]
          end
        elsif not node[3].nil? and node[3].start_with? '!'
          # Unmatched tag - assume not to have contents
          children = []
          push_node[out_list, [node[0], node[1], children, nil]]
          if inl_cont_tags_list.include? name
            child_list = children
          else
            child_list = out_list
          end
          for n in node[2]
            child_list = out_list unless n[0] == _text
            push_work[child_list, n]
          end
        else
          cnodes = node[2].dup
          node[2].replace([])
          push_node[out_list, node]
          for n in cnodes
            push_work[node[2], n]
          end
        end
      end
      for n in out_nodes
        raise [n, out_nodes, text_input].inspect if n[2] == nil
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
            text_paras = node[3].gsub("\n\n\n+", "\n\n").split("\n\n", -1)
            first = true
            # text_paras = text_paras.select{|para| not para.strip.empty?}
            text_paras.each do |para|
              new_para.call() if not first
              first_line = true
	      # String#split method doesn't work as one might expect here.
	      # I think "".split('x') should give [""], not []
	      if para == ''
		lines = [para]
	      else
                lines = para.split("\n", -1)
	      end
              for line in lines
                if not first_line
                  current_para[2].push(['br', {}, [], nil])
                end
                current_para[2].push([_text, {}, [], line]) if line
                first_line = false
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
                # previous code, but it looks tidier to me without, hence
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

    # The actual program
    # 1. Parse text into HTML 'tree'
    raw_nodes = parse_text.call(text_input)
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
    txt = nodes.map{|x| render_node(x)}.join('')
    return txt
  end

  # adds paragraphs and newlines, then gets rid of doubled ones
  def add_paragraph_tags_for_display(text)
    return clean_fully(text, @@all_html_tags)
  end

end