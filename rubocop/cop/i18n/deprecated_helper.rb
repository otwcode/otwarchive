# frozen_string_literal: true

module RuboCop
  module Cop
    module I18n
      # Checks for uses of the deprecated helper function, `ts`.
      # Strings passed to it cannot be translated, and all calls
      # will need to be replaced with I18n.t to enable UI translations
      # in the future.
      #
      # @example
      #  # bad
      #  ts("This will only be in English :(")
      #  ts("Hello %{name}", name: "world")
      #
      # @example
      #  # good
      #  t(".relative.path.to.translation")
      #  t(".greeting", name: "world")
      class DeprecatedHelper < RuboCop::Cop::Base
        MSG = "Prefer Rails built-in `I18n.t` function over `ts`: the latter is not actually translatable. For more information, refer to https://github.com/otwcode/otwarchive/wiki/Internationalization-(i18n)-Standards."

        RESTRICT_ON_SEND = %i[ts].freeze

        def on_send(node)
          add_offense(node)
        end
      end
    end
  end
end
