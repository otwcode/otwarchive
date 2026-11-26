# frozen_string_literal: true

require "spec_helper"

describe "Mass updating tags" do
  include LoginMacros

  let(:tag_wrangler) { create(:tag_wrangler) }
  let(:fandom) { create(:fandom, canonical: true) }

  before do
    fake_login_known_user(tag_wrangler)
  end

  context "when making many tags with long names canonical" do
    let(:freeforms) do
      Array.new(40) do |i|
        create(:freeform, canonical: false,
                          name: "#{i} #{'a' * (ArchiveConfig.TAG_MAX - 5)}")
      end
    end
    let(:make_request) do
      post mass_update_tag_path(fandom),
           params: { "canonicals" => freeforms.map { |tag| tag.id.to_s } }
    end
    let(:expected_flash_text) { "and 37 more" }

    it_behaves_like "an action whose flash fits in the session cookie"
  end
end
