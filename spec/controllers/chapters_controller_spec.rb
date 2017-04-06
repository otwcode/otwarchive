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
    let(:work) { create(:work_with_chapters, chapters_count: 3, posted: true) }
    let(:first_chapter) { work.first_chapter }
    let(:middle_chapter) { work.chapters_in_order[1] }
    let(:last_chapter) { work.last_chapter }

    context "when the chapter is the first chapter" do
      it "increases the hit count" do
        expect {
          get :show, work_id: work.id, id: first_chapter.id
        }.to change { REDIS_GENERAL.get("work_stats:#{work.id}:hit_count").to_i }.by(1)
      end
    end

    context "when the chapter is neither first nor last" do
      it "does not increase the hit count" do
        expect {
          get :show, work_id: work.id, id: middle_chapter.id
        }.to_not change { REDIS_GENERAL.get("work_stats:#{work.id}:hit_count") }
      end
    end

    context "when the chapter is the last chapter" do
      context "when the referrer is nil" do
        it "increases the work hit count" do
          request.env["HTTP_REFERER"] = nil
          expect {
            get :show, work_id: work.id, id: last_chapter.id
          }.to change { REDIS_GENERAL.get("work_stats:#{work.id}:hit_count").to_i }.by(1)
        end
      end

      context "when the referrer contains the work path" do
        context "with an exact match on the work id" do
          it "does not increase the hit count" do
            request.env["HTTP_REFERER"] = work_url(work)
            expect {
              get :show, work_id: work.id, id: last_chapter.id
            }.to_not change { REDIS_GENERAL.get("work_stats:#{work.id}:hit_count") }
          end

          context "with an additional path" do
            it "does not increase the hit count" do
              request.env["HTTP_REFERER"] = work_kudos_url(work)
              expect {
                get :show, work_id: work.id, id: last_chapter.id
              }.to_not change { REDIS_GENERAL.get("work_stats:#{work.id}:hit_count") }
            end
          end

          context "with parameters" do
            it "does not increase the hit count" do
              request.env["HTTP_REFERER"] = work_url(work) + "?view_adult=true"
              expect {
                get :show, work_id: work.id, id: last_chapter.id
              }.to_not change { REDIS_GENERAL.get("work_stats:#{work.id}:hit_count") }
            end
          end
        end

        context "with an inexact match on the work id" do
          it "increases the hit count" do
            request.env["HTTP_REFERER"] = work_url(work) + "00"
            expect {
              get :show, work_id: work.id, id: last_chapter.id
            }.to change { REDIS_GENERAL.get("work_stats:#{work.id}:hit_count").to_i }.by(1)
          end
        end
      end

      context "when the referrer does not contain the work path" do
        it "increases the hit count" do
          request.env["HTTP_REFERER"] = root_url
          expect {
            get :show, work_id: work.id, id: last_chapter.id
          }.to change { REDIS_GENERAL.get("work_stats:#{work.id}:hit_count").to_i }.by(1)
        end
      end
    end
  end
end
