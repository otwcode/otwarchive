class AdminPostPolicy
  attr_reader :admin, :post

  POSTING_ROLES = %w(superadmin communications translation)

  def initialize(admin, post=nil)
    @admin = admin
    @post = post
  end

  def create?
    can_post?
  end

  def update?
    can_post?
  end

  def destroy?
    can_post?
  end

  def can_post?
    admin && (POSTING_ROLES & admin.roles).present?
  end
end