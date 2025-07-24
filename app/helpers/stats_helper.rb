module StatsHelper
  
  def stat_items
    sql = <<-SQL
          (
      SELECT
        'WORK' AS type,
        works.id,
        works.title,
        tags.name AS fandom,
        works.word_count,
        works.revised_at AS date,
        GROUP_CONCAT(DISTINCT tags.name ORDER BY tags.name SEPARATOR ', ') AS fandom_string,
        sc.hit_count as hits,
        COUNT(DISTINCT b.id) AS bookmarks_count,
        COUNT(DISTINCT s.id) AS subscriptions_count,
        COUNT(DISTINCT k.id) AS kudos_count,
        COUNT(DISTINCT c.id) AS comment_thread_count
      FROM works
      -- Tag joins
      INNER JOIN taggings ON taggings.taggable_id = works.id AND taggings.taggable_type = 'Work'
      INNER JOIN tags ON taggings.tagger_id = tags.id AND tags.type = 'Fandom'
      -- Authorship
      INNER JOIN creatorships ON creatorships.creation_id = works.id AND creatorships.creation_type = 'Work'
      INNER JOIN pseuds ON pseuds.id = creatorships.pseud_id
      INNER JOIN users ON users.id = pseuds.user_id
      -- Counts
      LEFT JOIN bookmarks b ON b.bookmarkable_id = works.id AND b.bookmarkable_type = 'Work'
      LEFT JOIN subscriptions s ON s.subscribable_id = works.id AND s.subscribable_type = 'Work'
      LEFT JOIN kudos k ON k.commentable_id = works.id AND k.commentable_type = 'Work'
      LEFT JOIN stat_counters sc ON sc.work_id = works.id
      -- Total comments on chapters
      LEFT JOIN chapters ON chapters.work_id = works.id
      LEFT JOIN comments c ON c.commentable_id = chapters.id AND c.commentable_type = 'Chapter' AND c.depth = 0
      -- Filters
      WHERE users.id = #{ActiveRecord::Base.connection.quote(@user.id)} AND works.posted = TRUE
      GROUP BY works.id, works.title, works.word_count, works.revised_at
    )
    UNION ALL
    (
      SELECT
        'SERIES' AS type,
        series.id,
        series.title,
        tags.name AS fandom,
        NULL AS word_count,
        NULL AS date,
        GROUP_CONCAT(DISTINCT tags.name ORDER BY tags.name SEPARATOR ', ') AS fandom_string,
        NULL as hits,
        COUNT(DISTINCT b.id) AS bookmarks_count,
        COUNT(DISTINCT s.id) AS subscriptions_count,
        NULL AS kudos_count,
        NULL AS comment_thread_count
      FROM series
      -- Tags
      INNER JOIN serial_works ON serial_works.series_id = series.id
      INNER JOIN works ON works.id = serial_works.work_id
      INNER JOIN taggings ON taggings.taggable_id = works.id AND taggings.taggable_type = 'Work'
      INNER JOIN tags ON taggings.tagger_id = tags.id AND tags.type = 'Fandom'
      -- Authorship
      INNER JOIN creatorships ON creatorships.creation_id = works.id AND creatorships.creation_type = 'Work'
      INNER JOIN pseuds ON pseuds.id = creatorships.pseud_id
      INNER JOIN users ON users.id = pseuds.user_id
      -- Bookmarks/Subsriptions on series itself
      LEFT JOIN bookmarks b ON b.bookmarkable_id = series.id AND b.bookmarkable_type = 'Series'
      LEFT JOIN subscriptions s ON s.subscribable_id = series.id AND s.subscribable_type = 'Series'
      -- Filters
      WHERE users.id = #{ActiveRecord::Base.connection.quote(@user.id)}
      GROUP BY series.id, series.title
    )
    SQL

    results = ActiveRecord::Base.connection.exec_query(sql)
    results.map { |row| StatItem.new(row) }
  end
end
