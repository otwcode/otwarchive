# Sanitize: http://github.com/rgrove/sanitize.git
class Sanitize
  
  # This defines the configuration we use for HTML tags and attributes allowed in the archive.
  module Config

    ARCHIVE = {
      :elements => [
        'a', 'abbr', 'acronym', 'address', 'b', 'big', 'blockquote', 'br', 'caption', 'center', 'cite', 'code', 'col',
        'colgroup', 'dd', 'del', 'dfn', 'div', 'dl', 'dt', 'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'hr',
        'i', 'img', 'ins', 'kbd', 'li', 'ol', 'p', 'pre', 'q', 's', 'samp', 'small', 'span', 'strike', 'strong',
        'sub', 'sup', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'tt', 'u', 'ul', 'var'],

      # see in the Transformers section for what classes we strip
      :attributes => {
        :all => ['align', 'title', 'class', 'dir'],
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
      return if classval.blank?

      # let through alphanumeric class names with a dash/underscore;
      # allow multiple classes
      classes = classval.split(" ")
      newclasses = []
      classes.each { |cls| newclasses << [cls] if cls =~ /^[a-zA-Z][\w\-]+$/ }
      node['class'] = newclasses.join(" ")
    end

    # taken directly from rgrove's docs
    ALLOW_VIDEO_EMBEDS = lambda do |env|
      node      = env[:node]
      node_name = env[:node_name]
      parent    = node.parent

      # Since the transformer receives the deepest nodes first, we look for a
      # <param> element whose parent is an <object>, or an embed or iframe
      return unless ( (node_name == 'param' && parent && parent.name.to_s.downcase == 'object') || node_name == 'embed' || node_name == 'iframe')

      if node_name == 'param'
        # Quick XPath search to find the <param> node that contains the video URL.
        return unless movie_node = parent.search('param[@name="movie"]')[0]
        url = movie_node['value']
      else
        # Since this is an <embed> or <iframe>, the video URL is in the "src" attribute. No
        # extra work needed.
        url = node['src']
      end
      
      # Verify that the video URL is actually a valid video URL from a site we trust.
      source = case url
      when /^http:\/\/(?:www\.)?youtube\.com\//
        then "youtube"
      when /^http:\/\/(?:www\.|player\.)?vimeo\.com\//
        then "vimeo"
      when /^http:\/\/(?:www\.)?blip\.tv\//
        then "blip"
      when /^http:\/\/(?:www\.|static\.)?ning\.com\//
        then "ning"
      when /^http:\/\/(?:www\.)?dailymotion\.com\//
        then "dailymotion"
      when /^http:\/\/(?:www\.)?viddler\.com\//
        then "viddler"
      when /^http:\/\/(?:www\.)?metacafe\.com\//
        then "metacafe"
      when /^http:\/\/(?:www\.)?vidders\.net\//
        then "vidders.net"
      when /^http:\/\/(?:www\.)?criticalcommons\.org\//
        then "criticalcommons"
      when /^http:\/\/(?:www\.)?google\.com\//
        then "google"
      when /^http:\/\/(?:www\.)?archiveofourown\.org\//
        then "archiveofourown"
      when /^http:\/\/(?:www\.)?podfic\.com\//
        then "podfic"
      when /^https:\/\/(?:embed\.)?spotify\.com\//
        then "spotify"
      when /^http:\/\/(?:www\.)?8tracks\.com\//
        then "8tracks"
      when /^https:\/\/(?:w\.)?soundcloud\.com\//
        then "soundcloud"
      else
        nil
      end
      
      # if we don't know the source, sorry
      return if source.nil?           

      allow_flashvars = ["ning", "vidders.net", "google", "criticalcommons", "archiveofourown", "podfic", "spotify", "8tracks", "soundcloud"]

      # We're now certain that this is an embed from a trusted source, but we still need to run
      # it through a special Sanitize step to ensure that no unwanted elements or
      # attributes that don't belong in a video embed can sneak in.
      if parent && parent.name.to_s.downcase == 'object'
        Sanitize.clean_node!(parent, {
          :elements   => ['embed', 'object', 'param'],
          :attributes => {
            'embed'  => ['allowfullscreen', 'height', 'src', 'type', 'width'],
            'object' => ['height', 'width'],
            'param'  => ['name', 'value']
          }
        })
        
        # disable script access and networking
        parent['allowscriptaccess'] = 'never'
        parent['allownetworking'] = 'internal'
        
        parent.search("param").each {|paramnode| paramnode.unlink if paramnode[:name].downcase == "allowscriptaccess"}
        parent.search("param").each {|paramnode| paramnode.unlink if paramnode[:name].downcase == "allownetworking"}

        return {:node_whitelist => [node, parent]}
      else
        Sanitize.clean_node!(node, {
          :elements   => ['embed', 'iframe'],
          :attributes => {
            'embed'  => (['allowfullscreen', 'height', 'src', 'type', 'width'] + (allow_flashvars.include?(source) ? ['wmode', 'flashvars'] : [])),
            'iframe'  => ['frameborder', 'height', 'src', 'title', 'class', 'type', 'width'],
          }          
        })
        
        if node_name == 'embed'
          # disable script access and networking
          node['allowscriptaccess'] = 'never'
          node['allownetworking'] = 'internal'
          unless allow_flashvars.include?(source)
            node['flashvars'] = ""
          end
        end
        return {:node_whitelist => [node, parent]}
      end
    end
    
  end

end
