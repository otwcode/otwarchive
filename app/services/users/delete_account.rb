# frozen_string_literal: true

class Users::DeleteAccount
  attr_reader :preferences

  class DeleteFailed < StandardError; end

  def self.call(user_id, preferences: {})
    self.new(User.find(user_id), preferences: preferences).call
  end

  def initialize(user, preferences: {})
    @user = user
    @preferences = preferences
  end

  def call
    User.transaction do
      coauthored_works = @user.coauthored_works
      clean_up_coauthored_works(coauthored_works) if coauthored_works.present?

      works = @user.sole_authored_works
      collections = @user.sole_owned_collections
      clean_up_sole_works_and_collections(works, collections) if works.present? || collections.present?

      raise DeleteFailed, "Works failed to delete" if @user.works.exists?(posted: true)

      finish_cleanup
    end
  end

  # Either changes the ownership of co-authored works to the orphan account
  # or removes the user, depending on their preferences
  def clean_up_coauthored_works(works)
    case preferences[:coauthor]
    when "keep_pseud", "orphan_pseud"
      pseuds = @user.pseuds
      use_default = preferences[:use_default] || preferences[:coauthor] == "orphan_pseud"
      Creatorship.orphan(pseuds, works, use_default)
    when "remove"
      works.each do |w|
        w.remove_author(@user)
      end
    else
      raise DeleteFailed, "Unknown preference '#{preferences[:coauthor]}'"
    end
  end

  # Either orphans works or deletes them, depending on the user's preferences
  def clean_up_sole_works_and_collections(works, collections)
    case preferences[:sole_author]
    when "keep_pseud", "orphan_pseud"
      pseuds = @user.pseuds
      use_default = preferences[:use_default] || preferences[:sole_author] == "orphan_pseud"
      Creatorship.orphan(pseuds, works, use_default) if works.present?
      Collection.orphan(pseuds, collections, default: use_default) if collections.present?
    when "delete"
      works.each(&:destroy!)
      collections.each(&:destroy!)
    else
      raise DeleteFailed, "Unknown preference '#{preferences[:sole_author]}'"
    end
  end

  def finish_cleanup
    @user.wipeout_unposted_works
    @user.destroy_empty_series
    remove_stray_chapters
    @user.destroy!
  end

  # Clean up any chapters left dangling without works
  def remove_stray_chapters
    pseud_ids = @user.pseuds.pluck(:id)
    chapters = Chapter.joins(:creatorships)
      .where(work_id: nil, creatorships: { pseud_id: pseud_ids }).distinct

    chapters.each do |chapter|
      if chapter.creatorships.where.not(pseud_id: pseud_ids).exists?
        chapter.creatorships.where(pseud_id: pseud_ids).delete_all
      else
        chapter.creatorships.each(&:delete)
        chapter.delete
      end
    end
  end
end
