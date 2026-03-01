require "spec_helper"

describe TagQuery do
  describe "#search_results", tag_search: true do
    let!(:time) { Time.current }
    let!(:tags) do
      tags = {
        char_abc: create(:character, name: "abc"),
        char_abc_d_minus: create(:character, name: "abc -d"),
        char_abc_d: create(:character, name: "abc d"),
        fan_abcd: create(:fandom, name: "abcd", created_at: time),
        fan_abc_d_minus: create(:fandom, name: "abc-d"),
        fan_yuri: create(:fandom, name: "Yuri!!! On Ice"),
        free_abcplus: create(:freeform, name: "abc+"),
        free_abccc: create(:freeform, name: "abccc", created_at: time),
        free_abapos: create(:freeform, name: "ab'c d"),
        rel_slash: create(:relationship, name: "ab/cd"),
        rel_space: create(:relationship, name: "ab cd"),
        rel_quotes: create(:relationship, name: "ab \"cd\" ef"),
        rel_unicode: create(:relationship, name: "Dave ♦ Sawbuck")
      }
      run_all_indexing_jobs
      tags
    end

    it "performs a case-insensitive search ('AbC' matches 'abc')" do
      tag_query = TagQuery.new(name: "AbC")
      results = tag_query.search_results
      results.first.should eq(tags[:char_abc])
      results.should include(tags[:free_abcplus])
    end

    it "performs a query string search ('ab OR cd' matches 'ab cd', 'ab/cd' and 'ab “cd” ef')" do
      tag_query = TagQuery.new(name: "ab OR cd")
      results = tag_query.search_results
      results.should include(tags[:rel_slash])
      results.should include(tags[:rel_space])
      results.should include(tags[:rel_quotes])
    end

    it "performs an exact match with quotes ('xgh OR “abc d”' matches 'abc d')" do
      tag_query = TagQuery.new(name: 'xgh OR "abc d"')
      results = tag_query.search_results
      results.should include(tags[:char_abc_d])
    end

    it "lists closest matches at the top of the results ('abc' result lists 'abc' first)" do
      tag_query = TagQuery.new(name: "abc")
      results = tag_query.search_results
      results.first.should eq(tags[:char_abc])
      results.should include(tags[:char_abc_d])
      results.should include(tags[:free_abcplus])
      results.should include(tags[:fan_abc_d_minus])
    end

    it "matches every token in any order ('d abc' matches 'abc d' and 'abc-d', but not 'abc' or 'abc+')" do
      tag_query = TagQuery.new(name: "d abc")
      results = tag_query.search_results
      results.should include(tags[:char_abc_d])
      results.should include(tags[:fan_abc_d_minus])
      results.should_not include(tags[:free_abcplus])
      results.should_not include(tags[:char_abc])
    end

    it "matches tokens with double quotes ('ab \"cd\" ef' matches 'ab \"cd\" ef')" do
      tag_query = TagQuery.new(name: "ab \"cd\" ef")
      results = tag_query.search_results
      results.should include(tags[:rel_quotes])
    end

    it "matches tokens with single quotes ('ab'c d' matches 'ab'c d')" do
      tag_query = TagQuery.new(name: "ab'c d")
      results = tag_query.search_results
      results.should include(tags[:free_abapos])
    end

    it "performs a wildcard search at the end of a term ('abc*' matches 'abcd' and 'abcde')" do
      tag_query = TagQuery.new(name: "abc*")
      results = tag_query.search_results
      results.should include(tags[:char_abc])
      results.should include(tags[:fan_abcd])
      results.should include(tags[:free_abccc])
      results.should_not include(tags[:relationship])
    end

    it "performs a wildcard search in the middle of a term ('a*d' matches 'abcd')" do
      tag_query = TagQuery.new(name: "a*d")
      results = tag_query.search_results
      results.should include(tags[:fan_abcd])
    end

    it "performs a wildcard search at the beginning of a term ('*cd' matches 'abcd')" do
      tag_query = TagQuery.new(name: "*cd")
      results = tag_query.search_results
      results.should include(tags[:fan_abcd])
    end

    it "preserves plus (+) character ('abc+' matches 'abc+' and 'abc', but not 'abccc')" do
      tag_query = TagQuery.new(name: "abc+")
      results = tag_query.search_results
      results.should include(tags[:free_abcplus])
      results.should include(tags[:char_abc])
      results.should_not include(tags[:free_abccc])
    end

    it "preserves minus (-) character ('abc-d' matches 'abc-d', 'abc -d', 'abc d' but not 'abc' or 'abcd')" do
      tag_query = TagQuery.new(name: "abc-d")
      results = tag_query.search_results
      results.should include(tags[:fan_abc_d_minus])
      results.should include(tags[:char_abc_d_minus])
      results.should_not include(tags[:fan_abcd])
      results.should_not include(tags[:char_abc])
    end

    it "preserves minus (-) preceded by a space ('abc -d' matches 'abc -d', 'abc d' and 'abc-d', but not 'abc')" do
      tag_query = TagQuery.new(name: "abc -d")
      results = tag_query.search_results
      results.first.should eq(tags[:char_abc_d_minus])
      results.should include(tags[:char_abc_d])
      results.should include(tags[:fan_abc_d_minus])
      results.should_not include(tags[:char_abc])
    end

    it "preserves slashes without quotes ('ab/cd' should match 'ab/cd' and 'ab cd')" do
      tag_query = TagQuery.new(name: "ab/cd")
      results = tag_query.search_results
      results.should include(tags[:rel_slash])
      results.should include(tags[:rel_space])
    end

    it "matches tags with canonical punctuation ('yuri!!!' on ice matches 'Yuri!!! On Ice')" do
      tag_query = TagQuery.new(name: "yuri!!! on ice")
      results = tag_query.search_results
      results.should include(tags[:fan_yuri])
    end

    it "matches tags without canonical punctuation ('yuri on ice' matches 'Yuri!!! On Ice')" do
      tag_query = TagQuery.new(name: "yuri on ice")
      results = tag_query.search_results
      results.should include(tags[:fan_yuri])
    end

    it "matches unicode tags with unicode character ('Dave ♦ Sawbuck' matches 'Dave ♦ Sawbuck')" do
      tag_query = TagQuery.new(name: "dave ♦ sawbuck")
      results = tag_query.search_results
      results.should include(tags[:rel_unicode])
    end

    it "matches unicode tags without unicode character ('dave sawbuck' matches 'Dave ♦ Sawbuck')" do
      tag_query = TagQuery.new(name: "dave sawbuck")
      results = tag_query.search_results
      results.should include(tags[:rel_unicode])
    end

    it "defaults to TAGS_PER_SEARCH_PAGE to determine the number of results" do
      allow(ArchiveConfig).to receive(:TAGS_PER_SEARCH_PAGE).and_return(5)
      tag_query = TagQuery.new(name: "a*")
      results = tag_query.search_results
      expect(results.size).to eq 5
    end

    it "keeps sort order of tied tags the same when tag info is updated" do
      tag_query = TagQuery.new(name: "abc*", sort_column: "created_at")
      results = tag_query.search_results.map(&:id)

      [tags[:fan_abcd], tags[:free_abccc]].each do |tag|
        tag.update!(canonical: true)
        run_all_indexing_jobs
        expect(tag_query.search_results.map(&:id)).to eq(results)
      end
    end
  end

  describe "#generated_query" do
    it "matches all tags when no search parameters are specified" do
      q = TagQuery.new
      expect(q.generated_query[:query]).to eq({ match_all: {} })
    end

    it "filters tags by multiple fandom ids" do
      q = TagQuery.new(fandom_ids: [6, 7])
      expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { fandom_ids: 6 } }, { term: { fandom_ids: 7 } })
    end

    it "allows you to sort by Date Created" do
      q = TagQuery.new(sort_column: "created_at")
      expect(q.generated_query[:sort]).to eq([{ "created_at" => { order: "desc", unmapped_type: "date" } }, { id: { order: "desc" } }])
    end

    it "allows you to sort by Date Created in ascending order" do
      q = TagQuery.new(sort_column: "created_at", sort_direction: "asc")
      expect(q.generated_query[:sort]).to eq([{ "created_at" => { order: "asc", unmapped_type: "date" } }, { id: { order: "asc" } }])
    end

    it "allows you to sort by Uses" do
      q = TagQuery.new(sort_column: "uses")
      expect(q.generated_query[:sort]).to eq([{ "uses" => { order: "desc" } }, { "name.keyword" => { order: "asc" } }, { id: { order: "desc" } }])
    end

    it "allows you to sort by Uses in ascending order" do
      q = TagQuery.new(sort_column: "uses", sort_direction: "asc")
      expect(q.generated_query[:sort]).to eq([{ "uses" => { order: "asc" } }, { "name.keyword" => { order: "asc" } }, { id: { order: "asc" } }])
    end
  end

  describe "to_wrangle", tag_search: true do
    let!(:tags) do
      tags = {
        used: create(:character, taggings_count_cache: 5),
        unused_but_canonical: create(:canonical_character),
        unused_and_not_canonical: create(:character),
        used_and_canonical: create(:canonical_character, taggings_count_cache: 5),
        unwrangleable: create(:character, taggings_count_cache: 5, unwrangleable: true),
        wrangled: create(:canonical_character, common_taggings: [create(:common_tagging)])
      }
      run_all_indexing_jobs
      tags
    end

    it "returns unwrangled tags in use" do
      expect(results).to include(tags[:used])
    end

    it "returns unwrangled canonical tags, even unused" do
      expect(results).to include(tags[:unused_but_canonical])
    end

    it "returns tags that are both used and canonical" do
      expect(results).to include(tags[:used_and_canonical])
    end

    it "does not return tags that are neither canonical nor used" do
      expect(results).not_to include(tags[:unused_and_not_canonical])
    end

    it "does not return unwrangleable tags" do
      expect(results).not_to include(tags[:unwrangleable])
    end

    it "does not return wrangled tags" do
      expect(results).not_to include(tags[:wrangled])
    end

    it "can also list unused tags" do
      results = TagQuery.new(in_use: false).search_results
      expect(results).to include(tags[:unused_and_not_canonical])
      expect(results).not_to include(tags[:used])
      expect(results).not_to include(tags[:unused_but_canonical])
      expect(results).not_to include(tags[:used_and_canonical])
    end

    def results
      TagQuery.new(in_use: true, wrangling_status: "wrangleable", unwrangled: true).search_results
    end
  end

  describe "wrangling_status_filter", tag_search: true do
    let!(:canonical_fandom) { create(:canonical_fandom) }
    let!(:synonymous_fandom) { create(:fandom, merger: canonical_fandom) }
    let!(:unwrangleable) { create(:freeform, unwrangleable: true) }
    let!(:unactioned) { create(:freeform) }

    before do
      run_all_indexing_jobs
    end

    describe "when set to canonical" do
      let(:results) { TagQuery.new(wrangling_status: "canonical").search_results.to_a }

      it "only includes canonical tags" do
        expect(results).to include(canonical_fandom)
        expect(results).not_to include(synonymous_fandom)
        expect(results).not_to include(unwrangleable)
        expect(results).not_to include(unactioned)
      end
    end

    describe "when set to noncanonical" do
      let(:results) { TagQuery.new(wrangling_status: "noncanonical").search_results.to_a }

      it "only includes noncanonical tags" do
        expect(results).not_to include(canonical_fandom)
        expect(results).to include(synonymous_fandom)
        expect(results).to include(unwrangleable)
        expect(results).to include(unactioned)
      end
    end

    describe "when set to synonymous" do
      let(:results) { TagQuery.new(wrangling_status: "synonymous").search_results.to_a }

      it "only includes synonymous tags" do
        expect(results).not_to include(canonical_fandom)
        expect(results).to include(synonymous_fandom)
        expect(results).not_to include(unwrangleable)
        expect(results).not_to include(unactioned)
      end
    end

    describe "when set to canonical_synonymous" do
      let(:results) { TagQuery.new(wrangling_status: "canonical_synonymous").search_results.to_a }

      it "only includes tags that are canonical or synonymous" do
        expect(results).to include(canonical_fandom)
        expect(results).to include(synonymous_fandom)
        expect(results).not_to include(unwrangleable)
        expect(results).not_to include(unactioned)
      end
    end

    describe "when set to noncanonical_nonsynonymous" do
      let(:results) { TagQuery.new(wrangling_status: "noncanonical_nonsynonymous").search_results.to_a }

      it "only includes tags that are non-canonical and non-synonymous" do
        expect(results).not_to include(canonical_fandom)
        expect(results).not_to include(synonymous_fandom)
        expect(results).to include(unwrangleable)
        expect(results).to include(unactioned)
      end
    end

    describe "when set to unwrangleable" do
      let(:results) { TagQuery.new(wrangling_status: "unwrangleable").search_results.to_a }

      it "only includes tags that are unwrangleable" do
        expect(results).not_to include(canonical_fandom)
        expect(results).not_to include(synonymous_fandom)
        expect(results).to include(unwrangleable)
        expect(results).not_to include(unactioned)
      end
    end

    describe "when set to noncanonical_nonsynonymous_not_unwrangleable" do
      let(:results) { TagQuery.new(wrangling_status: "noncanonical_nonsynonymous_not_unwrangleable").search_results.to_a }

      it "only includes tags that are non-canonical, non-synonymous, and not marked unwrangleable" do
        expect(results).not_to include(canonical_fandom)
        expect(results).not_to include(synonymous_fandom)
        expect(results).not_to include(unwrangleable)
        expect(results).to include(unactioned)
      end
    end

    describe "when set to wrangleable" do
      let(:results) { TagQuery.new(wrangling_status: "wrangleable").search_results.to_a }

      it "only includes tags that are unwrangled and not marked unwrangleable" do
        expect(results).to include(canonical_fandom)
        expect(results).to include(synonymous_fandom)
        expect(results).not_to include(unwrangleable)
        expect(results).to include(unactioned)
      end
    end

    describe "when unset" do
      let(:results) { TagQuery.new.search_results.to_a }

      it "includes all tags" do
        expect(results).to include(canonical_fandom)
        expect(results).to include(synonymous_fandom)
        expect(results).to include(unwrangleable)
        expect(results).to include(unactioned)
      end
    end
  end
end
