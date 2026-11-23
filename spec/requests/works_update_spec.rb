# frozen_string_literal: true

require "spec_helper"

describe "Editing a work" do
  include LoginMacros

  let(:user) { create(:user) }
  let(:work) { create(:work, authors: [user.default_pseud]) }

  before do
    fake_login_known_user(user)
  end

  context "when adding the work to many moderated collections with long titles" do
    let(:collections) do
      Array.new(20) do |i|
        create(:collection, :moderated,
               title: "#{i} #{'a' * (ArchiveConfig.TITLE_MAX - 5)}")
      end
    end
    let(:make_request) do
      patch work_path(work),
            params: { "work" => { "collection_names" => collections.map(&:name).join(",") } }
    end

    it_behaves_like "a bulk action that fits in the session cookie"
  end
end
