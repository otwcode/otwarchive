# note, if you modify this file you have to restart the server or console
module HtmlFormatter
  include SanitizeParams

  # clean up the break tags and convert them into newlines
  # before saving
  def cleanup_break_tags_before_adding(text)
    text.gsub!(/<br\s*?\/?>/i, "\n")
    return text
  end
  
  # clean up the break tags after they have been added for display
  def cleanup_break_tags(text)
    text.gsub!(/<br\s*\/?>/i, "<br />")
    while text.gsub!(/<br \/><br \/><br \/>/im, "<br /><br />")
      # keep going
    end
    
    return text
  end

  # clean up tags
  def cleanup_and_format(text)
    text = cleanup_paragraph_tags(cleanup_break_tags_before_adding(close_tags(strip_comments(text))))
    return text
  end
  
  def sanitize_and_format_for_display(text, options = {})
    text = add_paragraph_tags_for_display(sanitize_whitelist(text, options))
  end
  
  # This is future-planning - titles are currently stripped of all html in order to make sort and search simpler, so there should be no tags in titles which need sanitize in the view. 
  def sanitize_title_for_display(text, options = {:tags => ['a href', 'b', 'br', 'p', 'i', 'em', 'strong', 'strike', 'u', 'ins', 'q', 'del', 'cite', 'blockquote', 'pre', 'code', 'small', 'sup', 'sub']})
    sanitize_whitelist(text, options)
  end
 
  # A more limited display option for comments and summaries
  def sanitize_limit_and_format_for_display(text, options = {:tags => ['a href', 'b', 'big', 'blockquote', 'br', 'center', 'cite', 'code', 'del', 'em', 'i', 'img', 'ins', 'p', 'pre', 'q', 'small', 'strike', 'strong',  'sub', 'sup', 'u']})
    text = add_paragraph_tags_for_display(sanitize_whitelist(text, options))
  end
  
    # A more limited display option which strips obtrusive tags for index views.
  def sanitize_strip_images_and_format_for_display(text, options = {:tags => ['a href', 'b', 'big', 'blockquote', 'br', 'center', 'cite', 'code', 'del', 'em', 'i', 'ins', 'p', 'pre', 'q', 'small', 'strike', 'strong', 'sub', 'sup', 'u']})
    text = add_paragraph_tags_for_display(sanitize_whitelist(text, options))
  end

  # cleans up doubled paragraph/newline tags
  def cleanup_paragraph_tags(text)
    # Now we want to replace any cases where these have been doubled -- ie, 
    # where a new paragraph tag is opened before an old one is closed
    text.gsub!(/<p>\s*<p>/im, "<p>")
    text.gsub!(/<\/p>\s*<\/p>/im, "</p>")
    while text.gsub!(/<br\s*\/>\s*<p>/im, "<p>")
    end

    while text.gsub!(/<p>\s*<br\s*\/>/im, "<p>")
    end

    #<pre> blocks shouldn't contain any linebreak markup
    a = text.scan(/<pre>.*?<\/pre>/im) 
    a.each do |pre|
      text = text.sub(pre.to_s(), pre.to_s().gsub(/<(\/)?(br|p)(\s)?(\/)?>/, "")) 
    end

    # and where there are empty paragraphs
    text.gsub!(/<p>\s*<\/p>/im, "")
    
    # also get rid of blank paragraphs inserted by tinymce
    text.gsub!(/<p>&nbsp;<\/p>/, "")
    
    return cleanup_break_tags(text)
  end

  # adds paragraphs and newlines, then gets rid of doubled ones
  def add_paragraph_tags_for_display(text)
    #The following are lists of tags according to their valid child elements
    #These tags are block-level
    block_tags_list = ['h1','h2','h3','h4','h5','h6','div','blockquote','ul','ol','dl','pre','table', 'center']
    #Block inline container tags - These tags will have both text and block-level nodes
    block_inl_cont_tags_list = ['li','dd','dt','td','th','a']
    #These tags will only contain block-level nodes
    block_cont_tags_list = ['div','blockquote']
    #These tags can only contain inline nodes
    inl_cont_tags_list = ['h1','h2','h3','h4','h5','h6','i','em','big','small','cite','b','strong','del','ins','caption','code']
    #These tags act as containers and can't have <br> or <p> tags preceding
    cont_tags_list = ['tbody','col','tr','caption']
    #Matches the properties of an HTML tag (accounts for > inside properties)
    tag_props = /((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)\/?/

    #Create the strings to be used in the regexes
    block_tags = block_tags_list.join("|")
    block_inl_cont_tags = block_inl_cont_tags_list.join("|")
    block_cont_tags = block_cont_tags_list.join("|")
    inl_cont_tags = inl_cont_tags_list.join("|")
    cont_tags = cont_tags_list.join("|")

    #Make certain we have a container paragraph
    text = "<p>" + text.to_s.dup + "</p>"

    # Standardise our linebreak chars
    text.gsub!(/\r\n?/, "\n")

    #Create paragraphs around block-level tags (ie <h1></h1> goes to </p><h1></h1><p>)
    text.gsub!(/<\/(#{block_tags}#{tag_props})>(\s|\n)?(?!<(#{block_tags}))/im, '</\1>\2'+"\n<p>") # Block tag not followed by another block tag...
    text.gsub!(/<(#{block_tags}#{tag_props})>/im, '</p><\1>') #Close any previous paragraph tags
    text.gsub!(/<\/(#{block_tags}#{tag_props})>(\s)?<\/p>/im, '</\1>') #Cleans up (won't be a </p> with a preceding block tag)

    # make sure there are paragraphs inside blockquotes and divs
    text.gsub!(/(<(#{block_cont_tags})#{tag_props}>)/, '\1<p>')
    text.gsub!(/(<\/(#{block_cont_tags})>)/, '</p>\1')

    #These tags can't contain paragraphs (doesn't cope with nested tags - not sure if this will be a problem)
    elements = text.scan(/(<(#{inl_cont_tags})#{tag_props}>.*?<\/\2>)/imx) 
    elements.each do |el|
      text = text.sub(el[0].to_s(), el[0].to_s().gsub(/\n/, "\n<br />")) 
    end

    #Closes and reopens <p> tags for double lines (but not before a block level or container tag)
    text.gsub!(/\n\s?\n(?!<\/?(#{block_tags}|#{block_inl_cont_tags}|#{cont_tags}))/, "</p>\n\n<p>")

    #Add initial and closing paragraphs inside table cells and list items where necessary
    elements = text.scan(/(<(#{block_inl_cont_tags})#{tag_props}>(.*?)<\/(#{block_inl_cont_tags})>)/im) 
    elements.each do |el|
      par = el[0].to_s().dup
      contents = el[5].to_s().dup #Group 5 is the contents of the tag
      if /<\/p>\n\n<p>/ =~ contents then
        contents = "<p>" << contents << "</p>"
      end
      text = text.sub(par, par.sub(el[5].to_s(), contents)) 
    end

    #Adds linebreaks, but only where it's appropriate
    text.gsub!(/(([^\n])\n)(?!<\/?(p|br|#{block_tags}|#{block_inl_cont_tags}|#{cont_tags}))(?![\n])/, '\2<br />'<<"\n") #Not putting them before block level elements
    text.gsub!(/(<\/?(p|#{block_tags}|#{block_inl_cont_tags}|#{cont_tags})#{tag_props}>)<br \/>/, '\1') #clean out any linebreaks immediately after block level elements

    text = cleanup_and_format(text)
    
    return text
  end

  #closes tags in html (uses http://snippets.dzone.com/posts/show/3822, but
  #modified)
  def close_tags(html)

    # no closing tag necessary for these
    soloTags = ["br","hr"]

    # Analyze all <> elements
    stack = Array.new
    result = html.gsub( /(<.*?>)/m ) do | element |
      if element =~ /\A<\/(\w+)/ then
        # </tag>
        tag = $1.downcase
        if stack.include?(tag) then
          # If allowed and on the stack
          # Then pop down the stack
          top = stack.pop
          out = "</#{top}>"
          until top == tag do
            top = stack.pop
            out << "</#{top}>"
          end
          out
        end
      elsif element =~ /\A<(\w+)\s*\/>/
        # <tag />
        tag = $1.downcase
        "<#{tag} />"
      elsif element =~ /\A<(\w+)/ then
        # <tag ...>
        tag = $1.downcase
        if ! soloTags.include?(tag) then
          stack.push(tag)
        end
        out = "<#{tag}"
        tag = $1.downcase
        while ( $' =~ /(\w+)=("[^"]+")/ )
          attr = $1.downcase
          valu = $2
          out << " #{attr}=#{valu}"
        end
        out << ">"
      end
    end
    
    # eat up unmatched leading >
    while result.sub!(/\A([^<]*)>/m) { $1 } do end
    
    # eat up unmatched trailing <
    while result.sub!(/<([^>]*)\Z/m) { $1 } do end
    
    # clean up the stack
    if stack.length > 0 then
      result << "</#{stack.reverse.join('></')}>"
    end
    
    result
  end
    
end
