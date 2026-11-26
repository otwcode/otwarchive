# frozen_string_literal: true

require "spec_helper"

describe "Reviewing multiple tag set nominations" do
  include LoginMacros

  let(:tag_set_nomination) { create(:tag_set_nomination) }
  let(:owned_tag_set) { tag_set_nomination.owned_tag_set }
  let(:moderator) do
    create(:pseud).tap do |pseud|
      owned_tag_set.add_moderator(pseud)
      owned_tag_set.save!
    end.user
  end

  before do
    fake_login_known_user(moderator.reload)
  end

  context "when rejecting many nominations with long names" do
    let(:tagnames) do
      Array.new(40) { |i| "#{i} #{'a' * (ArchiveConfig.TAG_MAX - 5)}" }
    end
    let(:make_request) do
      put update_multiple_tag_set_nominations_path(owned_tag_set),
          params: tagnames.to_h { |name| ["freeform_reject_#{name}", "1"] }
    end
    let(:expected_flash_text) { "and 37 more" }

    before do
      tagnames.each do |tagname|
        FreeformNomination.create!(tag_set_nomination: tag_set_nomination,
                                   tagname: tagname)
      end
    end

    it_behaves_like "an action whose flash fits in the session cookie"
  end
end
