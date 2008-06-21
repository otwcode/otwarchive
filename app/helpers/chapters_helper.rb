module ChaptersHelper 
  
  # For use with metadata virtual attribute
  def fields_for_metadata(metadata, &block)
    prefix = metadata.new_record? ? 'new' : 'existing'
    fields_for("chapter[metadata_attributes]", metadata, &block)
  end
  
  # Creates a link with the appropriate chapter number
  def chapter_link(chapter)
    chapter_header = "Chapter " + (chapter.position_placeholder || chapter.current_position).to_s
    link_to chapter_header, [chapter.work, chapter]
  end
  
end
