module StatsHelper
  VALID_SORT_COLUMNS = %w[hits date kudos_count comment_thread_count bookmarks_count subscriptions_count word_count].freeze
  VALID_SORT_DIRECTIONS = %w[ASC DESC].freeze

  private

  def sanitize_sort_params(column, direction)
    column = "hits" unless VALID_SORT_COLUMNS.include?(column)
    direction = "DESC" unless VALID_SORT_DIRECTIONS.include?(direction)
    [column, direction]
  end
  
  def stat_items(user, sort_column, sort_direction, year)
    # Since we cannot bind sort column/direction, validate input
    sort_column, sort_direction = sanitize_sort_params(sort_column, sort_direction)
    # Establish date ranges
    if year == "All Years"
      start_date = Date.new(1950, 1, 1)
      end_date = Time.zone.today
    else
      start_date = Date.new(year.to_i, 1, 1)
      end_date = start_date.end_of_year
    end

    sql_array = [<<-SQL, { user_id: user.id }] # rubocop:disable Rails/SquishedSQLHeredocs
      -- Prefilter works by user
      WITH user_works AS (
        SELECT 
          users.id as user_id,
          works.id as work_id,
          works.posted as work_posted,
          works.title as work_title
        FROM works
        INNER JOIN creatorships ON creatorships.creation_id = works.id AND creatorships.creation_type = 'Work'
	      INNER JOIN pseuds ON pseuds.id = creatorships.pseud_id
	      INNER JOIN users ON users.id = pseuds.user_id
      ), 
      -- Get fandom tags tied to works
      fandom_tags AS (
        SELECT 
          uw.user_id,
          uw.work_id,
          tags.name AS fandom
        FROM user_works uw
        INNER JOIN taggings ON taggings.taggable_id = uw.work_id AND taggings.taggable_type = 'Work'
        INNER JOIN tags ON taggings.tagger_id = tags.id AND tags.type = 'Fandom'
      ),
      -- Gets whole work stats
      work_stats AS (
        SELECT
          c.work_id,
          MAX(c.published_at) AS last_published_chapter_date,
          COUNT(DISTINCT com.id) as comment_thread_count,
          -- Recomputing the whole Work count when All Years is selected, unfortunately
          SUM(c.word_count) as word_count,
        CASE 
          -- Evaluate whether Work contains a chapter published in range
          WHEN MAX(c.published_at) IS NOT NULL THEN TRUE 
          ELSE FALSE 
        END AS published_in_range
        FROM chapters c
        LEFT JOIN comments com
          ON com.commentable_id = c.id AND com.commentable_type = 'Chapter' AND com.depth = 0
        WHERE c.published_at BETWEEN '#{start_date}' AND '#{end_date}'
        -- Only account for posted chapters
        AND c.posted = TRUE
        GROUP BY c.work_id
      ),
      -- Gets the total posted works for a series in specified range
      series_counts AS (
        SELECT 
          series.id as series_id,
          COUNT(DISTINCT sw.id) as work_count
        FROM series
        INNER JOIN serial_works sw ON sw.series_id = series.id
        INNER JOIN user_works uw ON uw.work_id = sw.work_id
        -- Join work stats to determine whether series contains a work with a chapter published in range
        INNER JOIN work_stats ON work_stats.work_id = uw.work_id
        WHERE work_stats.published_in_range = TRUE
	        AND uw.user_id = :user_id
          -- Only account for posted works
          AND uw.work_posted = TRUE
	      GROUP BY series.id
      ),
      -- Get the concatenated fandom string
      fandom_string AS (
        SELECT taggings.taggable_id AS work_id,
        GROUP_CONCAT(DISTINCT tags.name ORDER BY tags.name SEPARATOR ', ') AS fandom_string
        FROM taggings
        INNER JOIN tags ON taggings.tagger_id = tags.id
        WHERE taggings.taggable_type = 'Work' AND tags.type = 'Fandom'
        GROUP BY taggings.taggable_id
      )
      (
      SELECT
        'WORK' AS type,
        uw.work_id as id,
        uw.work_title as title,
        ft.fandom AS fandom,
        work_stats.word_count AS word_count,
        -- This doesn't retain the prior way of sorting via last revised at for All Years
        work_stats.last_published_chapter_date AS date,
        fs.fandom_string AS fandom_string,
        sc.hit_count as hits,
        -- Calculate kudos/bookmarks manually, or use stat_counters?
        sc.kudos_count AS kudos_count,
        sc.bookmarks_count AS bookmarks_count,
        COUNT(DISTINCT s.id) AS subscriptions_count,
        work_stats.comment_thread_count AS comment_thread_count,
        NULL as work_count
      FROM user_works uw
      -- Fandom tags
      INNER JOIN fandom_tags ft ON ft.work_id = uw.work_id AND ft.user_id = uw.user_id
      -- Counts
      LEFT JOIN subscriptions s ON s.subscribable_id = uw.work_id AND s.subscribable_type = 'Work'
      LEFT JOIN stat_counters sc ON sc.work_id = uw.work_id
      -- Fandom string
      LEFT JOIN fandom_string fs ON fs.work_id = uw.work_id
      -- Work stats
      LEFT JOIN work_stats ON work_stats.work_id = uw.work_id
      -- Find for current user
      WHERE uw.user_id = :user_id 
      -- Only posted works
      AND uw.work_posted = TRUE
      -- Only works with a chapter published within range
      AND work_stats.published_in_range = TRUE
      GROUP BY id, title, fandom
    )
    UNION ALL
    (
      SELECT
        'SERIES' AS type,
        series.id,
        series.title,
        ft.fandom AS fandom,
        NULL AS word_count,
        -- Most recent chapter update date for all works in series
        MAX(work_stats.last_published_chapter_date) AS date,
        fs.fandom_string AS fandom_string,
        NULL as hits,
        NULL AS kudos_count,
        COUNT(DISTINCT b.id) AS bookmarks_count,
        COUNT(DISTINCT s.id) AS subscriptions_count,
        NULL AS comment_thread_count,
        series_counts.work_count AS work_count
      FROM series
      -- Series counts and info
      INNER JOIN series_counts ON series_counts.series_id = series.id
      INNER JOIN serial_works sw ON sw.series_id = series.id
      INNER JOIN user_works uw ON uw.work_id = sw.work_id
      -- Fandom tags
      INNER JOIN fandom_tags ft ON ft.work_id = uw.work_id AND ft.user_id = uw.user_id
      -- Bookmarks/Subsriptions on series itself
      LEFT JOIN bookmarks b ON b.bookmarkable_id = series.id AND b.bookmarkable_type = 'Series'
      LEFT JOIN subscriptions s ON s.subscribable_id = series.id AND s.subscribable_type = 'Series'
      -- Fandom string
      LEFT JOIN fandom_string fs ON fs.work_id = uw.work_id
      -- Used for published-in-range check
      LEFT JOIN work_stats ON work_stats.work_id = uw.work_id 
      -- Find for current user
      WHERE uw.user_id = :user_id
      -- Only retrieve series info if work in series had a chapter published in range
      AND work_stats.published_in_range = TRUE
      GROUP BY series.id, series.title, fandom
    )
    ORDER BY #{sort_column} #{sort_direction}, title
    SQL

    sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array, sql_array)
    results = ActiveRecord::Base.connection.exec_query(sanitized_sql)
    results.map { |row| StatItem.new(row) }
  end
end
