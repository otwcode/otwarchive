# Sanitize: http://github.com/rgrove/sanitize.git
class Sanitize
  
  # This defines the configuration we use for HTML tags and attributes allowed in the archive.
  module Config
    ARCHIVE = {
      :elements => [
        'a', 'abbr', 'b', 'big', 'blockquote', 'br', 'caption', 'center', 'cite', 'code', 'col',
        'colgroup', 'dd', 'div', 'dl', 'dt', 'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'hr',
        'i', 'img', 'li', 'ol', 'p', 'pre', 'q', 's', 'small', 'span', 'strike', 'strong',
        'sub', 'sup', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'tt', 'u',
        'ul'],

      :attributes => {
        :all => ['align', 'title'],
        'a' => ['href', 'name'],
        'blockquote' => ['cite'],
        'col' => ['span', 'width'],
        'colgroup' => ['span', 'width'],
        'hr' => ['align', 'width'],
        'img' => ['align', 'alt', 'border', 'height', 'src', 'width'],
        'ol' => ['start', 'type'],
        'q' => ['cite'],
        'table' => ['border', 'summary', 'width'],
        'td' => ['abbr', 'axis', 'colspan', 'height', 'rowspan', 'width'],
        'th' => ['abbr', 'axis', 'colspan', 'height', 'rowspan', 'scope', 'width'],
        'ul' => ['type'],
      },

      :protocols => {
        'a' => {'href' => ['ftp', 'http', 'https', 'mailto', :relative]},
        'blockquote' => {'cite' => ['http', 'https', :relative]},
        'img' => {'src' => ['http', 'https', :relative]},
        'q' => {'cite' => ['http', 'https', :relative]}
      }
    }
  end
  
  # This defines the custom sanitizing transformers we use for cleaning data
  module Transformers
    
    # allow users to specify class attributes in their html
    ALLOW_USER_CLASSES = lambda do |env|
      node      = env[:node]
      classval  = node['class']
      
      # if we don't have a class attribute, away we go
      return nil unless !classval.blank?

      # otherwise, only let through alphanumeric class names with a 
      # dash/underscore.
      {:attr_whitelist => ['class']} if classval =~ /[a-zA-Z][\w\-]+/
    end

    # taken directly from rgrove's docs
    ALLOW_YOUTUBE_EMBEDS = lambda do |env|
        node      = env[:node]
        node_name = env[:node_name]
        parent    = node.parent

        # Since the transformer receives the deepest nodes first, we look for a
        # <param> element or an <embed> element whose parent is an <object>.
        return nil unless (node_name == 'param' || node_name == 'embed') &&
            parent.name.to_s.downcase == 'object'

        if node_name == 'param'
          # Quick XPath search to find the <param> node that contains the video URL.
          return nil unless movie_node = parent.search('param[@name="movie"]')[0]
          url = movie_node['value']
        else
          # Since this is an <embed>, the video URL is in the "src" attribute. No
          # extra work needed.
          url = node['src']
        end

        # Verify that the video URL is actually a valid YouTube video URL.
        return nil unless url =~ /^http:\/\/(?:www\.)?youtube\.com\/v\//

        # We're now certain that this is a YouTube embed, but we still need to run
        # it through a special Sanitize step to ensure that no unwanted elements or
        # attributes that don't belong in a YouTube embed can sneak in.
        Sanitize.clean_node!(parent, {
          :elements   => ['embed', 'object', 'param'],
          :attributes => {
            'embed'  => ['allowfullscreen', 'allowscriptaccess', 'height', 'src', 'type', 'width'],
            'object' => ['height', 'width'],
            'param'  => ['name', 'value']
          }
        })

        # Now that we're sure that this is a valid YouTube embed and that there are
        # no unwanted elements or attributes hidden inside it, we can tell Sanitize
        # to whitelist the current node (<param> or <embed>) and its parent
        # (<object>).
        {:whitelist_nodes => [node, parent]}
      end
    

  end

end
