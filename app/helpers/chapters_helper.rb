module ChaptersHelper
  # Provide a short summary of a chapter for a feed
  def atom_text(chapter)
    if chapter.summary.nil? || chapter.summary.empty?
      chapter.content.truncate(200)
    else
      chapter.summary
    end
  end
end
