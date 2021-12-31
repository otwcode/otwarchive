class ReservedUsernameValidator < ActiveModel::EachValidator
    def validate_each(record,attribute,value)
      if AdminReservedUsername.is_reserved?(value)
        record.errors[attribute] << (options[:message] || I18n.t('validators.username.reserved'))
        return false
      else
        return true
      end
    end
  end
