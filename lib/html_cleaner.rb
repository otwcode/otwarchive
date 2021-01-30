# note, if you modify this file you have to restart the server or console
module HtmlCleaner

  class LinebreakRender < Redcarpet::Render::XHTML
    @@MD_CHARS = Regexp.escape("`*_{}[]()#+-.!=~")
    @@BLOCK_TAGS = %w[address blockquote center dd div dl dt h1 h2 h3 h4 h5 h6 hr ol p pre table ul]
  
    def preprocess(doc)
      # Escape markdown special characters
      escaped = doc.gsub(Regexp.new("([#{@@MD_CHARS}])")) { "\\#{Regexp.last_match(1)}" }

      # Newlines after block elements (required by markdown spec)
      escaped = escaped.gsub(%r{(?:</(?:#{@@BLOCK_TAGS.join('|')})>|<hr( /)?>)\n?(?=.)}) { |m| "#{m}\n\n" }
      # Redcarpet doesn't think <center> is a block tag, so we need to convert it temporarily
      # to something that is, and we need to do the opposite for ins and del
      # (Pending https://github.com/vmg/redcarpet/pull/702)
      escaped = escaped.gsub(%r{<center>((?:\n|.)*?)</center>}) { "<div class=\"temp-transform-center\">#{Regexp.last_match(1)}</div>"}
      escaped = escaped.gsub(%r{<del>((?:\n|.)*?)</del>}) { "<span class=\"temp-transform-del\">#{Regexp.last_match(1)}</span>"}
      escaped = escaped.gsub(%r{<ins>((?:\n|.)*?)</ins>}) { "<span class=\"temp-transform-ins\">#{Regexp.last_match(1)}</span>"}

      # Markdown condenses extra newlines, but the user probably wanted them.
      escaped
    end

    def postprocess(doc)
      # Unescape markdown chars
      unescaped = doc.gsub(Regexp.new("\\\\([#{@@MD_CHARS}])")) { Regexp.last_match(1) }
  
      # Unconvert <center> from <div>, and <del> and <ins> from <span>
      unescaped = unescaped.gsub(%r{<div class="temp-transform-center">((?:\n|.)*?)</div>}) { "<center>#{Regexp.last_match(1)}</center>" }
      unescaped = unescaped.gsub(%r{<span class="temp-transform-ins">((?:\n|.)*?)</span>}) { "<ins>#{Regexp.last_match(1)}</ins>" }
      unescaped = unescaped.gsub(%r{<span class="temp-transform-del">((?:\n|.)*?)</span>}) { "<del>#{Regexp.last_match(1)}</del>" }
      unescaped.chomp
    end
    
  end
  
  def render_input(input)
    renderer = Redcarpet::Markdown.new(LinebreakRender.new(hard_wrap: true, xhtml: true, link_attributes: { rel: "nofollow" }), lax_spacing: true, disable_indented_code_blocks: true)
    renderer.render(input)
  end

  # Process input, and try to fix up to MAX_COUNT recoverable errors in tag/quote mismatching
  # This works recursively on input, so an upper limit is needed to prevent infinite
  # recursion when encountering an unfixiable error.
  class MismatchedTagFixer
    @@MAX_COUNT = 10

    def initialize
      @count = 0
    end

    # Scrape the list of currently open tags from an error string and split
    # them into an array.
    def open_tags(str)
      tag_block = str.sub(/.*Currently open tags: (.*?)\.$/, '\1').chomp
      tag_block.split(", ")
    end

    # Scrape character column from error, and return
    # as a zero-indexed offset
    def index_from_err(str)
      str.sub(/\d+:(\d+).*/, '\1').to_i - 1
    end

    # Scrape line number from error, and return
    # the matching line from input.
    def line_from_err(str, input)
      line_no = str.sub(/(\d+):.*/, '\1').to_i - 1
      lines = input.lines
      lines[line_no].chomp
    end

    def read(input)
      @count += 1
      updated = false

      doc = Nokogiri::HTML5.fragment(input, max_errors: -1) 
      # We're only set up to fix a limited set of error types, so grab the first error
      # that appears to match one of those.
      err = doc.errors.detect do |e|
        e.to_s.include?("ERROR: That tag isn't allowed here") || e.str1 == ('eof-in-tag') || e.str1 == ('unexpected-character-in-unquoted-attribute-value') || e.to_s.include?('ERROR: Premature end of file ')
      end

      if err

        if err.to_s.include?("ERROR: That tag isn't allowed here")
          # Missing start tag, or unclosed tag inside a block.
          # Grab column/line data and open tags from the error
          lines = err.to_s.lines
          i = self.index_from_err(lines[0])
          tags = self.open_tags(lines[0])
          block = self.line_from_err(lines[0], input)
          # Get the line we're working with, and then use the index to remove everything before the 
          # error (ie, "something</i> bar" goes to "</i> bar")
          segment = block[i..]

          if tags.length == 1
            # only one tag open (html), so we should delete the closing tag
            cut = segment.index(">") + 1
            fixed = segment[cut..]

            fixed_line = block.sub(segment, fixed)
            input = input.sub(block, fixed_line)
          else
            # We need to check if this tag was previously opened
            # and if so, close the tags inbetween.
            bad_tag = segment.sub(%r{</(\w*)(.|\n)*}, '\1')
            tag_i = tags.rindex(bad_tag)

            if tag_i
              # Tag was opened, closer intermediate tags
              tags_to_close = tags[(tag_i + 1)..]
              close_str = "</#{tags_to_close.join('></')}>"
              fixed_line = block.sub(segment, close_str + segment)
              input = input.sub(block, fixed_line)
            else
              # Tag was not opened, delete it.
              cut = segment.index(">") + 1
              fixed = segment[cut..]

              fixed_line = input.sub(segment, fixed)
              input = input.sub(block, fixed_line)
            end
          end

          updated = true


        end

        if err.str1 == ('eof-in-tag')
          # Missing close quote
          # (this error can also mean missing close bracket, but that's not handled)
          # NOTE: this only works sometimes - if the tag with the bad quote is nested within
          # another tag, Nokogiri will eat it and we won't have enough info to reconstruct.

          # Take what we have of the doc (ie, what got parsed up until the bad tag) and grab a chunk
          # of the end of it, so we can find our place in the original input
          matcher = doc.to_html[-20..-1] || doc.to_html
          # Dump any trailing close tags, as they may have been added by nokogiri
          matcher = matcher.sub(%r{(.*?)(</.*>)*$}, '\1')

          # Look for the first opening tag after the end of parsed input, skipping any closing tags
          # (in case we stripped one that was in the original input, as we can't tell)
          tag = input.sub(%r{(?:.|\n)*?#{matcher}(?:</.*>)*(<[^/](?:.|\n)*?>)(?:.|\n)*}, '\1')

          # Split attributes on = (ie, <p class='one' style='two'> becomes ["<p class", "'one' style", "'two'>"])
          # Ignore any attributes with two matching quotes followed by either a space and text, or >
          bad_attrs = tag.split("=").reject { |attr| attr.match?(/('|").+\1((?: +.+)|>)$/) }
          # Grab the opening quote, and then insert it before the space + text or > spot.
          bad_attrs.each do |attr|
            fixed = attr.sub(/('|")(.+)((?: +.+)|>)$/, '\1\2\1\3')
            input = input.sub(attr, fixed)
          end

          updated = true

        end

        if err.str1 == ("unexpected-character-in-unquoted-attribute-value")
          # Missing start quote
          # Grab line/col from the error info and get the correct input line to fix
          lines = err.to_s.lines
          i = self.index_from_err(lines[0])
          block = self.line_from_err(lines[0], input)

          # Grab the chunk of the line up through the bad quote 
          # (ie, "hello <span class=something'>yes" goes to hello "<span class=something'")
          segment = block[1..i]

          # last char of this is quote, and the last = is what we need to insert it after
          ch = segment[-1]
          insert_i = segment.rindex("=")
          # Need to make a copy of block, because insert modifies self, and we need the block
          # to know where to replace the text
          fixed = String.new(block).insert(insert_i + 2, ch)
          input = input.sub(block, fixed)

          updated = true


        end

        if err.to_s.include?("ERROR: Premature end of file ")
          # Missing close tag
          lines = err.to_s.lines
          # scrape list of unclosed tags from error str
          tags = open_tags(lines[0])
          end_block = lines[1].chomp

          # Work outward in, closing the last opened tag first.
          bad_tag = tags[-1]
          # Try the simple case (mismtched tag is in last line of input) first
          start_count = end_block.scan(/<#{bad_tag}( .*)?>/).length
          end_count = end_block.scan(%r{</#{bad_tag}>}).length
          # More start tags than ends tags = we have an unclosed start
          if (start_count - end_count).positive?
            input += "</#{bad_tag}>"
          else
            # Gotta do this the hard way - search the tag nodes for one
            # that contains our ending line
            doc.search("#{bad_tag}").each do |node|
              next unless node.inner_html.include?(end_block.chomp)

              content = node.to_html
              chomped = node.to_html.chomp("</#{node.name}>")        
              content = chomped.sub(/\n\n/, "</#{node.name}>\n\n") if content.include?("\n\n")
              # check with optional ending tag in case our bad tag has another of itself nested inside
              # (ie, "<i>some text <i>closed properly</i> something")
              input = input.sub(%r{#{chomped}(?:</#{node.name}>)?}, content)
            end
          end

          updated = true

        end

      end
      if updated && @count < @@MAX_COUNT

        # We've hopefully fixed the mismatch, reprocess.
        doc = self.read(input)
      end

      doc
    end
  end

  # step 1b
  def clean_inlines(node)
    inline = %w[a abbr acronym b big br cite code del dfn em i img ins kbd q s samp small span strike strong sub sup tt u var]
    return unless inline.include?(node.name) && node.content.include?("\n")

    start_tag = node.to_html.sub(/(<#{node.name}.*?>)(?:\n|.)*/, '\1')
    node.replace(node.to_html.gsub("\n\n", "</#{node.name}>\n\n#{start_tag}"))
  end

  # step 1c
  def parse_blocks(node)
    can_contain_p = %w[blockquote center div]
    return unless node.elem? && can_contain_p.include?(node.name) && node.content.strip.include?("\n")

    node.inner_html = render_input(node.inner_html)
  end

  def format_whitespace(node)
    # Only reformat whitespace inside non-empty top level nodes.
    return unless node.text? && node.parent && node.parent.name == "#document-fragment" && node.to_html.match?(/[^\s|\n]+$/)

    formatted = node.to_html.gsub(/\s*\n\s*\n\s*\n\s*/, "\n\n&nbsp;\n\n")
    node.replace(formatted)
  end
  
  def format_xml(input)
    # step 1a
    # Nokogumbo is aggressively pedantic about table formatting
    input = input.gsub(%r{(<table.*?>)(.*)((?:</thead>)?<tr>.*)</table>}, '\1\2<tbody>\3</tbody></table>')
    doc = MismatchedTagFixer.new.read(input)

    # If the doc doesn't have p tags, convert br to newline for processing
    if doc.children.all? { |n| n.name != "p"}
      doc.inner_html = doc.inner_html.gsub(%r{<br ?/?>\n*}, "\n")
    end
    doc.traverse do |node|
      clean_inlines(node)
      parse_blocks(node)
      format_whitespace(node)
    end
    doc.to_html
  end
  
  # Strip out HTML linebreak elements when they have corresponding
  # newlines. This is for the edit view, so we don't confuse users
  # with surprise HTML, and so we don't have issues with generating
  # duplicate HTML linebreak elements on each edit/save cycle. 
  def unparse(input)
    return "" if input.nil?

    input.gsub(%{\n*<br(?: /)?>\n*}, "\n").gsub(%r{\n*</?p>\n*}, "\n")
  end
  
  
  # Processing steps:
  # 1. Parse input with Nokogiri. This allows us to do some cleanup steps that the Markdown renderer doesn't handle, and catch unclosed tags.
  #   1a) Close off any mismatched tags so they don't eat the entire document.
  #   1b) Rewrap inline tags with contents that cross what will become a paragraph boundary
  #     ("<i>paragraph 1 \n\n paragraph 2</i>" is valid markup, and will italicize everything,
  #     but "<p><i>paragraph 1</p><p>paragraph 2</i></p>" is not, and will only italicize the
  #     first paragraph at best on modern browsers).
  #   1c) Parse contents of block-level tags (Markdown assumes that if you've put stuff inside an HTML
  #     block, you are willing to add your own whitespace tags)
  # 2. Run Nokogiri output through Redcarpet, to use a well-tested library for linebreak conversions.
  
  def format_linebreaks(input)
    formatted = format_xml(input)
    formatted = formatted.gsub(%r{(<br( /)?>)\n}, '\1')
    render_input(formatted)
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

  # yank out bad end-of-line characters and evil msword curly quotes
  def fix_bad_characters(text)
    return "" if text.nil?

    # get the text into UTF-8 and get rid of invalid characters
    text = text.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")

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
        transformers << OTWSanitize::EmbedSanitizer.transformer
        transformers << OTWSanitize::MediaSanitizer.transformer
      end
      if ArchiveConfig.FIELDS_ALLOWING_CSS.include?(field.to_s)
        transformers << OTWSanitize::UserClassSanitizer.transformer
      end
      # Now that we know what transformers we need, let's sanitize the unfrozen value
      if ArchiveConfig.FIELDS_ALLOWING_CSS.include?(field.to_s)
        unfrozen_value = format_linebreaks(Sanitize.clean(fix_bad_characters(unfrozen_value),
                                Sanitize::Config::CSS_ALLOWED.merge(transformers: transformers)))
      else
        # the screencast field shouldn't be wrapped in <p> tags
        unfrozen_value = format_linebreaks(Sanitize.clean(fix_bad_characters(unfrozen_value),
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
    unfrozen_value.gsub!(/&amp;/, "&") unless (ArchiveConfig.FIELDS_ALLOWING_HTML_ENTITIES + ArchiveConfig.FIELDS_ALLOWING_HTML).include?(field.to_s)
    unfrozen_value
  end
  
  
  ### STRIPPING FOR DISPLAY ONLY
  # Regexps for stripping particular tags and attributes for display.
  # These assume they are running on well-formed XHTML, which we can do
  # because they will only be used on already-cleaned fields.

  # strip img tags
  def strip_images(value)
    value.gsub(/<img .*?>/, "")
  end

  def add_break_between_paragraphs(value)
    return "" if value.blank?

    value.gsub(%r{\s*</p>\s*<p>\s*}, "</p><br /><p>")
  end

  def strip_html_breaks_simple(value)
    return "" if value.blank?

    value.gsub(/\s*<br ?\/?>\s*/, "<br />\n").
      gsub(/\s*<p[^>]*>\s*&nbsp;\s*<\/p>\s*/, "\n\n\n").
      gsub(/\s*<p[^>]*>(.*?)<\/p>\s*/m, "\n\n" + '\1').
      strip
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
  
end
