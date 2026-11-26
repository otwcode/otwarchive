# frozen_string_literal: true

require "spec_helper"

describe "Accepting co-creator requests" do
  include LoginMacros

  let(:user) { create(:user) }
  let(:creatorships) do
    Array.new(20) do |i|
      work = create(:work,
                    title: "#{i} #{'a' * (ArchiveConfig.TITLE_MAX - 5)}")
      Creatorship.new(pseud: user.default_pseud, creation: work,
                      approved: false).tap do |creatorship|
        creatorship.save!(validate: false)
      end
    end
  end

  before do
    fake_login_known_user(user)
  end

  context "when accepting many requests for works with long titles" do
    let(:make_request) do
      put user_creatorships_path(user),
          params: { "selected" => creatorships.map { |c| c.id.to_s },
                    "accept" => "Accept" }
    end
    let(:expected_flash_text) { "co-creator on 17 more works." }

    it_behaves_like "an action whose flash fits in the session cookie"
  end
end
