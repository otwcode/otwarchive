module OTWSanitize
  class EmbedSanitizer
    WHITELIST_REGEXES = {
      ao3:              /^archiveofourown\.org\//,
      archiveorg:       /^archive\.org\//,
      criticalcommons:  /^criticalcommons\.org\//,
      dailymotion:      /^dailymotion\.com\//,
      eighttracks:      /^8tracks\.com\//,
      google:           /^google\.com\//,
      metacafe:         /^metacafe\.com\//,
      ning:             /^(static\.)?ning\.com\//,
      podfic:           /^podfic\.com\//,
      soundcloud:       /^(w\.)?soundcloud\.com\//,
      spotify:          /^(open\.)?spotify\.com\//,
      viddersnet:       /^vidders\.net\//,
      viddertube:       /^viddertube\.com\//,
      vimeo:            /^(player\.)?vimeo\.com\//,
      youtube:          /^youtube(-nocookie)?\.com\//
    }.freeze

    ALLOWS_FLASHVARS = %i[
      ao3 criticalcommons eighttracks google
      ning podfic soundcloud spotify viddersnet
    ].freeze

    SUPPORTS_HTTPS = %i[
      ao3 archiveorg dailymotion eighttracks podfic
      soundcloud spotify viddertube vimeo youtube
    ].freeze

    def self.transformer
      lambda do |env|
        new(env[:node]).sanitized_node
      end
    end

    attr_reader :node

    def initialize(node)
      @node = node
    end

    def sanitized_node
      return unless embed_node?
      return unless source_url && source

      ensure_https

      if parent_name == 'object'
        sanitize_object
      else
        sanitize_embed
      end
    end

    def node_name
      node.name.to_s.downcase
    end

    def parent
      node.parent
    end

    def parent_name
      parent.name.to_s.downcase if parent
    end

    # Since the transformer receives the deepest nodes first, we look for a
    # <param> element whose parent is an <object>, or an embed or iframe
    def embed_node?
      (node_name == 'param' && parent_name == 'object') ||
      %w(embed iframe).include?(node_name)
    end

    def source
      return @source if @source
      WHITELIST_REGEXES.each_pair do |name, reg|
        if source_url =~ reg
          @source = name
          break
        end
      end
      @source
    end

    def source_url
      return @source_url if @source_url
      if node_name == 'param'
        # Quick XPath search to find the <param> node that contains the video URL.
        return unless movie_node = node.parent.search('param[@name="movie"]')[0]
        url = movie_node['value']
      else
        url = node['src']
      end
      # strip off optional protocol and www
      @source_url = url&.gsub(/^(?:https?:)?\/\/(?:www\.)?/i, '')
    end

    # For sites that support https, ensure we use a secure embed
    def ensure_https
      if supports_https? && node['src'].present?
        node['src'] = node['src'].gsub("http:", "https:")
      end
    end

    # We're now certain that this is an embed from a trusted source, but we still need to run
    # it through a special Sanitize step to ensure that no unwanted elements or
    # attributes that don't belong in a video embed can sneak in.
    def sanitize_object
      Sanitize.clean_node!(parent, {
        elements: ['embed', 'object', 'param'],
        attributes: {
          'embed'  => ['allowfullscreen', 'height', 'src', 'type', 'width'],
          'object' => ['height', 'width'],
          'param'  => ['name', 'value']
        }
      })

      # disable script access and networking
      parent['allowscriptaccess'] = 'never'
      parent['allownetworking'] = 'internal'

      parent.search("param").each do |paramnode|
        if paramnode[:name].downcase == "allowscriptaccess"
          paramnode.unlink
        end
        if paramnode[:name].downcase == "allownetworking"
          paramnode.unlink
        end
      end

      { node_whitelist: [node, parent] }
    end

    def sanitize_embed
      Sanitize.clean_node!(node, {
        elements: ['embed', 'iframe'],
        attributes: {
          'embed'   => %w[
            allowfullscreen height src type width
          ] + optional_embed_attributes,
          'iframe'  => %w[
            allowfullscreen frameborder height src title
            class type width
          ]
        }
      })

      if node_name == 'embed'
        # disable script access and networking
        node['allowscriptaccess'] = 'never'
        node['allownetworking'] = 'internal'
        unless allows_flashvars?
          node['flashvars'] = ""
        end
      end
      return { node_whitelist: [node, parent] }
    end

    def optional_embed_attributes
      if allows_flashvars?
        %w[wmode flashvars]
      else
        []
      end
    end

    def allows_flashvars?
      ALLOWS_FLASHVARS.include?(source)
    end

    def supports_https?
      SUPPORTS_HTTPS.include?(source)
    end
  end
end
