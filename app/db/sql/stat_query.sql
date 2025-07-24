(
  SELECT
    'WORK' AS type,
    works.id,
    works.title,
    tags.name AS fandom,
    works.word_count,
    works.revised_at AS date,
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
  -- Left joins for counts
  LEFT JOIN bookmarks b ON b.bookmarkable_id = works.id AND b.bookmarkable_type = 'Work'
  LEFT JOIN subscriptions s ON s.subscribable_id = works.id AND s.subscribable_type = 'Work'
  LEFT JOIN kudos k ON k.commentable_id = works.id AND k.commentable_type = 'Work'
  -- Total comments on chapters
  LEFT JOIN chapters ON chapters.work_id = works.id
  LEFT JOIN comments c ON c.commentable_id = chapters.id AND c.commentable_type = 'Chapter' AND c.depth = 0
  -- Filters
  WHERE users.id = ? AND works.posted = TRUE
  GROUP BY works.id, tags.name, works.title, works.word_count, works.revised_at
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
    COUNT(DISTINCT b.id) AS bookmarks_count,
    COUNT(DISTINCT s.id) AS subscriptions_count,
    NULL AS kudos_count,
    NULL AS comment_thread_count
  FROM series
  -- Join to get fandom tags from works in the series
  INNER JOIN serial_works ON serial_works.series_id = series.id
  INNER JOIN works ON works.id = serial_works.work_id
  INNER JOIN taggings ON taggings.taggable_id = works.id AND taggings.taggable_type = 'Work'
  INNER JOIN tags ON taggings.tagger_id = tags.id AND tags.type = 'Fandom'
  -- Authorship (via works)
  INNER JOIN creatorships ON creatorships.creation_id = works.id AND creatorships.creation_type = 'Work'
  INNER JOIN pseuds ON pseuds.id = creatorships.pseud_id
  INNER JOIN users ON users.id = pseuds.user_id
  -- Series-specific counts
  LEFT JOIN bookmarks b ON b.bookmarkable_id = series.id AND b.bookmarkable_type = 'Series'
  LEFT JOIN subscriptions s ON s.subscribable_id = series.id AND s.subscribable_type = 'Series'
  -- Filters
  WHERE users.id = ?
  GROUP BY series.id, tags.name, series.title
)
