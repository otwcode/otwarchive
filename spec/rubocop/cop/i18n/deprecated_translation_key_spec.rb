# frozen_string_literal: true

require "rubocop_spec_helper"
require_relative "../../../../rubocop/cop/i18n/deprecated_translation_key"

describe RuboCop::Cop::I18n::DeprecatedTranslationKey do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new("I18n/DeprecatedTranslationKey" => {
                          "Rules" => {
                            "name_with_colon" => "Prefer `name` with `mailer.general.metadata_label_indicator` over `name_with_colon`"
                          }
                        })
  end

  context "when using I18n.translate" do
    it "records a violation for `name_with_colon`" do
      expect_offense(<<~INVALID)
        I18n.translate("name_with_colon")
                       ^^^^^^^^^^^^^^^^^ Prefer `name` with `mailer.general.metadata_label_indicator` over `name_with_colon`
      INVALID
    end
  end

  context "when using human_attribute_name" do
    it "records a violation for `name_with_colon`" do
      expect_offense(<<~INVALID)
        Fandom.human_attribute_name("name_with_colon", count: prompt.any_fandom ? 1 : tag_groups["Fandom"].count)
                                    ^^^^^^^^^^^^^^^^^ Prefer `name` with `mailer.general.metadata_label_indicator` over `name_with_colon`
      INVALID
    end
  end
end
