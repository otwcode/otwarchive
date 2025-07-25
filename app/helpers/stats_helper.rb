module StatsHelper
  
  def stat_items(user, sort_column, sort_direction, year)
    # Establish date ranges
    if year == "All Years"
      start_date = Date.new(1950, 1, 1)
      end_date = Time.zone.today
    else
      start_date = Date.new(year.to_i, 1, 1)
      end_date = start_date.end_of_year
    end

    sql = <<-SQL
      -- prefilter works by specified user
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
      work_stats AS (
        SELECT
          c.work_id,
          MAX(c.published_at) AS last_published_chapter_date,
          COUNT(DISTINCT com.id) as comment_thread_count,
          -- Recomputing the whole Work count when All Years is selected, unfortunately
          SUM(c.word_count) as word_count,
        CASE 
          -- Evaluate whether Work contains a chapter that was published in date range
          WHEN MAX(c.published_at) IS NOT NULL THEN TRUE 
          ELSE FALSE 
        END AS published_in_range
        FROM chapters c
        LEFT JOIN comments com
          ON com.commentable_id = c.id AND com.commentable_type = 'Chapter' AND com.depth = 0
        WHERE c.published_at BETWEEN '#{start_date}' AND '#{end_date}'
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
          -- Might want to move user_id into select? Maybe doesn't matter
	        AND uw.user_id = #{ActiveRecord::Base.connection.quote(user.id)}
          AND uw.work_posted = TRUE
	      GROUP BY series.id
      ),
      -- Get the concatenated fandom string
      fandom_info AS (
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
        tags.name AS fandom,
        work_stats.word_count AS word_count,
        -- This doesn't retain the prior way of sorting via last revised at for All Years
        work_stats.last_published_chapter_date AS date,
        -- Should probably separate this out into different query?
        fandom_info.fandom_string AS fandom_string,
        sc.hit_count as hits,
        -- Use stats_counter for bookmarks and kudos as well?
        sc.kudos_count AS kudos_count,
        sc.bookmarks_count AS bookmarks_count,
        COUNT(DISTINCT s.id) AS subscriptions_count,
        work_stats.comment_thread_count AS comment_thread_count,
        NULL as work_count
      FROM user_works uw
      -- Tags
      INNER JOIN taggings ON taggings.taggable_id = uw.work_id AND taggings.taggable_type = 'Work'
      INNER JOIN tags ON taggings.tagger_id = tags.id AND tags.type = 'Fandom'
      -- Counts
      LEFT JOIN subscriptions s ON s.subscribable_id = uw.work_id AND s.subscribable_type = 'Work'
      LEFT JOIN stat_counters sc ON sc.work_id = uw.work_id
      -- Fandom string
      LEFT JOIN fandom_info ON fandom_info.work_id = uw.work_id
      -- Work stats
      LEFT JOIN work_stats ON work_stats.work_id = uw.work_id
      -- Filters
      WHERE uw.user_id = #{ActiveRecord::Base.connection.quote(user.id)} 
      -- Only posted works
      AND uw.work_posted = TRUE
      -- Only works within range
      AND work_stats.published_in_range = TRUE
      GROUP BY id, title, tags.name
    )
    UNION ALL
    (
      SELECT
        'SERIES' AS type,
        series.id,
        series.title,
        tags.name AS fandom,
        NULL AS word_count,
        -- Most recent chapter update date for all works in series
        MAX(work_stats.last_published_chapter_date) AS date,
        -- Should probably separate this out into different query?
        GROUP_CONCAT(DISTINCT tags.name ORDER BY tags.name SEPARATOR ', ') AS fandom_string,
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
      -- Tags
      INNER JOIN taggings ON taggings.taggable_id = uw.work_id AND taggings.taggable_type = 'Work'
      INNER JOIN tags ON taggings.tagger_id = tags.id AND tags.type = 'Fandom'
      -- Bookmarks/Subsriptions on series itself
      LEFT JOIN bookmarks b ON b.bookmarkable_id = series.id AND b.bookmarkable_type = 'Series'
      LEFT JOIN subscriptions s ON s.subscribable_id = series.id AND s.subscribable_type = 'Series'
      -- Used for published in range check
      LEFT JOIN work_stats ON work_stats.work_id = uw.work_id 
      -- Filters
      WHERE uw.user_id = #{ActiveRecord::Base.connection.quote(user.id)}
      -- Only retrieve series info if work in series had a chapter published in range
      AND work_stats.published_in_range = TRUE
      GROUP BY series.id, series.title, tags.name
    )
    ORDER BY #{sort_column} #{sort_direction}, title
    SQL

    results = ActiveRecord::Base.connection.exec_query(sql)
    results.map { |row| StatItem.new(row) }
  end
end
