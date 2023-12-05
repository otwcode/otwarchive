class UserQuery < Query
  def klass
    'User'
  end

  def index_name
    UserIndexer.index_name
  end

  def filters
    @filters ||= [
      id_filter,
      inactive_filter,
      role_filter,
      email_filter,
      name_filter
    ].flatten.compact
  end

  def sort
    [{ login: { order: :asc } }, { id: { order: :asc } }]
  end

  ################
  # FILTERS
  ################

  def id_filter
    { term: { id: options[:user_id] } } if options[:user_id].present?
  end

  def inactive_filter
    { term: { active: false } } if options[:inactive].present?
  end

  def role_filter
    { term: { role_ids: options[:role_id] } } if options[:role_id].present?
  end

  def name_filter
    return unless options[:name].present?

    field = options[:search_past].present? ? :all_names : :names

    { wildcard: { field => options[:name] } }
  end

  def email_filter
    return unless options[:email].present?

    field = options[:search_past].present? ? :all_emails : :email

    { wildcard: { field => options[:email] } }
  end
end
