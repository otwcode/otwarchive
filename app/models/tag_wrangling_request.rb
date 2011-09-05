class TagWranglingRequest < ActiveRecord::Base
  belongs_to :tag
  belongs_to :owned_tag_set
  
  attr_writer :do_request
  def do_request; false; end
  
  validates_uniqueness_of :tag_id, :scope => [:owned_tag_set_id], :message => ts("^You have already submitted a request to have that tag wrangled.")
  
  serialize :parent_tagname_list
  
  def parent_tagnames
    parent_tagname_list ? parent_tagname_list.join(",") : ""
  end
  def parent_tagnames=(parent_tagnames)
    parent_tagname_list = parent_tagnames.split(ArchiveConfig.DELIMITER_FOR_INPUT)
  end
  
  def self.for_tag_set(tagset)
    where(:owned_tag_set_id => tagset.id)
  end
  
end
