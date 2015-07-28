atom_feed do |feed|
  feed.title "'#{@work.title}'"
  feed.updated @work.revised_at

  unless @work.unrevealed?
    @work.posted_chapters.last(10).each do |chapter|
      feed.entry chapter do |entry|
        entry.title chapter.chapter_title
        entry.summary atom_text(chapter), :type => 'html'

        entry.author do |author|
          author.name text_byline(chapter, :visibility => 'public')
        end
      end
    end
  end
end
