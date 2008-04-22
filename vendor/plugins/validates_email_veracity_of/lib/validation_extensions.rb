module ActiveRecord
  module Validations
    module ClassMethods
      
      # Validates the form of an email address and verifies it's domain by checking if there are any
      # mail exchange or address servers associated with it.
      #
      # ==== Options
      # * <b>message</b>
      #   - Changes the default error message.
      # * <b>domain_check</b>
      #   - Skips server lookup unless true.
      # * <b>timeout</b>
      #   - Time (in seconds) before the domain lookup is skipped. Default is 2.
      # * <b>fail_on_timeout</b>
      #   - Causes validation to fail if a timeout occurs.
      # * <b>timeout_message</b>
      #   - Changes the default timeout error message.
      # * <b>mx_only</b>
      #   - When set, only mail exchange servers (MX) are looked up and the address server (A)
      #     lookup is skipped.
      # * <b>invalid_domains</b>
      #   - An array of domain names that are not to be used. Useful for stuff like dodgeit.com
      #     and other services.
      # * <b>invalid_domain_message</b>
      #   - Changes the default invalid domain error message.
      #
      # ==== Examples
      # * <tt>validates_email_veracity_of :email, :message => 'is not correct.'</tt>
      #   - Changes the default error message from 'is invalid.' to 'is not correct.'
      # * <tt>validates_email_veracity_of :email, :domain_check => false</tt>
      #   - Domain lookup is skipped.
      # * <tt>validates_email_veracity_of :email, :timeout => 0.5</tt>
      #   - Causes the domain lookup to timeout if it does not complete within half a second.
      # * <tt>validates_email_veracity_of :email, :fail_on_timeout => true, :timeout_message => 'is invalid.'</tt>
      #   - Causes the validation to fail on timeout and changes the error message to 'is invalid.'
      #     to obfuscate it.
      # * <tt>validates_email_veracity_of :email, :mx_only => true</tt>
      #   - The validator will only check the domain for mail exchange (MX) servers, ignoring address
      #     servers (A) records.
      # * <tt>validates_email_veracity_of :email, :invalid_domains => %w[dodgeit.com harvard.edu]</tt>
      #   - Any email addresses @dodgeit.com or @harvard.edu will be rejected.
      def validates_email_veracity_of(*attr_names)
        configuration = {
          :message => 'is invalid.',
          :timeout_message => 'domain is currently unreachable, try again later.',
          :invalid_domain_message => 'provider is not supported, try another email address.',
          :timeout => 2,
          :domain_check => true,
          :invalid_domains => [],
          :mx_only => false,
          :fail_on_timeout => false
        }
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
        validates_each(attr_names, configuration) do |record, attr_name, value|
          next if value.blank?
          email = ValidatesEmailVeracityOf::EmailAddress.new(value)
          message = :message unless email.pattern_is_valid?
          message = :invalid_domain_message unless email.domain_is_valid?(configuration)
          if configuration[:domain_check] && !message
            message = case email.domain_has_servers?(configuration)
              when nil then :timeout_message
              when false then :message
            end
          end
          record.errors.add(attr_name, configuration[message]) if message
        end
      end
      
    end
  end
end