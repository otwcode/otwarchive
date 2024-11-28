# frozen_string_literal: true

class ArchiveFaqPolicy < ApplicationPolicy
  TRANSLATION_ACCESS_ROLES = %w[superadmin docs support translation].freeze
  # a subset of TRANSLATION_ACCESS_ROLES
  FULL_ACCESS_ROLES = %w[superadmin docs support].freeze

  def translation_access?
    user_has_roles?(TRANSLATION_ACCESS_ROLES)
  end

  def full_access?
    user_has_roles?(FULL_ACCESS_ROLES)
  end

  alias edit? translation_access?
  alias update? translation_access?
  alias new? full_access?
  alias create? full_access?
  alias manage? full_access?
  alias update_positions? full_access?
  alias confirm_delete? full_access?
  alias destroy? full_access?
end
