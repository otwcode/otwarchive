class Creatorship < ActiveRecord::Base
  belongs_to :pseud
  belongs_to :creation, :polymorphic => true  

  # Change authorship of works or series from a particular pseud to the orphan account
  def self.orphan(pseuds, orphans, default=true)
    for pseud in pseuds
      for new_orphan in orphans
        unless pseud.blank? || new_orphan.blank? || !new_orphan.pseuds.include?(pseud)
          orphan_pseud = default ? User.orphan_account.default_pseud : User.orphan_account.pseuds.find_or_create_by_name(pseud.name)
          options = (new_orphan.is_a?(Series)) ? {:skip_series => true} : {}
          pseud.change_ownership(new_orphan, orphan_pseud, options)
        end   
      end
    end    
  end

  # Change authorship of works or series from a particular pseud to the AnonymousCreator account
  def self.anon(pseuds, anons, default=true)
    for pseud in pseuds
      for new_anon in anons
        unless pseud.blank? || new_anon.blank? || !new_anon.pseuds.include?(pseud)
          anon_pseud = default ? User.anonymous_account.default_pseud : User.anonymous_account.pseuds.find_or_create_by_name(pseud.name)
          options = (new_anon.is_a?(Series)) ? {:skip_series => true} : {}
          pseud.change_ownership(new_anon, anon_pseud, options)
        end
      end
    end
  end

end
