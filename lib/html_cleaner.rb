# note, if you modify this file you have to restart the server or console
module HtmlCleaner
  # If we aren't sure that this field hasn't been sanitized since the last sanitizer version,
  # we sanitize it before we allow it to pass through (and save it if possible).
  # For certain highly visible fields, we might want to be cautious about
  # images. Use image_safety_mode: true to prevent images from embedding as-is.
  def sanitize_field(object, fieldname, image_safety_mode: false)
    return "" if object.send(fieldname).nil?

    sanitizer_version = object.try("#{fieldname}_sanitizer_version")
    sanitized_field =
      if sanitizer_version && sanitizer_version >= ArchiveConfig.SANITIZER_VERSION
        # return the field without sanitizing
        object.send(fieldname)
      else
        # no sanitizer version information, so re-sanitize
        sanitize_value(fieldname, object.send(fieldname))
      end

    sanitized_field = strip_images(sanitized_field, keep_src: true) if image_safety_mode
    sanitized_field
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
      transformers = [
        Sanitize::Config::OPEN_ATTRIBUTE_TRANSFORMER,
        Sanitize::Config::RELATIVE_IMAGE_PATH_TRANSFORMER
      ]
      if ArchiveConfig.FIELDS_ALLOWING_VIDEO_EMBEDS.include?(field.to_s)
        transformers << OtwSanitize::EmbedSanitizer.transformer
        transformers << OtwSanitize::MediaSanitizer.transformer
      end
      if ArchiveConfig.FIELDS_ALLOWING_CSS.include?(field.to_s)
        transformers << OtwSanitize::UserClassSanitizer.transformer
      end
      # Now that we know what transformers we need, let's sanitize the unfrozen value
      if ArchiveConfig.FIELDS_ALLOWING_CSS.include?(field.to_s)
        unfrozen_value = Sanitize.clean(add_paragraphs_to_text(fix_bad_characters(unfrozen_value)),
                                        Sanitize::Config::CSS_ALLOWED.merge(transformers: transformers))
      else
        unfrozen_value = Sanitize.clean(add_paragraphs_to_text(fix_bad_characters(unfrozen_value)),
                                        Sanitize::Config::ARCHIVE.merge(transformers: transformers))
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

  def add_paragraphs_to_text(text)
    # Adding paragraphs in place of linebreaks
    doc = Nokogiri::HTML.fragment("<myroot>#{text}</myroot>")
    myroot = doc.children.first
    ParagraphMaker.process(myroot)
    myroot.children.to_xhtml
  end


  ### STRIPPING FOR DISPLAY ONLY
  # Regexps for stripping particular tags and attributes for display.
  # These assume they are running on well-formed XHTML, which we can do
  # because they will only be used on already-cleaned fields.

  # strip img tags, optionally leaving the src URL exposed
  def strip_images(value, keep_src: false)
    value.gsub(/(<img .*?>)/) do |img_tag|
      match_data = img_tag.match(/src="([^"]+)"/) if keep_src
      src = match_data[1] if match_data
      src || ""
    end
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
