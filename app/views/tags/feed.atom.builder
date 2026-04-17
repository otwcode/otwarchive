atom_feed do |feed|
  feed.title "AO3 works tagged '#{@tag.name}'"

  @works.each_with_index do |work, index|
    next if work.unrevealed?

    feed.updated work.created_at if index == 0

    feed.entry work do |entry|
      entry.title work.title
      entry.summary feed_summary(work), type: "html"

      creators_for_feed(work) do |name, uri|
        entry.author do |author|
          author.name name
          author.uri uri if uri
        end
      end
    end
  end
end
