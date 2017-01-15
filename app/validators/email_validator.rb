require 'mail'
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      m = Mail::Address.new(value)
      # We must check that value contains a domain, the domain has at least
      # one '.' and that value is an email address      
      r = !m.domain.nil? && m.domain.match('\.') && m.address == value

      # Update 2015-Mar-24
      # the :tree method was private and is no longer available.
      # t = m.__send__(:tree)
      # We need to dig into treetop
      # A valid domain must have dot_atom_text elements size > 1
      # user@localhost is excluded
      # treetop must respond to domain
      # We exclude valid email values like <user@localhost.com>
      # Hence we use m.__send__(tree).domain
      # r &&= (t.domain.dot_atom_text.elements.size > 1)
    rescue   
      r = false
    end
    record.errors[attribute] << (options[:message] || "is invalid") unless r
  end
end
