class ProfilePresenter < SimpleDelegator
  def created_at
    user.created_at.to_date
  end
end
