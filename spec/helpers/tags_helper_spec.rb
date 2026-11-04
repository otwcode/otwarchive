require "spec_helper"

describe TagsHelper do
  describe "#show_wrangling_dashboard" do
    let(:controller_name) { "tag_wranglings" }
    let(:current_user) { nil }
    let(:current_admin) { nil }

    before do
      allow(helper.controller).to receive(:controller_name).and_return(controller_name)
      allow(helper).to receive(:current_user).and_return(current_user)
      allow(helper).to receive(:logged_in_as_admin?).and_return(current_admin.present?)
      allow(helper).to receive(:policy).with(:wrangling) do
        WranglingPolicy.new(current_admin, :wrangling)
      end
    end

    context "when logged out" do
      it "returns false" do
        expect(helper.show_wrangling_dashboard).to be_falsey
      end
    end

    context "when logged in as a regular user" do
      let(:current_user) { create(:user) }

      it "returns false" do
        expect(helper.show_wrangling_dashboard).to be_falsey
      end
    end

    context "when logged in as a tag wrangler" do
      let(:current_user) { create(:tag_wrangler) }

      %w[tags tag_wranglings tag_wranglers tag_wrangling_requests unsorted_tags].each do |name|
        context "on the #{name} controller" do
          let(:controller_name) { name }

          it "returns true" do
            expect(helper.show_wrangling_dashboard).to be_truthy
          end
        end
      end

      context "on the comments controller" do
        let(:controller_name) { "comments" }

        before { assign(:tag, build(:fandom)) }

        it "returns false" do
          expect(helper.show_wrangling_dashboard).to be_falsey
        end
      end

      context "on an unrelated controller" do
        let(:controller_name) { "works" }

        it "returns false" do
          expect(helper.show_wrangling_dashboard).to be_falsey
        end
      end
    end

    context "when logged in as an admin" do
      %i[superadmin tag_wrangling_admin policy_and_abuse_admin].each do |factory|
        context "with the #{factory} role" do
          let(:current_admin) { create(factory) }

          it "returns true" do
            expect(helper.show_wrangling_dashboard).to be_truthy
          end
        end
      end

      context "with a role that has no wrangling access" do
        let(:current_admin) { create(:support_admin) }

        it "returns false" do
          expect(helper.show_wrangling_dashboard).to be_falsey
        end
      end

      context "on the comments controller" do
        let(:current_admin) { create(:tag_wrangling_admin) }
        let(:controller_name) { "comments" }

        it "returns false" do
          expect(helper.show_wrangling_dashboard).to be_falsey
        end
      end
    end
  end
end
