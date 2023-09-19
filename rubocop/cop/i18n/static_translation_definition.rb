# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      # This cop flags translation definitions in static scopes because changing
      # locales has no effect and won't translate this text again. The rule here is based upon
      # https://gitlab.com/gitlab-org/gitlab/-/blob/master/rubocop/cop/static_translation_definition.rb?ref_type=heads.
      #
      # @example
      #   # bad
      #   class MyExample
      #     # Constant
      #     Translation = I18n.t('A translation.')
      #
      #     # Class scope
      #     field :foo, title: I18n.t('A title')
      #
      #     validates :title, :presence, message: I18n.t('is missing')
      #
      #     # Memoized
      #     def self.translations
      #       @cached ||= { text: I18n.t('A translation.') }
      #     end
      #
      #     included do # or prepended or class_methods
      #       self.error_message = I18n.t('Something went wrong.')
      #     end
      #   end
      #
      #   # good
      #   class MyExample
      #     # Keep translations dynamic.
      #     Translation = -> { I18n.t('A translation.') }
      #     # OR
      #     def translation
      #       I18n.t('A translation.')
      #     end
      #
      #     field :foo, title: -> { I18n.t('A title') }
      #
      #     validates :title, :presence, message: -> { I18n.t('is missing') }
      #
      #     def self.translations
      #       { text: I18n.t('A translation.') }
      #     end
      #
      #     included do # or prepended or class_methods
      #       self.error_message = -> { I18n.t('Something went wrong.') }
      #     end
      # end
      class StaticTranslationDefinition < RuboCop::Cop::Base
        MSG = "Translation is defined in static scope. Keep translations dynamic."

        RESTRICT_ON_SEND = %i[t translate].freeze

        # List of method names which are not considered real method definitions.
        # See https://api.rubyonrails.org/classes/ActiveSupport/Concern.html
        NON_METHOD_DEFINITIONS = %i[class_methods included prepended].to_set.freeze

        # @!method translation_method?
        def_node_matcher :translation_method?, <<~PATTERN
          (send _ {#{RESTRICT_ON_SEND.map(&:inspect).join(' ')}} {dstr str}+ ...)
        PATTERN

        def on_send(node)
          return unless translation_method?(node)

          static = true
          memoized = false
          node.each_ancestor do |ancestor|
            memoized = true if memoized?(ancestor)

            if dynamic?(ancestor, memoized)
              static = false
              break
            end
          end

          add_offense(node) if static
        end

        private

        def memoized?(node)
          node.type == :or_asgn
        end

        def dynamic?(node, memoized)
          lambda_or_proc?(node) ||
            named_block?(node) ||
            instance_method_definition?(node) ||
            unmemoized_class_method_definition?(node, memoized)
        end

        def lambda_or_proc?(node)
          node.lambda_or_proc?
        end

        def named_block?(node)
          return unless node.block_type?

          !NON_METHOD_DEFINITIONS.include?(node.method_name) # rubocop:disable Rails/NegateInclude
        end

        def instance_method_definition?(node)
          node.type == :def
        end

        def unmemoized_class_method_definition?(node, memoized)
          node.type == :defs && !memoized
        end
      end
    end
  end
end
