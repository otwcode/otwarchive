# always enable enqueue_after_transaction_commit
# TODO: remove for rails 8.2! https://github.com/rails/rails/commit/a477a3273c3c71305cc8ae1835638dc75184ad9d
Rails.application.config.after_initialize do
  ActiveSupport.on_load(:active_job) do
    ActiveJob::Base.enqueue_after_transaction_commit = true
  end
end
