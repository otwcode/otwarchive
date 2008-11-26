class Creatorship < ActiveRecord::Base
  belongs_to :pseud
  belongs_to :creation, :polymorphic => true  

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
