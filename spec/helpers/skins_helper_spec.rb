# frozen_string_literal: true

require "spec_helper"

describe SkinsHelper do
  describe "#current_skin" do
    before do
      allow(helper).to receive(:current_user)
      allow(helper).to receive(:logged_in_as_admin?).and_return(false)
      allow(helper).to receive(:logged_in?).and_return(false)
      admin_setting = AdminSetting.default
      admin_setting.default_skin = Skin.default
      admin_setting.save(validate: false)
    end

    context "when the parameters include a skin id" do
      before do
        params[:site_skin] = skin.id
      end

      context "when the skin is applied" do
        let(:skin) { create(:skin, :public) }

        it "returns the skin matching the parameter" do
          expect(helper.current_skin).to eq(skin)
        end
      end

      context "when the skin is not applied" do
        let(:skin) { create(:skin) }

        it "falls back to other options" do
          expect(helper.current_skin).to eq(Skin.default)
        end
      end
    end

    context "when the current user has a skin set for the session" do
      before do
        allow(helper).to receive(:current_user).and_return(create(:user))
        allow(helper).to receive(:logged_in?).and_return(true)
        session[:site_skin] = skin.id
      end

      context "when the skin is applied" do
        let(:skin) { create(:skin, :public) }

        it "returns the skin matching the session attribute" do
          expect(helper.current_skin).to eq(skin)
        end
      end

      context "when the skin is not applied" do
        # Non-public skin with a different author
        let(:skin) { create(:skin) }

        it "falls back to other options" do
          expect(helper.current_skin).to eq(Skin.default)
        end
      end
    end

    context "when the current user has a skin preference set" do
      let(:skin) { create(:skin) }
      let(:user) { skin.author }

      before do
        user.preference.update!(skin: skin)
        allow(helper).to receive(:current_user).and_return(user)
      end

      it "returns the preferred skin" do
        expect(helper.current_skin).to eq(skin)
      end
    end
  end
end
