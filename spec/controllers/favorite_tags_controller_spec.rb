require "spec_helper"

describe FavoriteTagsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "POST #create" do
    let(:user) { create(:user) }
    let(:tag) { create(:canonical_freeform) }
    let!(:favorite_tag) { create(:favorite_tag, tag_id: tag.id, user_id: user.id) }

    before do
      fake_login_known_user(user)
    end

    context "when creating a duplicate favorite" do
      it "redirects and shows an error in HTML format" do
        post :create, params: { user_id: user, favorite_tag: { tag_id: tag.id }, format: :html }
        it_redirects_to_with_error(tag_works_path(tag), ["Tag is already in your favorite tags."])
      end

      it "returns an error in JSON format" do
        post :create, params: { user_id: user, favorite_tag: { tag_id: tag.id }, format: :json }

        expect(JSON.parse(response.body)).to eq({ "errors" => ["Tag is already in your favorite tags."] })
        expect(response.status).to eq(422)
      end
    end

    context "when duplicate database inserts happen despite Rails validations" do
      # https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of-label-Concurrency+and+integrity
      #
      # We fake this scenario by skipping Rails validations.
      before do
        allow_any_instance_of(FavoriteTag).to receive(:save).and_call_original
        allow_any_instance_of(FavoriteTag).to receive(:save).with(no_args) do |fav_tag|
          fav_tag.save(validate: false) # rubocop:disable Rails/SaveBang
        end
      end

      it "redirects and shows an error in HTML format" do
        post :create, params: { user_id: user, favorite_tag: { tag_id: tag.id }, format: :html }
        it_redirects_to_with_error(tag_works_path(tag), ["Tag is already in your favorite tags."])
      end

      it "returns an error in JSON format" do
        post :create, params: { user_id: user, favorite_tag: { tag_id: tag.id }, format: :json }

        expect(JSON.parse(response.body)).to eq({ "errors" => ["Tag is already in your favorite tags."] })
        expect(response.status).to eq(422)
      end
    end
  end
end
