# frozen_string_literal: true

require "spec_helper"

describe "Deleting multiple works" do
  include LoginMacros

  let(:user) { create(:user) }
  let(:make_request) do
    post delete_multiple_user_works_path(user),
         params: { "work_ids" => works.map { |work| work.id.to_s } }
  end

  before do
    fake_login_known_user(user)
  end

  context "when deleting many works with long titles" do
    let!(:works) do
      Array.new(20) do |i|
        create(:work, title: "#{i} #{'a' * (ArchiveConfig.TITLE_MAX - 5)}",
                      authors: [user.default_pseud])
      end
    end
    let(:expected_flash_text) { "and 17 more were deleted." }

    it_behaves_like "an action whose flash fits in the session cookie"

    it "deletes the works" do
      make_request

      expect(response).to redirect_to(show_multiple_user_works_path(user))
      expect(Work.where(id: works.map(&:id))).to be_empty
    end
  end

  context "when deleting the same number of works with short titles" do
    let!(:works) do
      Array.new(20) do |i|
        create(:work, title: "Work #{i}", authors: [user.default_pseud])
      end
    end

    it "deletes the works and lists only the first titles in the flash" do
      make_request

      expect(response).to redirect_to(show_multiple_user_works_path(user))
      expect(Work.where(id: works.map(&:id))).to be_empty
      expect(flash[:notice]).to include("and 17 more")
    end
  end
end
