# frozen_string_literal: true

require "rubocop_spec_helper"
require_relative "../../../../rubocop/cop/i18n/default_translation"

describe RuboCop::Cop::I18n::DefaultTranslation do
  context "when within the `t` helper" do
    it "registers an offense if `default` is used alone" do
      expect_offense(<<~INVALID)
        t(".translation_key", default: "English text")
                              ^^^^^^^^^^^^^^^^^^^^^^^ Prefer setting a translation in the appropriate `en.yml` locale file instead of using `default`
      INVALID
    end

    it "registers an offense if `default` is used with other kwargs" do
      expect_offense(<<~INVALID)
        t(".translation_key", input: "hello", default: "I got %{input}")
                                              ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer setting a translation in the appropriate `en.yml` locale file instead of using `default`
      INVALID
    end

    it "does not register an offense if `default` is not used" do
      expect_no_offenses(<<~RUBY)
        t(".translation_key1")
        t(".translation_key2", input: "hello")
      RUBY
    end
  end

  context "when not within the `t` helper" do
    it "does not register an offense if `default` is present in keyword args" do
      expect_no_offenses(<<~RUBY)
        my_method("arg", default: "something", kwarg1: "hi")
      RUBY
    end
  end
end
