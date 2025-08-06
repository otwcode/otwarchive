module StatsHelper
  VALID_SORT_COLUMNS = %w[hits date kudos_count comment_thread_count bookmarks_count subscriptions_count word_count].freeze
  VALID_SORT_DIRECTIONS = %w[ASC DESC].freeze

  private

  def sanitize_sort_params(column, direction)
    column = "hits" unless VALID_SORT_COLUMNS.include?(column)
    direction = "DESC" unless VALID_SORT_DIRECTIONS.include?(direction)
    [column, direction]
  end

  def sanitize_stat_params(column, direction, year)
    column, direction = sanitize_sort_params(column, direction)
    # Establish date ranges
    if year.to_s.match?(/\A\d{4}\z/)
      parsed_year = year.to_i
      start_date = Date.new(parsed_year, 1, 1)
      end_date = start_date.end_of_year
    else
      # Default: All Years
      start_date = Date.new(1950, 1, 1)
      end_date = Time.zone.today
    end

    [column, direction, start_date, end_date]
  end
  
  def stat_items(user, sort_column, sort_direction, year)
    sort_column, sort_direction, start_date, end_date = sanitize_stat_params(sort_column, sort_direction, year)

    work_stats = Work
      .for_user(user)
      .joins(:chapters)
      .with_fandoms
      .with_stats
      .chapter_published_in_range(start_date, end_date)
      .group("works.id, fandom")
      .select(Arel.sql(<<~SQL.squish))
        "WORK" as type,
        works.id,
        works.title,
        stat_counters.hit_count as hits,
        stat_counters.kudos_count,
        MAX(chapters.published_at) AS date,
        SUM(chapters.word_count) AS word_count,
        COUNT(DISTINCT c.id) AS comment_thread_count,
        COUNT(DISTINCT s.id) AS subscriptions_count,
        COUNT(DISTINCT b.id) AS bookmarks_count,
        tags.name AS fandom
      SQL

    stats = work_stats.all.map { |work_stat| StatItem.new(work_stat) }

    series_stats = Series
      .for_user(user)
      .with_stats
      .merge(Work.with_fandoms)
      .merge(Work.chapter_published_in_range(start_date, end_date))
      .group("series.id, fandom")
      .select(Arel.sql(<<~SQL.squish))
        "SERIES" as type,
        series.id,
        series.title,
        MAX(chapters.published_at) AS date,
        COUNT(DISTINCT works.id) AS work_count,
        COUNT(DISTINCT c.id) AS comment_thread_count,
        COUNT(DISTINCT s.id) AS subscriptions_count,
        COUNT(DISTINCT b.id) AS bookmarks_count,
        tags.name as fandom
      SQL

      # GROUP_CONCAT(DISTINCT tags.name ORDER BY tags.name SEPARATOR ', ') AS fandom_string

    stats.concat(series_stats.all.map { |work_stat| StatItem.new(work_stat) })

    stats.sort_by do |w|
      stat_el = sort_column == "date" ? stat_element(w, sort_column).to_time.to_i : (stat_element(w, sort_column) || 0).to_i
      primary = sort_direction == "ASC" ? stat_el : (0 - stat_el)
      [primary, w.title.downcase]
    end
  end

  def stat_element(work, element)
    case element.downcase
    when "date"
      work.date
    when "hits"
      work.hits
    when "kudos_count"
      work.kudos_count
    when "comment_thread_count"
      work.comment_thread_count
    when "bookmarks_count"
      work.bookmarks_count
    when "subscriptions_count"
      work.subscriptions_count
    when "word_count"
      work.word_count
    end
  end
end
