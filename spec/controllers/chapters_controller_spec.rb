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
    let(:chapter) { create(:chapter) }
    let(:work) { Work.find(chapter.work_id) }

    context "when the chapter is the first chapter" do
      context "when someone visits once" do
        it "increases the work hit count" do
          expect {
            get :show, work_id: work.id, id: work.chapters.first.id
          }.to change {REDIS_GENERAL.get("work_stats:#{work.id}:hit_count").to_i}.from(0).to(1)
        end
      end
      
      context "when someone visits twice in a row" do      
        it "increases the work hit count by one" do
        end
      end
        
      context "when someone visits twice, but their visits are interrupted by another visitor" do
        it "increases the work hit count by three" do
        end
      end
    end

    context "when the chapter is neither first nor last" do
      it "does not increase the hit count" do
      end
    end

    context "when the chapter is the last chapter" do
      context "when the referrer is nil" do
        context "when someone visits once" do
          it "increases the work hit count by one" do
          end
        end

        context "when someone visits twice in a row" do
          it "increases the work hit count by one" do
          end
        end      

        context "when someone visits twice, but their visits are interrupted by another visitor" do
          it "increases the work hit count by three" do
          end
        end
      end

      context "when the referrer does not contain the work path" do
        context "when someone visits once" do
          it "increases the work hit count by one" do
          end
        end

        context "when someone visits twice in a row" do
          it "increases the work hit count by one" do
          end
        end      

        context "when someone visits twice, but their visits are interrupted by another visitor" do
          it "increases the work hit count by three" do
          end
        end
      end

      context "when the referrer contains the work path" do
        it "does not increase the hit count" do
        end
      end
    end
  end
end