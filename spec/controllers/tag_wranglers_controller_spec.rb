require "spec_helper"

describe TagWranglersController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user) { create(:tag_wrangler) }

  describe "#show" do
    before { fake_login_known_user(user) }

    context "when the target user does not exist" do
      it "raises a 404 error" do
        expect do
          get :show, params: { id: -1 }
        end.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#report_csv" do
    let!(:tag1) { create(:freeform, last_wrangler: user, unwrangleable: true) }
    let!(:tag2) { create(:relationship, last_wrangler: user) }

    context "when anonymous" do
      it "prevents access" do
        get :report_csv, params: { id: user.login }
        it_redirects_to_simple(root_path)
      end
    end

    context "when logged in as a superadmin" do
      let!(:tag3) { create(:relationship, last_wrangler: user, merger: tag2) }

      before { fake_login_admin(create(:superadmin)) }

      it "renders the report" do
        get :report_csv, params: { id: user.login }
        result = CSV.parse(response.body.encode("utf-8")[1..], col_sep: "\t")
        expect(result)
          .to eq([%w[Name Last\ Updated Type Merger Fandoms Unwrangleable],
                  [tag1.name, tag1.updated_at.to_s, tag1.type, "", "", "true"],
                  [tag2.name, tag2.updated_at.to_s, tag2.type, "", "", "false"],
                  [tag3.name, tag3.updated_at.to_s, tag3.type, tag2.name, "", "false"]])
      end
    end

    context "when logged in as a tag wrangling admin" do
      let(:fandom1) { create(:canonical_fandom) }
      let(:fandom2) { create(:canonical_fandom) }

      before do
        fandom1.add_association(tag2)
        fandom2.add_association(tag2)
        fake_login_admin(create(:tag_wrangling_admin))
      end

      it "renders the report" do
        get :report_csv, params: { id: user.login }
        result = CSV.parse(response.body.encode("utf-8")[1..], col_sep: "\t")
        expect(result)
          .to eq([%w[Name Last\ Updated Type Merger Fandoms Unwrangleable],
                  [tag1.name, tag1.updated_at.to_s, tag1.type, "", "", "true"],
                  [tag2.name, tag2.updated_at.to_s, tag2.type, "", "#{fandom1.name} + #{fandom2.name}", "false"]])
      end
    end

    context "when logged in as the wrangler" do
      before { fake_login_known_user(user) }

      it "prevents access" do
        get :report_csv, params: { id: user.login }
        it_redirects_to_simple(root_path)
      end
    end
  end
end
