# frozen_string_literal: true

# Creates a Sanitize transformer to sanitize audio and video tags
module OTWSanitize
  class MediaSanitizer
    # Attribute whitelists
    AUDIO_ATTRIBUTES = %w[
      class controls crossorigin dir
      loop muted preload src title
    ].freeze

    VIDEO_ATTRIBUTES = %w[
      class controls crossorigin dir height loop
      muted playsinline poster preload src title width
    ].freeze

    SOURCE_ATTRIBUTES = %w[src type].freeze
    TRACK_ATTRIBUTES = %w[default kind label src srclang].freeze

    WHITELIST_CONFIG = {
      elements: %w[audio video source track],
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
          'poster' => %w[http https]
        }
      }
    }.freeze

    # Creates a callable transformer for the sanitizer to use
    def self.transformer
      lambda do |env|
        new(env[:node]).sanitized_node
      end
    end

    attr_reader :node

    # Takes a Nokogiri node
    def initialize(node)
      @node = node
    end

    # Skip if it's not media or if we don't want to whitelist it
    def sanitized_node
      return unless media_node?
      return if blacklisted_source?

      Sanitize.clean_node!(node, WHITELIST_CONFIG)
      { node_whitelist: [node] }
    end

    def node_name
      node.name.to_s.downcase
    end

    def media_node?
      %w[audio video source track].include?(node_name)
    end

    def source_url
      node["src"] || ""
    end

    def source_host
      url = source_url
      # Just in case we're missing a protocol
      unless url =~ /http/
        url = "https://" + url
      end
      URI(url).host
    end

    def blacklisted_source?
      return unless source_host
      ArchiveConfig.BLACKLISTED_MULTIMEDIA_SRCS.any? do |blocked|
        source_host.match(blocked)
      end
    end
  end
end
