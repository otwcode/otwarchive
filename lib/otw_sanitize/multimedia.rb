module OTWSanitize
  module Multimedia
    # Attribute whitelists
    AUDIO_ATTRIBUTES = [
      'class', 'controls', 'crossorigin', 'dir',
      'loop', 'muted', 'preload', 'src', 'title'
    ]
    VIDEO_ATTRIBUTES = [
      'class', 'controls', 'crossorigin', 'dir', 'height',
      'loop', 'muted', 'poster', 'preload', 'src', 'title', 'width'
    ]
    SOURCE_ATTRIBUTES = ['src', 'type']
    TRACK_ATTRIBUTES = ['default', 'kind', 'label', 'src', 'srclang']

    def self.transformer
      lambda do |env|
        node      = env[:node]
        node_name = env[:node_name]

        return unless %w[audio video source track].include?(node_name)
        return if blacklisted_source?(node)

        sanitize_node(node)
      end
    end

    def self.sanitize_node(node)
      Sanitize.clean_node!(node, {
        elements: ['audio', 'video', 'source', 'track'],
        attributes: {
          'audio'  => AUDIO_ATTRIBUTES,
          'video'  => VIDEO_ATTRIBUTES,
          'source' => SOURCE_ATTRIBUTES,
          'track'  => TRACK_ATTRIBUTES
        },
        add_attributes: {
          'audio' => {
            'controls'    => 'controls',
            'crossorigin' => 'anonymous',
            'preload'     => 'metadata'
          },
          'video' => {
            'controls'    => 'controls',
            'playsinline' => 'playsinline',
            'crossorigin' => 'anonymous',
            'preload'     => 'metadata'
          }
        },
        protocols: {
          'video' => {
            'poster' => ['http', 'https']
          }
        }
      })
      { node_whitelist: [node] }
    end

    private

    def self.blacklisted_source?(node)
      url = node['src']
      return false unless url
      ArchiveConfig.BLACKLISTED_SRCS.include?(source_host(url))
    end

    def self.source_host(url)
      # Just in case we're missing a protocol
      unless url.match /http/
        url = "https://" + url
      end
      URI(url).host
    end
  end
end
