# frozen_string_literal: true

require "spec_helper"

describe BookmarkSearchForm do
  describe "options" do
    it "includes flags set to false" do
      bsf = BookmarkSearchForm.new(show_restricted: false, show_private: false)
      expect(bsf.options).to include(show_restricted: false)
      expect(bsf.options).to include(show_private: false)
    end
  end
end
