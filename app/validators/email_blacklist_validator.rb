class EmailBlacklistValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    if AdminBlacklistedEmail.is_blacklisted?(value)
      record.errors[attribute] << (options[:message] || I18n.t('email_blacklisted', default: "has been blocked at the owner's request. That means it can't be used in guest comments. Please check the address to make sure it's yours to use and contact AO3 Support if you have any questions."))
      return false
    else
      return true
    end
  end
end
