# frozen_string_literal: true

require "rubocop_spec_helper"
require_relative "../../../../rubocop/cop/i18n/deprecated_helper"

describe RuboCop::Cop::I18n::DeprecatedHelper do
  it "registers an offense when `ts` is used" do
    expect_offense(<<~INVALID)
      ts("Some String")
      ^^^^^^^^^^^^^^^^^ Prefer Rails built-in `I18n.t` function over `ts`: the latter is not actually translatable
    INVALID
  end

  it "registers an offense when `ts` is used without parentheses" do
    expect_offense(<<~INVALID)
      ts "Another string"
      ^^^^^^^^^^^^^^^^^^^ Prefer Rails built-in `I18n.t` function over `ts`: the latter is not actually translatable
    INVALID
  end

  it "does not register an offense when `I18n.t` is used" do
    expect_no_offenses(<<~RUBY)
      I18n.t(".hello")
      t(".goodbye")
    RUBY
  end

  it "does not register an offense for functions containing the letter `ts`" do
    expect_no_offenses(<<~RUBY)
      cats("meow")
    RUBY
  end
end
