class UnsortedTag < Tag

  NAME = "Unsorted Tag"
  index_name Tag.index_name

  # unsorted tags can have their type changed
  # but they need to be reloaded to be seen as an instance of the proper subclass
  def recategorize(new_type)
    self.update_attribute(:type, new_type)
    # return a new instance of the tag, with the correct class
    Tag.find(self.id)
  end

end
