atom_feed do |feed|
  feed.title "AO3 works tagged '#{@tag.name}'"
  feed.updated @works.first.created_at

  @works.each do |work|
    unless work.unrevealed?
      feed.entry work do |entry|
        entry.title work.title
        entry.summary work.summary + "<p>Words: #{work.word_count}, 
  Chapters: #{work.chapter_total_display}, 
  Language: #{work.language ? work.language.name : "English"}, 
  Series: #{series_list_for_feeds(work)}</p>
  <p>Tags: #{work.tags.map{|t| link_to_tag_works(t)}.join(', ')}
  </p>", :type => 'html'

        entry.author do |author|
          author.name byline(work, :visibility => 'public'), :type => 'html'
        end
      end
    end
  end
end
