# frozen_string_literal: true

require "spec_helper"

describe "Adding a work to collections" do
  include LoginMacros

  let(:user) { create(:user) }
  let(:work) { create(:work, authors: [user.default_pseud]) }

  before do
    # Otherwise the action redirects before it checks the collections.
    user.preference.update!(allow_collection_invitation: true)
    fake_login_known_user(user)
  end

  context "when many of the collections can't be found" do
    let(:collection_names) do
      Array.new(30) { |i| "missing_#{i}_#{'a' * 140}" }
    end
    let(:make_request) do
      post work_collection_items_path(work),
           params: { "collection_names" => collection_names.join(",") }
    end
    let(:expected_flash_text) { "27 more errors" }

    it_behaves_like "an action whose flash fits in the session cookie"
  end
end
