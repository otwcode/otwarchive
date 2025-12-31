atom_feed do |feed|
  feed.title "AO3 works tagged '#{@tag.name}'"
  feed.updated @works.first.created_at if @works.respond_to?(:first) && @works.first.present?

  @works.each do |work|
    next if work.unrevealed?

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
