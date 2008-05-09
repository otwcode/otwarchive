module ChaptersHelper 
  
  # For use with metadata virtual attribute
  def fields_for_metadata(metadata, &block)
    prefix = metadata.new_record? ? 'new' : 'existing'
    fields_for("chapter[#{prefix}_metadata_attributes]", metadata, &block)
  end
  
end
