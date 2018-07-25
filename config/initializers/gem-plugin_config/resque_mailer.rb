Resque::Mailer.excluded_environments = [:test, :cucumber]
Resque::Mailer.error_handler = lambda { |mailer, message, error, action, args|
  if error.is_a?(Resque::TermException)
    Resque.enqueue(mailer, action, *args)
  elsif error.is_a?(ActiveRecord::RecordNotFound) && !args.include?(:retried)
    Resque.enqueue_in(5.minutes, mailer, action, :retried, *args)
  else
    raise error
  end
}