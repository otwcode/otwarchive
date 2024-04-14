# frozen_string_literal: true

module RuboCop
  module Cop
    module Cucumber
      # Checks that Cucumber step definitions use Cucumber expressions
      # instead of Regex. Note: this may not always be possible, and this
      # cop is not smart enough to detect those cases.
      #
      # @example
      #   # bad
      #   Given /foobar/ do
      #     ...
      #   end
      #   When /baz/ do
      #     ...
      #   end
      #   Then /oops(\w+)/ do |it|
      #     ...
      #   end
      #
      # @example
      #   # good
      #   Given "foobar(s)" do
      #     ...
      #   end
      #   When "baz" do
      #     ...
      #   end
      #   Then "oops{str}" do |it|
      #     ...
      #   end
      class RegexStepName < RuboCop::Cop::Base
        MSG = "Prefer Cucumber expressions (https://github.com/cucumber/cucumber-expressions) over regex for step names; refer to https://github.com/otwcode/otwarchive/wiki/Reviewdog-and-RuboCop if regex is still required"

        RESTRICT_ON_SEND = %i[Given When Then].freeze

        # @!method regex_name(node)
        def_node_matcher :regex_name, <<~PATTERN
          (send nil? _ $(:regexp ...) ...)
        PATTERN

        def on_send(node)
          regex_name(node) do |regex_node|
            add_offense(regex_node, severity: :refactor)
          end
        end
      end
    end
  end
end
