# frozen_string_literal: true

require "rubocop_spec_helper"
require_relative "../../../../rubocop/cop/i18n/static_translation_definition"

describe RuboCop::Cop::I18n::StaticTranslationDefinition do
  context "when translating validation messages" do
    it "records a violation for static scope" do
      expect_offense(<<~INVALID)
        validates :email,
                  email_format: { message: I18n.t(".custom.key") },
                                           ^^^^^^^^^^^^^^^^^^^^^ Translation is defined in static scope. Keep translations dynamic.
                  uniqueness: true
      INVALID
    end

    it "does not record a violation when inside a lambda" do
      expect_no_offenses(<<~RUBY)
        validates :email,
                  email_format: { message: ->{ I18n.t(".custom.key") } },
                  uniqueness: true
      RUBY
    end
  end
end
