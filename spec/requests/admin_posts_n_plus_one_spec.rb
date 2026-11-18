require "spec_helper"

describe "n+1 queries in the admin posts controller" do
  include LoginMacros

  describe "#index", n_plus_one: true do
    subject do
      proc do
        get admin_posts_path
      end
    end

    populate do |n|
      n.times { |i| create(:admin_post, tag_list: "Tag #{i}") }
    end

    it "produces 2 queries per admin post" do
      expect do
        subject.call
        expect(response.body.scan('<div class="news module group').size).to eq(current_scale.to_i)
      end.to perform_linear_number_of_queries(slope: 2).with_warming_up # The translations which are individually eager-loaded and the comment count
    end
  end
end
