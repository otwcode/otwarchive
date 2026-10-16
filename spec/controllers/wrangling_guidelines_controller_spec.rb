require "spec_helper"

describe WranglingGuidelinesController do
  include HtmlCleaner
  include LoginMacros
  include RedirectExpectationHelper
  let(:admin) { create(:admin) }

  describe "GET #index" do
    let!(:guideline1) { create(:wrangling_guideline, position: 9001) }
    let!(:guideline2) { create(:wrangling_guideline, position: 2) }
    let!(:guideline3) { create(:wrangling_guideline, position: 7) }

    it "renders" do
      get :index
      expect(response).to render_template("index")
      expect(assigns(:wrangling_guidelines)).to eq([guideline2, guideline3, guideline1])
    end
  end

  describe "GET #show" do
    let(:guideline) { create(:wrangling_guideline) }

    it "renders" do
      get :show, params: { id: guideline.id }
      expect(response).to render_template("show")
      expect(assigns(:wrangling_guideline)).to eq(guideline)
    end
  end

  describe "GET #new" do
    it "blocks non-admins" do
      fake_logout
      get :new
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")

      fake_login
      get :new
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    %w[board communications translation policy_and_abuse docs support open_doors].each do |role|
      context "when logged in as an admin with #{role} role" do 
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with error" do
          fake_login_admin(admin)
          get :new
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[tag_wrangling superadmin].each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it "renders" do
          fake_login_admin(admin)
          get :new
          expect(response).to render_template("new")
          expect(assigns(:wrangling_guideline)).to be_a_new(WranglingGuideline)
        end
      end
    end
  end

  describe "GET #edit" do
    it "blocks non-admins" do
      fake_logout
      get :edit, params: { id: 1 }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")

      fake_login
      get :edit, params: { id: 1 }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    %w[board communications translation policy_and_abuse docs support open_doors].each do |role|
      context "when logged in as an admin with #{role} role" do 
        let(:guideline) { create(:wrangling_guideline) }
        let(:admin) { create(:admin, roles: [role]) }
        
        before { fake_login_admin(admin) }

        it "redirects with error" do 
          get :edit, params: { id: guideline.id }
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[tag_wrangling superadmin].each do |role| 
      context "when logged in as an admin with #{role} role" do 
        let(:guideline) { create(:wrangling_guideline) }
        let(:admin) { create(:admin, roles: [role]) }

        before { fake_login_admin(admin) }

        it "renders" do
          get :edit, params: { id: guideline.id }
          expect(response).to render_template("edit")
          expect(assigns(:wrangling_guideline)).to eq(guideline)
        end
      end
    end
  end

  describe "GET #manage" do
    it "blocks non-admins" do
      fake_logout
      get :manage
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")

      fake_login
      get :manage
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    %w[board communications translation policy_and_abuse docs support open_doors].each do |role|
      context "when logged in as an admin with #{role} role" do 
        let(:admin) { create(:admin, roles: [role]) }

        before { fake_login_admin(admin) }

        it "redirects with error" do 
          get :manage
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[tag_wrangling superadmin].each do |role| 
      context "when logged in as an admin with #{role} role" do 
        let!(:guideline1) { create(:wrangling_guideline, position: 9001) }
        let!(:guideline2) { create(:wrangling_guideline, position: 2) }
        let!(:guideline3) { create(:wrangling_guideline, position: 7) }
        let(:admin) { create(:admin, roles: [role]) }

        before { fake_login_admin(admin) }

        it "renders" do
          get :manage
          expect(response).to render_template("manage")
          expect(assigns(:wrangling_guidelines)).to eq([guideline2, guideline3, guideline1])
        end
      end
    end
  end

  describe "POST #create" do
    it "blocks non-admins" do
      fake_logout
      post :create
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")

      fake_login
      post :create
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    %w[board communications translation policy_and_abuse docs support open_doors].each do |role|
      context "when logged in as an admin with #{role} role" do 
        let(:admin) { create(:admin, roles: [role]) }

        before { fake_login_admin(admin) }

        it "redirects with error" do 
          title = "Wrangling 101"
          content = "JUST DO IT!"
          post :create, params: { wrangling_guideline: { title: title, content: content } }          
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[tag_wrangling superadmin].each do |role| 
      context "when logged in as an admin with #{role} role" do 
        let(:admin) { create(:admin, roles: [role]) }

        before { fake_login_admin(admin) }

        it "creates and redirects to new wrangling guideline" do
          title = "Wrangling 101"
          content = "JUST DO IT!"
          post :create, params: { wrangling_guideline: { title: title, content: content } }
  
          guideline = WranglingGuideline.find_by(title: title)
          expect(assigns(:wrangling_guideline)).to eq(guideline)
          expect(assigns(:wrangling_guideline).content).to eq(sanitize_value("content", content))
          it_redirects_to_with_notice(wrangling_guideline_path(guideline), "Wrangling Guideline was successfully created.")
        end
  
        it "renders new if create fails" do
          # Cannot save a content-free guideline
          post :create, params: { wrangling_guideline: { title: "Wrangling 101" } }
          expect(response).to render_template("new")
        end
      end
    end
  end

  describe "PUT #update" do
    it "blocks non-admins" do
      fake_logout
      put :update, params: { id: 1 }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")

      fake_login
      put :update, params: { id: 1 }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    %w[board communications translation policy_and_abuse docs support open_doors].each do |role|
      context "when logged in as an admin with #{role} role" do 
        let(:guideline) { create(:wrangling_guideline) }
        let(:admin) { create(:admin, roles: [role]) }

        before { fake_login_admin(admin) }

        it "redirects with error" do 
          title = "Wrangling 101"
          expect(guideline.title).not_to eq(title)
          put :update, params: { id: guideline.id, wrangling_guideline: { title: title } }          
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[tag_wrangling superadmin].each do |role| 
      context "when logged in as an admin with #{role} role" do 
        let(:guideline) { create(:wrangling_guideline) }
        let(:admin) { create(:admin, roles: [role]) }

        before { fake_login_admin(admin) }

        it "updates and redirects to updated wrangling guideline" do
          title = "Wrangling 101"
          expect(guideline.title).not_to eq(title)
  
          put :update, params: { id: guideline.id, wrangling_guideline: { title: title } }
  
          expect(assigns(:wrangling_guideline)).to eq(guideline)
          expect(assigns(:wrangling_guideline).title).to eq(title)
          it_redirects_to_with_notice(wrangling_guideline_path(guideline), "Wrangling Guideline was successfully updated.")
        end
  
        it "renders edit if update fails" do
          put :update, params: { id: guideline.id, wrangling_guideline: { title: nil } }
          expect(response).to render_template("edit")
        end
      end
    end
  end

  describe "POST #update_positions" do
    it "blocks non-admins" do
      fake_logout
      post :update_positions
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")

      fake_login
      post :update_positions
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    %w[board communications translation policy_and_abuse docs support open_doors].each do |role|
      context "when logged in as an admin with #{role} role" do 
        let!(:guideline1) { create(:wrangling_guideline, position: 1) }
        let!(:guideline2) { create(:wrangling_guideline, position: 2) }
        let!(:guideline3) { create(:wrangling_guideline, position: 3) }
        let(:admin) { create(:admin, roles: [role]) }

        before { fake_login_admin(admin) }

        it "redirects with error" do 
          expect(WranglingGuideline.order("position ASC")).to eq([guideline1, guideline2, guideline3])
          post :update_positions, params: { wrangling_guidelines: [3, 2, 1] }          
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[tag_wrangling superadmin].each do |role| 
      context "when logged in as an admin with #{role} role" do 
        let!(:guideline1) { create(:wrangling_guideline, position: 1) }
        let!(:guideline2) { create(:wrangling_guideline, position: 2) }
        let!(:guideline3) { create(:wrangling_guideline, position: 3) }
        let(:admin) { create(:admin, roles: [role]) }

        before { fake_login_admin(admin) }

        it "updates positions and redirects to index" do
          expect(WranglingGuideline.order("position ASC")).to eq([guideline1, guideline2, guideline3])
          post :update_positions, params: { wrangling_guidelines: [3, 2, 1] }
  
          expect(assigns(:wrangling_guidelines)).to eq(WranglingGuideline.order("position ASC"))
          expect(assigns(:wrangling_guidelines)).to eq([guideline3, guideline2, guideline1])
          it_redirects_to_with_notice(wrangling_guidelines_path, "Wrangling Guidelines order was successfully updated.")
        end
  
        it "redirects to index given no params" do
          post :update_positions
          it_redirects_to(wrangling_guidelines_path)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    it "blocks non-admins" do
      fake_logout
      delete :destroy, params: { id: 1 }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")

      fake_login
      delete :destroy, params: { id: 1 }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    %w[board communications translation policy_and_abuse docs support open_doors].each do |role|
      context "when logged in as an admin with #{role} role" do 
        let(:guideline) { create(:wrangling_guideline) }
        let(:admin) { create(:admin, roles: [role]) }

        before { fake_login_admin(admin) }

        it "redirects with error" do 
          delete :destroy, params: { id: guideline.id }

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[tag_wrangling superadmin].each do |role| 
      context "when logged in as an admin with #{role} role" do 
        let(:guideline) { create(:wrangling_guideline) }
        let(:admin) { create(:admin, roles: [role]) }

        before { fake_login_admin(admin) }

        it "deletes and redirects to index" do
          delete :destroy, params: { id: guideline.id }
          expect(WranglingGuideline.find_by(id: guideline.id)).to be_nil
          it_redirects_to_with_notice(wrangling_guidelines_path, "Wrangling Guideline was successfully deleted.")
        end
      end
    end
  end
end
