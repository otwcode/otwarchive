# frozen_string_literal: true

require "spec_helper"

describe ApplicationHelper do
  describe "#creation_id_for_css_classes" do
    context "when creation is ExternalWork" do
      let(:external_work) { create(:external_work) }

      it "returns string for exteral work" do
        result = creation_id_for_css_classes(external_work)
        expect(result).to eq("external-work-#{external_work.id}")
      end
    end

    context "when creation is Series" do
      let(:series) { create(:series) }

      it "returns string for series" do
        result = creation_id_for_css_classes(series)
        expect(result).to eq("series-#{series.id}")
      end
    end

    context "when creation is Work" do
      let(:work) { create(:work) }

      it "returns string for work" do
        result = creation_id_for_css_classes(work)
        expect(result).to eq("work-#{work.id}")
      end
    end
  end

  describe "#creator_ids_for_css_classes" do
    context "when creation is ExternalWork" do
      let(:external_work) { create(:external_work) }

      it "returns nil for exteral work" do
        result = creator_ids_for_css_classes(external_work)
        expect(result).to be_nil
      end
    end

    context "when creation is Series" do
      let(:series) { create(:series) }

      it "returns nil for series" do
        result = creator_ids_for_css_classes(series)
        expect(result).to be_nil
      end
    end

    context "when creation is Work" do
      let(:work) { create(:work) }
      let(:user1) { work.users.first }

      it "returns string for work" do
        result = creator_ids_for_css_classes(work)
        expect(result).to eq("user-#{user1.id}")
      end

      context "with multiple pseuds from same user" do
        let(:user1_pseud2) { create(:pseud, user: user1) }

        before do
          work.creatorships.find_or_create_by(pseud_id: user1_pseud2.id)
        end

        it "returns string with one user" do
          result = creator_ids_for_css_classes(work)
          expect(result).to eq("user-#{user1.id}")
        end
      end

      context "with pseuds from multiple users" do
        let(:user2) { create(:user) }

        before do
          work.creatorships.find_or_create_by(pseud_id: user2.default_pseud_id)
        end

        it "returns string with all users" do
          result = creator_ids_for_css_classes(work)
          expect(result).to eq("user-#{user1.id} user-#{user2.id}")
        end
      end

      context "when work is anonymous" do
        let(:collection) { create(:anonymous_collection) }

        before { work.collections << collection }

        it "returns nil" do
          result = creator_ids_for_css_classes(work)
          expect(result).to be_nil
        end
      end

      context "when work is unrevealed" do
        let(:collection) { create(:unrevealed_collection) }

        before { work.collections << collection }

        it "returns nil" do
          result = creator_ids_for_css_classes(work)
          expect(result).to be_nil
        end
      end

      context "when work has external author" do
        let(:external_creatorship) { create(:external_creatorship, work: work) }

        it "returns string with user" do
          result = creator_ids_for_css_classes(work)
          expect(result).to eq("user-#{user1.id}")
        end
      end
    end
  end

  describe "#css_classes_for_creation_blurb" do
    let(:default_classes) { "blurb group" }

    context "when creation is ExternalWork" do
      let(:external_work) { create(:external_work) }

      it "returns string with default classes and creation info" do
        result = css_classes_for_creation_blurb(external_work)
        expect(result).to eq("#{default_classes} external-work-#{external_work.id}")
      end
    end

    context "when creation is Series" do
      let(:series) { create(:series) }

      it "returns string with default classes and creation info" do
        result = css_classes_for_creation_blurb(series)
        expect(result).to eq("#{default_classes} series-#{series.id}")
      end
    end

    context "when creation is Work" do
      let(:work) { create(:work) }
      let(:user1) { work.users.first }
      let(:user2) { create(:user) }

      it "returns string with default classes and creation and creator info" do
        result = css_classes_for_creation_blurb(work)
        expect(result).to eq("#{default_classes} work-#{work.id} user-#{user1.id}")
      end

      context "when new user is added" do
        it "returns updated string" do
          travel_to(Time.parse("2021-01-01"))
          original_cache_key = "#{work.cache_key_with_version}/blurb_css_classes"
          expect(css_classes_for_creation_blurb(work)).to eq("#{default_classes} work-#{work.id} user-#{user1.id}")

          travel_back
          work.creatorships.find_or_create_by(pseud_id: user2.default_pseud_id)
          expect(css_classes_for_creation_blurb(work)).to eq("#{default_classes} work-#{work.id} user-#{user1.id} user-#{user2.id}")
          expect(original_cache_key).not_to eq("#{work.cache_key_with_version}/blurb_css_classes")
        end
      end

      context "when user is removed" do
        it "returns updated string" do
          travel_to(Time.parse("2021-01-01"))
          work.creatorships.find_or_create_by(pseud_id: user2.default_pseud_id)
          original_cache_key = "#{work.cache_key_with_version}/blurb_css_classes"
          expect(css_classes_for_creation_blurb(work)).to eq("#{default_classes} work-#{work.id} user-#{user1.id} user-#{user2.id}")

          travel_back
          work.creatorships.find_by(pseud_id: user2.default_pseud_id).destroy
          expect(css_classes_for_creation_blurb(work)).to eq("#{default_classes} work-#{work.id} user-#{user1.id}")
          expect(original_cache_key).not_to eq("#{work.cache_key_with_version}/blurb_css_classes")
        end
      end

      context "when work becomes anonymous" do
        let(:collection) { create(:anonymous_collection) }

        it "returns updated string" do
          travel_to(Time.parse("2021-01-01"))
          original_cache_key = "#{work.cache_key_with_version}/blurb_css_classes"
          expect(css_classes_for_creation_blurb(work)).to eq("#{default_classes} work-#{work.id} user-#{user1.id}")

          travel_back
          work.collections << collection
          expect(css_classes_for_creation_blurb(work)).to eq("#{default_classes} work-#{work.id}")
          expect(original_cache_key).not_to eq("#{work.cache_key_with_version}/blurb_css_classes")
        end
      end

      context "when work becomes unrevealed" do
        let(:collection) { create(:unrevealed_collection) }

        it "returns updated string" do
          travel_to(Time.parse("2021-01-01"))
          original_cache_key = "#{work.cache_key_with_version}/blurb_css_classes"
          expect(css_classes_for_creation_blurb(work)).to eq("#{default_classes} work-#{work.id} user-#{user1.id}")

          travel_back
          work.collections << collection
          expect(css_classes_for_creation_blurb(work)).to eq("#{default_classes} work-#{work.id}")
          expect(original_cache_key).not_to eq("#{work.cache_key_with_version}/blurb_css_classes")
        end
      end
    end
  end
end
