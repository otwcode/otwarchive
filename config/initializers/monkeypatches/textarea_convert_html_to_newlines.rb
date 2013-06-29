# modifying to_text_area_tag and text_area_tag to strip paragraph/br tags and convert them back into newlines for editing purposes
module ActionView
  module Helpers
    
    module FormTagHelper

      # added method to yank <p> and <br> tags and replace with newlines
      # this needs to reverse "add_paragraph_tags_to_text" from our html_cleaner library
      def strip_html_breaks(content, name="")
        return "" if content.blank?
        if name =~ /content/
          # might be using RTE, preserve all paragraphs as they are
          content.gsub(/\s*<br ?\/?>\s*/, "<br />\n").
                  gsub(/\s*<p[^>]*>\s*&nbsp;\s*<\/p>\s*/, "\n\n\n").
                  gsub(/\s*(<p[^>]*>.*?<\/p>)\s*/m, "\n\n" + '\1').
                  strip
        else
          # no RTE, so clean up paragraphs unless they have qualifiers
          content = content.gsub(/\s*<br ?\/?>\s*/, "<br />\n").
                            gsub(/\s*<p[^>]*>\s*&nbsp;\s*<\/p>\s*/, "\n\n\n")
                  
          if content.match(/\s*(<p[^>]+>)(.*?)(<\/p>)\s*/m)
            content.gsub(/\s*(<p[^>]*>.*?<\/p>)\s*/m, "\n\n" + '\1').
                    strip
          else
            content.gsub(/\s*<p[^>]*>(.*?)<\/p>\s*/m, "\n\n" + '\1').
                    strip
          end
        end
      end      

      def text_area_tag_with_html_breaks(name, content = nil, options = {})
        options.stringify_keys!

        if size = options.delete("size")
          options["cols"], options["rows"] = size.split("x") if size.respond_to?(:split)
        end

        content = strip_html_breaks(content, name) # ADDED

        escape = options.key?("escape") ? options.delete("escape") : true
        content = ERB::Util.html_escape(content) if escape

        content_tag :textarea, content.to_s.html_safe, { "name" => name, "id" => sanitize_to_id(name) }.update(options)
      end
      
      alias_method_chain :text_area_tag, :html_breaks
    end
    
    class InstanceTag
      def to_text_area_tag_with_html_breaks(options = {})
        options = DEFAULT_TEXT_AREA_OPTIONS.merge(options.stringify_keys)
        add_default_name_and_id(options)

        if size = options.delete("size")
          options["cols"], options["rows"] = size.split("x") if size.respond_to?(:split)
        end

        # modified
        content = strip_html_breaks(options.delete('value') || value_before_type_cast(object), options["name"])
        content_tag("textarea", ERB::Util.html_escape(content), options)
      end
      
      alias_method_chain :to_text_area_tag, :html_breaks
    end
    
  end
end
