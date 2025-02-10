module ResqueExecutorWrap
  def around_perform_wrap_executor(*args)
    Rails.application.executor.wrap { yield }
  end
end
