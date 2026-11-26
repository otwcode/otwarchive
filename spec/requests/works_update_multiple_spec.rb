# frozen_string_literal: true

require "spec_helper"

describe "Editing multiple works" do
  include LoginMacros

  let(:user) { create(:user) }
  let!(:works) do
    Array.new(20) do |i|
      create(:work, title: "#{i} #{'a' * (ArchiveConfig.TITLE_MAX - 5)}",
                    authors: [user.default_pseud])
    end
  end

  before do
    fake_login_known_user(user)
  end

  context "when removing yourself from many works where you are the only " \
          "creator" do
    let(:make_request) do
      patch update_multiple_user_works_path(user),
            params: { "work_ids" => works.map { |work| work.id.to_s },
                      "remove_me" => "1",
                      "work" => { "summary" => "New summary" } }
    end
    let(:expected_flash_text) { "17 more errors" }

    it_behaves_like "an action whose flash fits in the session cookie"
  end
end
