require "spec_helper"

describe TagWranglersController do
  include LoginMacros
  include RedirectExpectationHelper

  wrangling_roles = %w[superadmin tag_wrangling]

  let(:user) { create(:tag_wrangler) }

  shared_examples "denies access to unauthorized admins" do
    context "when logged in as an admin with no role" do
      let(:admin) { create(:admin) }

      it "redirects with an error" do
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - wrangling_roles).each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        it "redirects with an error" do
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end
  end

  describe "#index" do
    before do
      Role.create!(name: "tag_wrangler")
    end

    it_behaves_like "denies access to unauthorized admins" do
      before do
        fake_login_admin(admin)
        get :index
      end
    end

    wrangling_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        before do
          fake_login_admin(admin)
        end

        it "allows access" do
          get :index
          expect(response).to have_http_status(:success)
        end
      end
    end

    context "when logged in as a tag wrangler" do
      before do
        fake_login_known_user(user)
      end

      it "allows access" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "#show" do
    before { fake_login_known_user(user) }

    context "when the target user does not exist" do
      it "raises a 404 error" do
        expect do
          get :show, params: { id: -1 }
        end.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    it_behaves_like "denies access to unauthorized admins" do
      before do
        fake_login_admin(admin)
        get :show, params: { id: user.login }
      end
    end

    wrangling_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        before do
          fake_login_admin(admin)
        end

        it "allows access" do
          get :show, params: { id: user.login }
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "#report_csv" do
    shared_examples "prevents access to the report" do
      it "redirects with an error" do
        get :report_csv, params: { id: user.login }
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when not logged in" do
      it_behaves_like "prevents access to the report"
    end

    context "when logged in as the wrangler" do
      before { fake_login_known_user(user) }

      it_behaves_like "prevents access to the report"
    end

    it_behaves_like "denies access to unauthorized admins" do
      before do
        fake_login_admin(admin)
        get :report_csv, params: { id: user.login }
      end
    end

    context "when logged in as an admin with proper authorization" do
      before { fake_login_admin(admin) }

      wrangling_roles.each do |admin_role|
        context "with role #{admin_role}" do
          let(:admin) { create(:admin, roles: [admin_role]) }

          it "allows access to the report" do
            get :report_csv, params: { id: user.login }
            expect(response).to have_http_status(:success)
          end

          it "only includes wrangling activity for the specified user" do
            other_user = create(:user)
            tag1 = create(:tag, last_wrangler: user)
            create(:tag, last_wrangler: other_user)

            get :report_csv, params: { id: user.login }
            result = CSV.parse(response.body.encode("utf-8")[1..], col_sep: "\t")

            expect(result)
              .to eq([["Name", "Last Updated", "Type", "Merger", "Fandoms", "Unwrangleable"],
                      [tag1.name, tag1.updated_at.to_s, tag1.type, "", "", "false"]])
          end

          it "limits the number of tags" do
            stub_const("ArchiveConfig", OpenStruct.new(ArchiveConfig))
            ArchiveConfig.WRANGLING_REPORT_LIMIT = 1
            create(:tag, last_wrangler: user)
            tag2 = create(:tag, last_wrangler: user)

            get :report_csv, params: { id: user.login }
            result = CSV.parse(response.body.encode("utf-8")[1..], col_sep: "\t")

            expect(result.length).to eq(2)
            expect(result[1][0]).to eq(tag2.name)
          end

          it "correctly reports mergers" do
            tag1 = create(:tag, last_wrangler: user)
            tag2 = create(:tag, last_wrangler: user, merger: tag1)

            get :report_csv, params: { id: user.login }
            result = CSV.parse(response.body.encode("utf-8")[1..], col_sep: "\t")

            expect(result)
              .to eq([["Name", "Last Updated", "Type", "Merger", "Fandoms", "Unwrangleable"],
                      [tag2.name, tag2.updated_at.to_s, tag2.type, tag1.name, "", "false"],
                      [tag1.name, tag1.updated_at.to_s, tag1.type, "", "", "false"]])
          end

          it "correctly reports tags with one fandom" do
            fandom = create(:canonical_fandom)
            tag = create(:freeform, last_wrangler: user)
            expect(fandom.add_association(tag)).to be_truthy

            get :report_csv, params: { id: user.login }
            result = CSV.parse(response.body.encode("utf-8")[1..], col_sep: "\t")

            expect(result)
              .to eq([["Name", "Last Updated", "Type", "Merger", "Fandoms", "Unwrangleable"],
                      [tag.name, tag.updated_at.to_s, tag.type, "", fandom.name, "false"]])
          end

          it "correctly reports tags with multiple fandoms" do
            fandom1 = create(:canonical_fandom)
            fandom2 = create(:canonical_fandom)
            tag = create(:relationship, last_wrangler: user)
            expect(fandom1.add_association(tag)).to be_truthy
            expect(fandom2.add_association(tag)).to be_truthy

            get :report_csv, params: { id: user.login }
            result = CSV.parse(response.body.encode("utf-8")[1..], col_sep: "\t")

            expect(result)
              .to eq([["Name", "Last Updated", "Type", "Merger", "Fandoms", "Unwrangleable"],
                      [tag.name, tag.updated_at.to_s, tag.type, "", "#{fandom1.name}, #{fandom2.name}", "false"]])
          end

          it "only includes parent fandoms" do
            fandom = create(:canonical_fandom)
            media = create(:media, last_wrangler: user)
            expect(media.add_association(fandom)).to be_truthy

            get :report_csv, params: { id: user.login }
            result = CSV.parse(response.body.encode("utf-8")[1..], col_sep: "\t")

            expect(result[1][4]).to be_empty
          end

          it "correctly reports a tag marked unwrangleable" do
            tag = create(:tag, last_wrangler: user, unwrangleable: true)

            get :report_csv, params: { id: user.login }
            result = CSV.parse(response.body.encode("utf-8")[1..], col_sep: "\t")

            expect(result)
              .to eq([["Name", "Last Updated", "Type", "Merger", "Fandoms", "Unwrangleable"],
                      [tag.name, tag.updated_at.to_s, tag.type, "", "", "true"]])
          end
        end
      end
    end
  end

  describe "#create" do
    let(:fandom) { create(:fandom) }

    it_behaves_like "denies access to unauthorized admins" do
      before do
        fake_login_admin(admin)
        post :create, params: { assignments: { fandom.id.to_s => [user.login] } }
      end
    end

    wrangling_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        before do
          fake_login_admin(admin)
        end

        it "creates wrangling assignments" do
          post :create, params: { assignments: { fandom.id.to_s => [user.login] } }
          it_redirects_to_with_notice(tag_wranglers_path, "Wranglers were successfully assigned!")
        end
      end
    end

    context "when logged in as another tag wrangler" do
      before do
        fake_login_known_user(create(:tag_wrangler))
      end

      it "allows access" do
        post :create, params: { assignments: { fandom.id.to_s => [user.login] } }
        it_redirects_to_with_notice(tag_wranglers_path, "Wranglers were successfully assigned!")
      end
    end
  end

  describe "#destroy" do
    let(:wrangling_assignment) { create(:wrangling_assignment) }

    it_behaves_like "denies access to unauthorized admins" do
      before do
        fake_login_admin(admin)
        delete :destroy, params: { id: wrangling_assignment.user.login, fandom_id: wrangling_assignment.fandom.id }
      end
    end

    wrangling_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        before do
          fake_login_admin(admin)
        end

        it "removes the wrangling assignment" do
          delete :destroy, params: { id: wrangling_assignment.user.login, fandom_id: wrangling_assignment.fandom.id }
          it_redirects_to_with_notice(tag_wranglers_path, "Wranglers were successfully unassigned!")
        end
      end
    end

    context "when logged in as another tag wrangler" do
      before do
        fake_login_known_user(create(:tag_wrangler))
      end

      it "allows access" do
        delete :destroy, params: { id: wrangling_assignment.user.login, fandom_id: wrangling_assignment.fandom.id }
        it_redirects_to_with_notice(tag_wranglers_path, "Wranglers were successfully unassigned!")
      end
    end
  end
end
