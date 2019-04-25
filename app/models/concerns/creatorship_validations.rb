# frozen_string_literal: true

module CreatorshipValidations
  extend ActiveSupport::Concern

  included do
    has_many :creatorships,
      autosave: true,
      as: :creation,
      inverse_of: :creation

    has_many :approved_creatorships,
      -> { where(approved: true) },
      class_name: "Creatorship",
      as: :creation,
      inverse_of: :creation

    has_many :pseuds,
      through: :approved_creatorships,
      before_add: :disallow_pseud_changes,
      before_remove: :disallow_pseud_changes

    has_many :users,
      -> { distinct },
      through: :pseuds

    validate :check_no_creators
    after_save :update_current_user_pseuds
    after_destroy :destroy_creatorships
  end

  def disallow_pseud_changes(*)
    return if User.current_user.nil?
    raise "Cannot add or remove pseuds through the pseuds association!"
  end

  def check_no_creators
    return if @current_user_pseuds.present? || pseuds_after_saving.any?

    errors.add(:base, ts("%{type} must have at least one creator.",
                         type: model_name.human))
  end

  attr_reader :current_user_pseuds

  def update_current_user_pseuds
    return unless @current_user_pseuds
    set_current_user_pseuds(@current_user_pseuds)
    @current_user_pseuds = nil
  end

  def set_current_user_pseuds(new_pseuds)
    return unless User.current_user.is_a?(User)
    user_id = User.current_user.id

    children = if is_a?(Work)
                 chapters.to_a
               elsif is_a?(Series)
                 works.to_a
               else
                 []
               end

    transaction do
      children.each do |child|
        next unless child.users.include?(User.current_user)
        child.set_current_user_pseuds(new_pseuds)
      end

      # Create before destroying, so that we don't run into issues with
      # deleting the very last creator.
      new_pseuds.each do |pseud|
        creatorships.approve_or_create_by(pseud: pseud)
      end

      creatorships.each do |creatorship|
        creatorship.destroy unless (new_pseuds.include?(creatorship.pseud) ||
                                    creatorship.pseud&.user_id != user_id)
      end
    end
  end

  def destroy_creatorships
    creatorships.destroy_all
  end

  def creatorships_after_saving
    creatorships.select(&:valid?).reject(&:marked_for_destruction?)
  end

  def pseuds_after_saving
    pseuds = creatorships_after_saving.select(&:approved).map(&:pseud)

    if @current_user_pseuds
      pseuds = (pseuds - User.current_user.pseuds) + @current_user_pseuds
    end

    pseuds
  end

  def author_attributes=(attributes)
    self.new_bylines = attributes[:byline] if attributes[:byline].present?
    self.new_co_creator_ids = attributes[:coauthors] if attributes[:coauthors].present?
    self.current_user_pseud_ids = attributes[:ids] if attributes[:ids].present?
  end

  def new_bylines=(bylines)
    bylines.split(",").reject(&:blank?).map(&:strip).each do |byline|
      self.creatorships.build(byline: byline)
    end
  end

  def new_co_creator_ids=(ids)
    new_pseuds = Pseud.where(id: ids).to_a

    creatorships.each do |creatorship|
      if new_pseuds.include?(creatorship.pseud)
        new_pseuds.delete(creatorship.pseud)
      end
    end

    new_pseuds.each do |pseud|
      self.creatorships.build(pseud: pseud)
    end
  end

  def current_user_pseud_ids=(ids)
    return unless User.current_user.is_a?(User)

    pseuds = Pseud.where(id: ids).to_a

    if pseuds.empty?
      errors.add(:base, ts("You haven't selected any pseuds for this %{type}.",
                           type: model_name.human.downcase))
    elsif pseuds.any? { |p| p.user_id != User.current_user.id }
      errors.add(:base, ts("You don't have permission to use that pseud."))
    else
      @current_user_pseuds = pseuds
    end
  end

  def user_has_creator_invite?(user)
    return false unless user.is_a?(User)
    creatorships.invited.for_user(user).exists?
  end
end
