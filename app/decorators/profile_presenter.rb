class ProfilePresenter < SimpleDelegator
  def created_at
    user.created_at.to_date
  end

  def date_of_birth
    nil
  end

  def email
    nil
  end

  def location
    nil
  end
end
