module MailerMacros
  def last_email
    ActionMailer::Base.deliveries.last
  end

  def reset_email
    ActionMailer::Base.deliveries = []
  end

  def at_least_one_email_to(recipient)
    ActionMailer::Base.deliveries.any? do |em|
      em.to.include?(recipient)
    end
  end

  def no_email_to(recipient)
    !(ActionMailer::Base.deliveries.any? {|em| em.to.include?(recipient)})
  end

  def count_emails_to(recipient)
    ActionMailer::Base.deliveries.collect(&:to).flatten.select {|recip| recip =~ Regexp.new(Regexp.escape(recipient), Regexp::IGNORECASE) }.count
  end

end
