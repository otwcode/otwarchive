# For models which have pseuds (authors)
module Pseudable

  def pseuds_to_add=(pseud_names)
    names = pseud_names.split(',').
                        reject { |name| name.blank? }.
                        map { |name| name.strip }
    names.each do |name|
      possible_pseuds = Pseud.parse_byline(name)
      if possible_pseuds.size > 1
        possible_pseuds = Pseud.parse_byline(name, assume_matching_login: true)
      end
      pseud = possible_pseuds.first
      if pseud.nil?
        errors.add(:base, 
                   ts("We couldn't find the pseud {{name}}.", name: name))
      elsif pseud.user.banned?
        errors.add(:base, 
                   ts("{{name}} has been banned and cannot be listed as a co-creator",
                      name: name)
                   )
      else
        add_pseud(pseud)
      end
    end
  end
  
  def add_pseud(p)
    if p && !self.pseuds.include?(p)
      self.pseuds << p
    end
  end
  
  def pseuds_to_remove=(pseud_ids)
    pseud_ids.reject {|id| id.blank?}.map {|id| id.strip}.each do |id|
      p = Pseud.find(id)
      remove_pseud(p)
    end
  end
  
  def remove_pseud(p, remove_all=false)
    if p && self.pseuds.include?(p)
      # don't remove all authors
      if remove_all || (self.pseuds - [p]).size > 0
        self.pseuds -= [p]
      end
    end
  end
  
  def pseuds_to_add; nil; end
  def pseuds_to_remove; nil; end
  
  
end
  
