atom_feed do |feed|
  feed.title "AO3 works tagged '#{@tag.name}'"
  feed.updated @works.first.created_at if @works.respond_to?(:first) && @works.first.present?

  @works.each do |work|
    unless work.unrevealed?
      feed.entry work do |entry|
        entry.title work.title 
        entry.summary(Rails.cache.fetch(Work.rss_work_summary_key(work.id)) do feed_summary(work) end, type: 'html')

        entry.author do |author|
          author.name Rails.cache.fetch(Work.rss_work_byline_key(work.id)) do text_byline(work, :visibility => 'public') end
        end
      end
    end
  end
end
