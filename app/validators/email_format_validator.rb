# From Authlogic, to mimic old behavior
#
# https://github.com/binarylogic/authlogic/blob/master/lib/authlogic/regex.rb
# (line 13)
#
# https://github.com/binarylogic/authlogic/blob/master/lib/authlogic/acts_as_authentic/email.rb
# (line 90)
#
class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    email_regex ||= begin
      email_name_regex = '[A-Z0-9_\.&%\+\-\']+'
      domain_head_regex = '(?:[A-Z0-9\-]+\.)+'
      domain_tld_regex = '(?:[A-Z]{2,25})'
      /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
    end

    if value.match(email_regex)
      true
    else
      record.errors[attribute] << (options[:message] || I18n.t('validators.email.format'))
    end
  end
end
