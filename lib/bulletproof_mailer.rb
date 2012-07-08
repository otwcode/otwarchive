# See: http://stackoverflow.com/questions/6550809/rails-3-how-to-abort-delivery-method-in-actionmailer
module BulletproofMailer
  class BlackholeMailMessage < Mail::Message
    def self.deliver
      false
    end
  end

  class AbortDeliveryError < StandardError
  end

  class Base < ActionMailer::Base

    def abort_delivery
      raise AbortDeliveryError
    end

    def process(*args)
      begin
        super *args
      rescue AbortDeliveryError
        self.message = BulletproofMailer::BlackholeMailMessage
      end
    end
  end
end
