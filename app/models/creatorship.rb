class Creatorship < ActiveRecord::Base
  belongs_to :pseud
  belongs_to :creation, :polymorphic => true
  
  # Add multiple pseuds as authors to a creation
  def self.add_authors(creation, pseuds)
    pseuds.each { |p| p.add_creations([creation]) } if pseuds
  end 
  
  def self.remove_authors(creation, pseuds)
    return false if (creation.pseuds - pseuds).empty?  # can't remove all authors
    pseuds.each {|p| p.remove_creation([creation])} if pseuds
  end
  
  # Change authorship of work(s) from a particular pseud to the orphan account
  def self.orphan(pseuds, works, default=true)
    for pseud in pseuds
      for work in works
        unless pseud.blank? || work.blank? || !work.pseuds.include?(pseud)
          orphan_pseud = default ? User.orphan_account.default_pseud : User.orphan_account.pseuds.find_or_create_by_name(pseud.name)
          pseud.change_ownership(work, orphan_pseud)
        end   
      end
    end    
  end  
end
