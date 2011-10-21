module XhtmlSplitter

  class Error < StandardError
  end

  TAG_PATTERN = /<(\/?)(\w+)(.*?)(\/?)>/

  XSL = Nokogiri::XSLT(File.open("#{Rails.root.to_s}/lib/xhtml_splitter.xsl"))

  
  # Split a string of valid html into chunks that are smaller than
  # maxbytes bytes
  #
  # Algorithm is as follows: convert html to xhtml and split it into
  # multiple lines via xslt at certain tags. (See xslt which tags go
  # on a new line.) Copy xhtml over to the new part line by line,
  # keeping track of opening and closing html tags via a stack. If the
  # new part gets close to maxbytes bytes, stop, close all still-open
  # tags. start with a new part where the still-open tags get
  # re-opened.

  def split_xhtml(html, maxbytes=280*1024)
    return [html] if html.bytesize < maxbytes
    doc = XSL.transform(Nokogiri::XML.parse("<myroot>#{html}</myroot>"))
    html = doc.children.to_s.gsub(/(\A<myroot>)|(<\/myroot>\Z)/, "")

    parts = []
    tag_stack = []
    new_part = ""

    html.each_line do |line|
      new_part += line
      stack_tags(line, tag_stack)
      if new_part.bytesize >= 0.85 * maxbytes
        new_part = close_tags(new_part, tag_stack)
        if new_part.bytesize >= maxbytes
          raise Error, "Part too big."
          # This might happen if the last line before the split is
          # very long. If we actually do see this error in production,
          # we could try to split the line further
        end
        parts << new_part
        new_part = open_tags(tag_stack)
      end
    end

    parts << new_part
    return parts

  end


  # keep track of opening/closing HTML tags
  def stack_tags(html, stack)
    
    html.scan(TAG_PATTERN).each do |match|
      next unless match[3].empty? # self-closing tags, ignore
      if match[0].empty?
        # opening tag, put on stack
        stack << "<#{match[1]}#{match[2]}#{match[3]}>"
      else
        # closing tag, remove from stack
        raise Error, "Found extra closing tag." if stack.empty?
        last = stack[-1].scan(TAG_PATTERN).flatten
        if match[1] == last[1]
          stack.pop
        else
          raise Error, "Found wrong closing tag."
        end
      end  
    end

    return stack
  end

  def close_tags(html, stack)
    stack.reverse_each do |tag|
      tmatch = tag.scan(TAG_PATTERN).flatten
      html += "</#{tmatch[1]}>"
    end
    return html
  end

  def open_tags(stack)
    stack.join("") + "\n"
  end
  
end
