# frozen_string_literal: true

require "rubocop_spec_helper"
require_relative "../../../../rubocop/cop/i18n/html_safe_translation"

describe RuboCop::Cop::I18n::HtmlSafeTranslation do
  context "when using translate" do
    it "records a violation for calling `html_safe` on it" do
      expect_offense(<<~INVALID)
        translate(".foo").html_safe
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer t(key) with locale keys ending in `_html` or `.html` over calling t(key).html_safe
        translate(".bar", input: "hello").html_safe
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer t(key) with locale keys ending in `_html` or `.html` over calling t(key).html_safe
      INVALID
    end

    it "does not record a violation when html_safe is not called" do
      expect_no_offenses(<<~RUBY)
        translate(".foo")
        translate(".bar", input: "hello")
      RUBY
    end
  end

  context "when using t" do
    it "records a violation for calling `html_safe` on it" do
      expect_offense(<<~INVALID)
        t(".foo").html_safe
        ^^^^^^^^^^^^^^^^^^^ Prefer t(key) with locale keys ending in `_html` or `.html` over calling t(key).html_safe
        t(".bar", input: "hello").html_safe
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer t(key) with locale keys ending in `_html` or `.html` over calling t(key).html_safe
      INVALID
    end

    it "does not record a violation when html_safe is not called" do
      expect_no_offenses(<<~RUBY)
        t(".foo")
        t(".bar", input: "hello")
      RUBY
    end
  end

  # only the helpers in controllers and views support the html suffixes for HTML safe translations
  context "when using I18n.t" do
    it "does not record a violation for calling `html_safe` on it" do
      expect_no_offenses(<<~RUBY)
        I18n.t(".foo").html_safe
        I18n.t(".bar", input: "hello").html_safe
      RUBY
    end
  end

  # only the helpers in controllers and views support the html suffixes for HTML safe translations
  context "when using I18n.translate" do
    it "does not record a violation for calling `html_safe` on it" do
      expect_no_offenses(<<~RUBY)
        I18n.translate(".foo").html_safe
        I18n.translate(".bar", input: "hello").html_safe
      RUBY
    end
  end

  context "when using anther method" do
    it "does not record a violation for calling `html_safe` on it" do
      expect_no_offenses(<<~RUBY)
        cat(".foo").html_safe
        cat(".bar", input: "hello").html_safe
        not_translate(".foo").html_safe
        not_translate(".bar", input: "hello").html_safe
      RUBY
    end
  end
end
