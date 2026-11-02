# frozen_string_literal: true

require "spec_helper"

describe "n+1 queries in the owned tag sets controller" do
  include LoginMacros

  describe "#edit", n_plus_one: true do
    context "with a moderator viewing a tag set with associations" do
      let!(:owner) { create(:user) }
      let!(:tag_set) { create(:owned_tag_set, owner: owner.default_pseud) }

      populate do |n|
        n.times do
          create(:tag_set_association, owned_tag_set: tag_set,
                                       tag: create(:character),
                                       parent_tag: create(:fandom))
        end
      end

      before do
        fake_login_known_user(owner)
      end

      subject do
        proc do
          get edit_tag_set_path(tag_set)
        end
      end

      warmup { subject.call }

      it "produces a constant number of queries" do
        expect do
          subject.call
          checkboxes = response.body.scan(
            /type="checkbox" name="owned_tag_set\[associations_to_remove\]/
          ).size
          expect(checkboxes).to eq(current_scale.to_i)
        end.to perform_constant_number_of_queries
      end
    end
  end
end
