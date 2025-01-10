# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      # Checks for uses of the `default` keyword argument within Rails translation helpers.
      #
      # @example
      #   # bad
      #   t(".translation_key", default: "English text")
      #
      # @example
      #   # good
      #   # assuming the translation is in a view, the key must be defined in config/locales/views/en.yml
      #   t(".translation_key")
      class DefaultTranslation < RuboCop::Cop::Base
        MSG = "Prefer setting a translation in the appropriate `en.yml` locale file instead of using `default`"

        RESTRICT_ON_SEND = %i[t translate].freeze

        # @!method default_kwarg(node)
        def_node_search :default_kwarg, <<~PATTERN
          (pair (sym :default) _)
        PATTERN

        def on_send(node)
          default_kwarg(node).each do |kwarg_node|
            add_offense(kwarg_node)
          end
        end
      end
    end
  end
end
