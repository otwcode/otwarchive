require 'spec_helper'

describe ChaptersController do
  include LoginMacros

  describe "create" do
    before do
      @user = create(:user)
      fake_login_known_user(@user)
      @work = create(:work, authors: [@user.pseuds.first])
      @chapter_attributes = { content: "This doesn't matter" }
    end

    it "adds a new chapter" do
      expect {
        post :create, { work_id: @work.id, chapter: @chapter_attributes }
      }.to change(Chapter, :count)
      expect(@work.chapters.count).to eq 2
    end

    it "errors and renders new if a user submits only a pseud that is not theirs" do
      @user2 = create(:user)
      @chapter_attributes[:author_attributes] = {:ids => [@user2.pseuds.first.id]}
      expect {
        post :create, work_id: @work.id, chapter: @chapter_attributes
      }.to_not change(Chapter, :count)
      expect(response).to render_template("new")
      expect(flash[:error]).to eq "You're not allowed to use that pseud."
    end
  end

  describe "show" do
    let(:work) { create(:work, posted: true) }
    let(:chapter) { work.chapters.first }

    context "when the chapter is the first chapter" do
      it "increases the hit count" do
        clean_the_database
        allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("1.1.1.1")
        expect {
          get :show, work_id: work.id, id: work.chapters.first.id
        }.to change { REDIS_GENERAL.get("work_stats:#{work.id}:hit_count").to_i }.from(0).to(1)
      end
    end

    context "when the chapter is neither first nor last" do
      it "does not increase the hit count" do
      end
    end

    context "when the chapter is the last chapter" do
      context "when the referrer is nil" do
        it "increases the work hit count" do
          clean_the_database
          allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("1.1.1.1")
          request.env["HTTP_REFERER"] = nil
          get :show, work_id: work.id, id: work.chapters.last.id
          expect(REDIS_GENERAL.get("work_stats:#{work.id}:hit_count").to_i).to eq 1
        end
      end

      context "when the refferer contains the work path" do
        it "does not increase the hit count" do
          request.env["HTTP_REFERER"] = work_url(work)
          get :show, work_id: work.id, id: work.chapters.last.id
          expect(REDIS_GENERAL.get("work_stats:#{work.id}:hit_count").to_i).to eq 0
        end
      end

      context "when the referrer does not contain the work path" do
        before(:each) do
          clean_the_database
          allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("1.1.1.1")
        end

        it "increases the hit count" do
          request.env["HTTP_REFERER"] = root_url
          get :show, work_id: work.id, id: work.chapters.last.id
          expect(REDIS_GENERAL.get("work_stats:#{work.id}:hit_count").to_i).to eq 1
        end
      end
    end
  end
end
