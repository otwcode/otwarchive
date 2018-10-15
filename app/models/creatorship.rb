class Creatorship < ApplicationRecord
  belongs_to :pseud
  belongs_to :creation, polymorphic: true, touch: true

  before_destroy :expire_caches
  after_create :update_pseud_index
  after_destroy :update_pseud_index

  validate :unique_index

  def unique_index
    duplicate_creatorships = Creatorship.where(
      'creation_id = ? AND creation_type = ? AND pseud_id = ? AND id != ?',
      creation_id, creation_type, pseud_id, id
    )

    if duplicate_creatorships.any?
      errors.add(:base, 'Cannot be a duplicate entry')
    end
  end

  # Change authorship of works or series from a particular pseud to the orphan account
  def self.orphan(pseuds, orphans, default=true)
    for pseud in pseuds
      for new_orphan in orphans
        unless pseud.blank? || new_orphan.blank? || !new_orphan.pseuds.include?(pseud)
          orphan_pseud = default ? User.orphan_account.default_pseud : User.orphan_account.pseuds.find_or_create_by(name: pseud.name)
          options = (new_orphan.is_a?(Series)) ? {skip_series: true} : {}
          pseud.change_ownership(new_orphan, orphan_pseud, options)
        end
      end
    end
  end

  def expire_caches
    if creation_type == 'Work' && self.pseud.present?
      CacheMaster.record(creation_id, 'pseud', self.pseud_id)
      CacheMaster.record(creation_id, 'user', self.pseud.user_id)
    end
  end

  def update_pseud_index
    return unless creation_type == 'Work'
    return unless creation.respond_to?(:reindex_changed_pseud)
    creation.reindex_changed_pseud(pseud_id)
  end
end
