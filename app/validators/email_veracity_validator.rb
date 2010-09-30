require 'mail'

# from http://my.rails-royce.org/2010/07/21/email-validation-in-ruby-on-rails-without-regexp/
class EmailVeracityValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
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
    record.errors[attribute] << (options[:message] || "is not a valid email address") unless result
  end
end
