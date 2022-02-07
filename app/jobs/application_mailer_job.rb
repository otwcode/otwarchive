class ApplicationMailerJob < ActionMailer::MailDeliveryJob
  # TODO: We have a mix of mailers that take ActiveRecords as arguments, and
  # mailers that take IDs as arguments. If an item is unavailable when the
  # notification is sent, it'll produce an ActiveJob::DeserializationError in
  # the former case, and an ActiveRecord::RecordNotFound error in the latter.
  #
  # Ideally, we don't want to catch RecordNotFound errors, because they might
  # be a sign of a different problem. But until we move all of the mailers over
  # to taking ActiveRecords as arguments, we need to catch both errors.

  retry_on ActiveJob::DeserializationError,
           attempts: 3,
           wait: 1.minute do
    # silently discard job after 3 failures
  end

  retry_on ActiveRecord::RecordNotFound,
           attempts: 3,
           wait: 1.minute do
    # silently discard job after 3 failures
  end
end
