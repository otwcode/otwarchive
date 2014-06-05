Before do
  Work.tire.index.delete
  Work.create_elasticsearch_index
  Work.tire.index.refresh

  Bookmark.tire.index.delete
  Bookmark.create_elasticsearch_index
  Bookmark.import

  Tag.tire.index.delete
  Tag.create_elasticsearch_index

  Pseud.tire.index.delete
  Pseud.create_elasticsearch_index
end
