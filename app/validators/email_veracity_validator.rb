require 'mail'

# from http://my.rails-royce.org/2010/07/21/email-validation-in-ruby-on-rails-without-regexp/
class EmailVeracityValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    if options[:allow_blank] && value.blank?
      result = true 
    else
      begin
        mail = Mail::Address.new(value)
        # We must check that value contains a domain and that value is an email address
        result = mail.domain && mail.address == value

        # We need to dig into treetop
        # user@localhost is excluded
        # treetop must respond to domain
        # We exclude valid email values like <user@localhost.com>
        # Hence we use m.__send__(tree).domain
        treetop = mail.__send__(:tree)
      
        # A valid domain must have dot_atom_text elements size > 1
        result &&= (treetop.domain.dot_atom_text.elements.size > 1)
      rescue Exception => e   
        result = false
      end
    end
    unless result
      if options[:allow_blank]
        record.errors[attribute] << (options[:message] ||  I18n.t('validators.email.veracity.allow_blank'))
      else
        record.errors[attribute] << (options[:message] || I18n.t('validators.email.veracity.no_blank'))
      end
    end
  end
end
