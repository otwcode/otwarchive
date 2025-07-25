module StatsHelper
  
  def stat_items(user, sort_column, sort_direction, year)
    if year != "All Years"
      start_date = Date.new(year.to_i, 1, 1)
      end_date = start_date.end_of_year
    end

    # Get works or series where a chapter was published in that year
    year_clause = if year == "All Years"
                    "TRUE"
                  else
                    "chapters.published_at BETWEEN '#{start_date}' AND '#{end_date}'"
                  end
    
    # Use max published chapter for series
    date_series = if year == "All Years"
                    "MAX(chapters.published_at)"
                  else
                    "MAX(CASE WHEN chapters.published_at BETWEEN '#{start_date}' AND '#{end_date}' THEN chapters.published_at END)"
                  end
    
    # Sort works by revised date for all years or last published chapter for specific year
    date_works =  if year == "All Years"
                    "MAX(works.revised_at)"
                  else
                    "MAX(chapters.published_at)"
                  end

    # Grab work word count for all years or sum all chapters published in that year
    word_count = if year == "All Years"
                    "works.word_count"
                 else
                    "SUM(CASE WHEN chapters.published_at BETWEEN '#{start_date}' AND '#{end_date}' THEN chapters.word_count ELSE 0 END)"
                 end

    sql = <<-SQL
          (
      SELECT
        'WORK' AS type,
        works.id,
        works.title as title,
        tags.name AS fandom,
        #{word_count} AS word_count,
        -- Sort by last revised work date if All Years, otherwise pull last published chapter
        #{date_works} AS date,
        -- Should probably separate this out into different query
        GROUP_CONCAT(DISTINCT tags.name ORDER BY tags.name SEPARATOR ', ') AS fandom_string,
        sc.hit_count as hits,
        -- Use stats_counter for bookmarks and kudos as well?
        sc.kudos_count AS kudos_count,
        sc.bookmarks_count AS bookmarks_count,
        COUNT(DISTINCT s.id) AS subscriptions_count,
        COUNT(DISTINCT c.id) AS comment_thread_count,
        NULL as work_count
      FROM works
      -- Tags
      INNER JOIN taggings ON taggings.taggable_id = works.id AND taggings.taggable_type = 'Work'
      INNER JOIN tags ON taggings.tagger_id = tags.id AND tags.type = 'Fandom'
      -- Authorship
      INNER JOIN creatorships ON creatorships.creation_id = works.id AND creatorships.creation_type = 'Work'
      INNER JOIN pseuds ON pseuds.id = creatorships.pseud_id
      INNER JOIN users ON users.id = pseuds.user_id
      -- Counts
      LEFT JOIN subscriptions s ON s.subscribable_id = works.id AND s.subscribable_type = 'Work'
      LEFT JOIN stat_counters sc ON sc.work_id = works.id
      -- Total comments on chapters
      LEFT JOIN chapters ON chapters.work_id = works.id
      LEFT JOIN comments c ON c.commentable_id = chapters.id AND c.commentable_type = 'Chapter' AND c.depth = 0
      -- Filters
      WHERE users.id = #{ActiveRecord::Base.connection.quote(user.id)} 
      AND works.posted = TRUE
      AND #{year_clause}
      GROUP BY works.id, title, tags.name
    )
    UNION ALL
    (
      SELECT
        'SERIES' AS type,
        series.id,
        series.title,
        tags.name AS fandom,
        NULL AS word_count,
        #{date_series} AS date,
        -- Should probably separate this out into different query
        GROUP_CONCAT(DISTINCT tags.name ORDER BY tags.name SEPARATOR ', ') AS fandom_string,
        NULL as hits,
        NULL AS kudos_count,
        COUNT(DISTINCT b.id) AS bookmarks_count,
        COUNT(DISTINCT s.id) AS subscriptions_count,
        NULL AS comment_thread_count,
        COUNT(DISTINCT sw.id) as work_count
      FROM series
      -- Tags
      INNER JOIN serial_works sw ON sw.series_id = series.id
      INNER JOIN works ON works.id = sw.work_id
      INNER JOIN taggings ON taggings.taggable_id = works.id AND taggings.taggable_type = 'Work'
      INNER JOIN tags ON taggings.tagger_id = tags.id AND tags.type = 'Fandom'
      -- Authorship
      INNER JOIN creatorships ON creatorships.creation_id = works.id AND creatorships.creation_type = 'Work'
      INNER JOIN pseuds ON pseuds.id = creatorships.pseud_id
      INNER JOIN users ON users.id = pseuds.user_id
      -- Bookmarks/Subsriptions on series itself
      LEFT JOIN bookmarks b ON b.bookmarkable_id = series.id AND b.bookmarkable_type = 'Series'
      LEFT JOIN subscriptions s ON s.subscribable_id = series.id AND s.subscribable_type = 'Series'
      -- Get chapters for dating
      LEFT JOIN chapters on chapters.work_id = works.id
      -- Filters
      WHERE users.id = #{ActiveRecord::Base.connection.quote(user.id)}
      AND #{year_clause}
      GROUP BY series.id, series.title, tags.name
    )
    ORDER BY #{sort_column} #{sort_direction}, title
    SQL

    results = ActiveRecord::Base.connection.exec_query(sql)
    results.map { |row| StatItem.new(row) }
  end
end
