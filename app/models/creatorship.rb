class Creatorship < ActiveRecord::Base
  belongs_to :pseud
  belongs_to :creation, :polymorphic => true
  
  after_create :expire_caches
  before_destroy :expire_caches

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
  
  def expire_caches
    if creation_type == 'Work' && self.pseud.present?
      self.pseud.update_works_index_timestamp!
      self.pseud.user.update_works_index_timestamp!
    end
  end

end
