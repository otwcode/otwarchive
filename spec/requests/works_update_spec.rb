# frozen_string_literal: true

require "spec_helper"

describe "Editing a work" do
  include LoginMacros

  let(:user) { create(:user) }
  let(:work) { create(:work, authors: [user.default_pseud]) }

  before do
    fake_login_known_user(user)
  end

  context "when adding the work to many moderated collections with long " \
          "titles" do
    let(:collections) do
      Array.new(20) do |i|
        create(:collection, :moderated,
               title: "#{i} #{'a' * (ArchiveConfig.TITLE_MAX - 5)}")
      end
    end
    let(:collection_names) { collections.map(&:name).join(",") }
    let(:make_request) do
      patch work_path(work),
            params: { "work" => { "collection_names" => collection_names } }
    end
    let(:expected_flash_text) { "and 17 more)" }

    it_behaves_like "an action whose flash fits in the session cookie"
  end
end
