# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      # Checks for uses of translation keys that have been superseded
      # by others or different methods of translation.
      #
      # @example
      #   # bad
      #   Category.human_attribute_name("name_with_colon", count: 1)
      #   t(".relative.path.name_with_colon", count: 2)
      #
      # @example
      #   # good
      #   Category.human_attribute_name("name", count: 1) + t("mailer.general.metadata_label_indicator")
      #   metadata_property(t(".relative.path.name", count: 2)) # views only
      class DeprecatedTranslationKey < RuboCop::Cop::Base
        # Rubocop optimization: the check here is a little bit inefficient,
        # and we know which functions/methods to check, so only run it on those.
        RESTRICT_ON_SEND = %i[t translate human_attribute_name].freeze

        # @!method translation_keys(node)
        def_node_search :translation_keys, <<~PATTERN
          $(str $_)
        PATTERN

        def on_send(node)
          translation_keys(node).each do |key_node, key_text|
            denied_key = deprecated_keys.find do |key, _|
              key_text.include?(key.to_s)
            end
            next unless denied_key

            add_offense(key_node, message: denied_key[1])
          end
        end

        private

        def deprecated_keys
          cop_config["Rules"] || []
        end
      end
    end
  end
end
