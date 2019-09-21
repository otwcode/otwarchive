require 'spec_helper'

describe PseudQuery, type: :model, pseud_search: true do
  let!(:pseuds) do
    users = {
      user_abc: create(:user, login: "abc"),
      user_abc_d: create(:user, login: "abc_d"),
      user_abc_num: create(:user, login: "abc123"),
      user_foo: create(:user, login: "foo"),
      user_bar: create(:user, login: "bar"),
      user_aisha: create(:user, login: "aisha")
    }
    pseuds = {
      pseud_abc: users[:user_abc].default_pseud,
      pseud_abc_d: users[:user_abc_d].default_pseud,
      pseud_abc_d_2: create(:pseud, user: users[:user_abc_d], name: "Abc_ D"),
      pseud_abc_num: users[:user_abc_num].default_pseud,
      pseud_abc_num_2: create(:pseud, user: users[:user_abc_num], name: "Abc 123 Pseud"),
      pseud_foo: users[:user_foo].default_pseud,
      pseud_foo_2: create(:pseud, user: users[:user_foo], name: "bar"),
      pseud_bar: users[:user_bar].default_pseud,
      pseud_bar_2: create(:pseud, user: users[:user_bar], name: "foo"),
      pseud_aisha: create(:pseud, user: users[:user_aisha], name: "عيشة")
    }
    run_all_indexing_jobs
    pseuds
  end

  context "Search all fields" do
    it "performs a case-insensitive search" do
      pseud_query = PseudQuery.new(query: "AbC")
      names = pseud_query.search_results.map(&:name)
      expect(names[0..2]).to eq(
        ["abc", "Abc 123 Pseud", "abc123"]
      )
      # these two have the same score
      expect(names).to include("abc_d", "Abc_ D")
    end

    it "matches a pseud with and without numbers" do
      pseud_query = PseudQuery.new(query: "abc123")
      names = pseud_query.search_results.map(&:name)
      expect(names[0..2]).to eq(
        ["abc123", "Abc 123 Pseud", "abc"]
      )
      expect(names).to include("abc_d", "Abc_ D")
    end

    it "matches both pseud and user and ranks the pseud match higher" do
      pseud_query = PseudQuery.new(query: "bar")
      bylines = pseud_query.search_results.map(&:byline)
      expect(bylines).to eq(
        ["bar", "bar (foo)", "foo (bar)"]
      )
    end
  end

  context "Name field" do
    it "performs a case-insensitive search" do
      pseud_query = PseudQuery.new(name: "AbC")
      names = pseud_query.search_results.map(&:name)
      expect(names).to eq(["abc", "Abc 123 Pseud"])
    end

    it "matches a pseud with and without numbers" do
      pseud_query = PseudQuery.new(name: "abc123")
      names = pseud_query.search_results.map(&:name)
      expect(names).to eq(["abc123", "Abc 123 Pseud"])
    end

    it "matches multiple pseuds with and without numbers and returns exact matches first" do
      pseud_query = PseudQuery.new(name: "abc123,عيشة")
      names = pseud_query.search_results.map(&:name)
      expect(names).to include("abc123", "عيشة")
      expect(names.last).to eq("Abc 123 Pseud")
    end
  end
end
