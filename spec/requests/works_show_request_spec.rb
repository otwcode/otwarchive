require "spec_helper"


describe "Works#show" do
  let(:work) { create(:work) }
  let(:chapter) { work.chapters.first }

  context "when the first chapter of a work is unposted" do
    before do
      work.chapters.create(position: 1, posted: false, content: "Draft content")
      chapter.update(position: 2)
    end

    context "when logged in as an admin" do
      before { sign_in create(:admin), scope: :admin }

      it "displays the unposted chapter" do
        get work_url(work)
        expect(response).to render_template(:show)
        expect(response.body).not_to include(chapter.content)
        expect(response.body).to include("Draft content")
      end
    end

    context "when logged in as a random user" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:logout_if_not_user_credentials).and_return(false)
        sign_in create(:user), scope: :user
      end

      it "displays the first posted chapter" do
        get work_url(work)
        expect(response).to render_template(:show)
        expect(response.body).to include(chapter.content)
        expect(response.body).not_to include("Draft content")
      end
    end

    context "when logged in as the work creator" do
      let(:user) { work.creatorships.first.pseud.user }

      before do
        allow_any_instance_of(ApplicationController).to receive(:logout_if_not_user_credentials).and_return(false)
        sign_in user, scope: :user
      end

      it "displays the unposted chapter" do
        get work_url(work)
        expect(response).to render_template(:show)
        expect(response.body).not_to include(chapter.content)
        expect(response.body).to include("Draft content")
      end
    end

    context "when logged in as a user who is an invited co-creator" do
      let(:user) { create(:user) }

      before do
        work.creatorships.find_or_create_by(pseud: user.default_pseud, approved: false)
        allow_any_instance_of(ApplicationController).to receive(:logout_if_not_user_credentials).and_return(false)
        sign_in user, scope: :user
      end

      it "displays the unposted chapter" do
        get work_url(work)
        expect(response).to render_template(:show)
        expect(response.body).not_to include(chapter.content)
        expect(response.body).to include("Draft content")
      end
    end

    context "when logged out" do
      it "displays the first posted chapter" do
        get work_url(work)
        expect(response).to render_template(:show)
        expect(response.body).to include(chapter.content)
        expect(response.body).not_to include("Draft content")
      end
    end
  end
end
