require "spec_helper"

describe StatsHelper do
  include StatsHelper

  let(:user) { create(:user) }

  def run_query(sort_col = "date", sort_dir = "DESC", year = "All Years")
    stat_items(user, sort_col, sort_dir, year)
  end

  def expect_stat_item(stat_item, expected_attributes)
    expected_attributes.each do |key, value|
      actual = stat_item.public_send(key)
      expect(actual).to eq(value), "Expected #{key} to be #{value.inspect}, got #{actual.inspect}"
    end
  end

  def create_work_set_first_chapter_info(title, chapter_content, year, posted: true)
    work = create(:work, title: title, authors: user.pseuds, posted: posted)
    work.first_chapter.update!(published_at: Date.new(year, 1, 1))
    work.first_chapter.update!(content: chapter_content)
    work
  end

  describe "generating statistics" do
    before do
      User.current_user = user
    end

    it "includes posted works with published chapter inside date range" do
      work = create(:work, authors: user.pseuds)
      create(:chapter, work: work, year: 2010)

      results = run_query("date", "DESC", 2010)
      expect(results.map(&:id)).to include(work.id)
    end

    it "includes posted multi-chapter works with published chapter inside date range" do
      work = create(:work, authors: user.pseuds)
      create(:chapter, work: work, year: 2010)
      create(:chapter, work: work, year: 2011)

      results = run_query("date", "DESC", 2010)
      expect(results.length).to eq(1)
      expect(results.map(&:id)).to include(work.id)
    end

    it "excludes posted works with published chapters outside date range" do
      work = create(:work, authors: user.pseuds)
      create(:chapter, work: work, year: 2010)

      results = run_query("date", "DESC", 2011)
      expect(results.map(&:id)).not_to include(work.id)
    end

    it "excludes series with posted works with published chapters outside date range" do
      work = create(:work, authors: user.pseuds)
      create(:chapter, work: work, year: 2010)

      create(:series, works: [work], authors: user.pseuds)

      results = run_query("date", "DESC", 2011)
      expect(results).to be_empty
    end

    it "includes series with posted works with published chapters inside date range" do
      work = create(:work, authors: user.pseuds)
      create(:chapter, work: work, year: 2010)

      create(:series, works: [work], authors: user.pseuds)

      results = run_query("date", "DESC", 2010)
      expect(results.size).to eq(2)
      expect(results.map(&:type)).to contain_exactly("WORK", "SERIES")
    end

    it "excludes unposted works" do
      draft = create(:work, posted: false, authors: user.pseuds)

      results = run_query("date", "DESC", Time.zone.now.year)
      expect(results.map(&:id)).not_to include(draft.id)

      results = run_query("date", "DESC", "All Years")
      expect(results.map(&:id)).not_to include(draft.id)
    end

    it "excludes unposted works from backdated year" do
      draft = create(:work, posted: false, authors: user.pseuds)
      create_work_set_first_chapter_info("Totally unposted", "one two three four five", 2010)
      
      results = run_query("date", "DESC", 2010)
      expect(results.map(&:id)).not_to include(draft.id)

      results = run_query("date", "DESC", "All Years")
      expect(results.map(&:id)).not_to include(draft.id)
    end

    it "excludes unposted works with multiple draft chapters from different years" do
      draft = create(:work, posted: false, authors: user.pseuds)
      create_work_set_first_chapter_info("Totally unposted", "one two three four five", 2015)

      create(:chapter, work: draft, posted: false, year: 2018)
      
      results = run_query("date", "DESC", 2018)
      expect(results.map(&:id)).not_to include(draft.id)
      
      results = run_query("date", "DESC", 2015)
      expect(results.map(&:id)).not_to include(draft.id)

      results = run_query("date", "DESC", "All Years")
      expect(results.map(&:id)).not_to include(draft.id)
    end

    it "returns work stat items grouped by fandom" do
      fandoms = Set.new(["supernatural", "doctor who", "sherlock"])
      work = create(:work, authors: user.pseuds, fandom_string: fandoms.to_a.join(", "))
      create(:chapter, work: work, year: 2010)
      create(:series, works: [work], authors: user.pseuds)

      results = run_query("date", "DESC", "All Years")
      puts "#{results}"
      
      # each fandom will have 1 work and 1 series entry -> 6
      expect(results.length).to eq(6)

      # verify work and series item appears for all fandoms
      results_by_fandom = results.group_by(&:fandom)
      results_by_fandom.each do |_, stat_items|
        types = stat_items.map(&:type)
        expect(types).to contain_exactly("WORK", "SERIES")
        expect(types.size).to eq(2)
      end
      
      # Check fandom strings are the same
      results.each { |result| expect(result.fandom_string).to eq("doctor who, sherlock, supernatural") }

      stat_fandoms = Set.new(results.map(&:fandom))
      expect(stat_fandoms).to eq(fandoms)
    end

    it "returns series and work stat items grouped by fandom" do
      fandoms = Set.new(["supernatural", "doctor who", "sherlock"])
      work = create(:work, authors: user.pseuds, fandom_string: fandoms.to_a.join(", "))
      create(:chapter, work: work, year: 2010)

      results = run_query("date", "DESC", "All Years")
      
      # grouped by fandom, so there should be 3 results
      expect(results.length).to eq(3)

      # Check fandom strings are the same
      results.each { |result| expect(result.fandom_string).to eq("doctor who, sherlock, supernatural") }

      stat_fandoms = Set.new(results.map(&:fandom))
      expect(stat_fandoms).to eq(fandoms)
    end

    it "excludes unposted chapters posted in same year from word count" do
      # create work with 1 posted chapter, 1 draft chapter
      partially_posted = create_work_set_first_chapter_info("Partially unposted", "one two three four five", 2010)
      create(:chapter, :draft, content: "six seven eight", work: partially_posted, year: 2010)

      result = run_query("date", "DESC", "All Years")
      expect(result.length).to eq(1)
      result = result.first
      # word count should only equal posted first chapter count
      expect(result.word_count).to eq(5)

      result = run_query("date", "DESC", 2010)
      expect(result.length).to eq(1)
      result = result.first
      expect(result.word_count).to eq(5)
    end

    it "displays series and work within series in stat count" do
      create(:series_with_a_work, authors: user.pseuds)
      results = run_query("date", "DESC", "All Years")

      series = results.find { |item| item.type == "SERIES" }
      work = results.find { |item| item.type == "WORK" }
      # 2 stat items - 1 for series, 1 for work (only 1 fandom so 1 for each)
      expect(results.length).to eq(2)
      expect_stat_item(
        series, 
        {
          fandom: "Testing",
          fandom_string: "Testing",
          work_count: 1,
          word_count: 0,
          date: Time.zone.today,
          hits: 0,
          kudos_count: 0
        }
      )

      expect_stat_item(
        work, 
        {
          title: "My title is long enough",
          fandom: "Testing",
          fandom_string: "Testing",
          word_count: 8,
          work_count: 0,
          date: Time.zone.today,
          hits: 0,
          kudos_count: 0
        }
      )
    end

    it "excludes draft works from series work count" do
      unposted = create_work_set_first_chapter_info("Unposted", "one two three four five", 2015, posted: false)
      create(:chapter, :draft, content: "six seven eight", work: unposted, year: 2015)

      series = create(:series, title: "Series with draft work", works: [unposted], authors: user.pseuds)
      
      results = run_query("date", "DESC", "All Years")
      expect(results.length).to eq(0)

      # add posted work to series to verify draft still excluded
      posted = create(:work, authors: user.pseuds)
      series.works << posted
      results = run_query("date", "DESC", "All Years")
      expect(results.length).to eq(2)

      series = results.find { |item| item.type == "SERIES" }
      expect_stat_item(series, { work_count: 1 })
    end

    it "filters posted works with draft chapters from counts" do
      partially_posted = create_work_set_first_chapter_info("Partially unposted", "one two three four five", 2010)
      # draft chapter is in different year
      create(:chapter, :draft, content: "six seven eight", work: partially_posted, year: 2018)

      # filter by draft chapter year
      results = run_query("date", "DESC", 2018)
      expect(results.length).to eq(0)

      # add work to series, still should not return for draft year
      create(:series, title: "Series", works: [partially_posted], authors: user.pseuds)
      results = run_query("date", "DESC", 2018)
      expect(results.length).to eq(0)
    end

    it "sanitizes invalid sort column, sort direction, and year" do
      expect(sanitize_stat_params("invalid", "invalid", "invalid")).to eq(["hits", "DESC", Date.new(1950, 1, 1), Time.zone.today])

      work = create(:work, authors: user.pseuds)
      create(:chapter, work: work)

      results = run_query("invalid", "invalid", "invalid")
      # should return results
      expect(results).not_to be_empty
    end
  end
end
