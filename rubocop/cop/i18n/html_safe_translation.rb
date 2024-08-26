# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      # Checks for uses of html_safe on strings translated with `t`.
      # html_safe does not escape HTML in strings, making it potentially unsafe
      # to call on user-generated text like interpolation variables.
      # Renaming the locale key to end with `.html` or `_html` will escape interpolation variables
      # while keeping HTML from Rails helpers like link_to intact.
      #
      # @example
      #  # bad
      #  t(".has_invited", user_name: style_bold(@user_name)).html_safe
      #  t(".about.popular", search_tags_link: link_to(t(".search_tags"), search_tags_path)).html_safe
      #
      # @example
      #  # good
      #  t(".has_invited.html", user_name: style_bold(@user_name))
      #  t(".about.popular_html", search_tags_link: link_to(t(".search_tags"), search_tags_path))
      class HtmlSafeTranslation < RuboCop::Cop::Base
        MSG = "Prefer t(key) with locale keys ending in `_html` or `.html` over calling t(key).html_safe"

        RESTRICT_ON_SEND = %i[html_safe].freeze

        # @!method html_safe_translate?(node)
        def_node_matcher :html_safe_translate?, <<~PATTERN
          (send (send nil? {:t | :translate} ...) :html_safe)
        PATTERN

        def on_send(node)
          return unless html_safe_translate?(node)

          add_offense(node)
        end
      end
    end
  end
end
