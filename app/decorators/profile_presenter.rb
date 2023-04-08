class ProfilePresenter < SimpleDelegator
  def created_at
    user.created_at.to_date
  end

  def date_of_birth
    super if user.preference.try(:date_of_birth_visible)
  end

  def email
    user.email if user.preference.try(:email_visible)
  end
end
