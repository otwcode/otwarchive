class UnsortedTag < Tag
  include ActiveModel::ForbiddenAttributesProtection

  NAME = "Unsorted Tag"
  index_name Tag.index_name

end
