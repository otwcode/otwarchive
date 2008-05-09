module WorksHelper 
  
  # For use with metadata and chapter virtual attributes
  def fields_for_associated(associated, &block)
    prefix = associated.new_record? ? 'new' : 'existing'
    fields_for("work[#{prefix}_#{associated.class.to_s.downcase}_attributes]", associated, &block)
  end
  
end
