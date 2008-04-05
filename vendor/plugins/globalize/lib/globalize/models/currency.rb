module Globalize

=begin rdoc
  This is what you use for representing money in your ActiveRecord models.
  It stores values as integers internally and in the database, to safeguard 
  precision and rounding.

  More importantly for globalization freaks, it prints out the amount correctly
  in the current locale, via the handy #format method. Try it!

  Example:

    class Product < ActiveRecord::Base
      composed_of :price, :class_name => "Globalize::Currency", 
        :mapping => [ %w(price cents) ]
    end

    product.price -> "SFr. 483'232.43"
=end
  class Currency
    include Comparable

    attr_reader :cents
    
    class CurrencyError < StandardError# :nodoc:
    end

    # Creates a new Currency object, given cents. This is used to tie into
    # the ActiveRecord aggregation stuff.
    def initialize(cents)
      @cents = cents.nil? ? nil : cents.to_i
    end

    @@no_cents = false
    def self.no_cents; @@no_cents end
    def self.no_cents=(val); @@no_cents = val end

    @@free = Currency.new(0)
    @@free.freeze

    # Returns the Currency object representing a price of 0.
    def self.free
      @@free
    end

    @@na = Currency.new(nil)
    @@na.freeze

    # Returns the Currency object representing an unknown price.
    def self.na
      @@na
    end

    def <=>(other)
      if other.respond_to? :cents
        if na?
          other.na? ? 0 : 1
        else
          other.na? ? -1 : cents <=> other.cents
        end
      elsif other.kind_of? Integer
        na? ? 1 : cents <=> other
      else
        raise "can only compare with money or integer"
      end      
    end

    def +(other_money)
      raise TypeError, "parameter to Currency#+ must be Currency object" unless
        other_money.kind_of? Currency
      (na? || other_money.na?) ? Currency.na :
        Currency.new(cents + other_money.cents)
    end

    def -(other_money)
      raise TypeError, "parameter to Currency#+ must be Currency object" unless
        other_money.kind_of? Currency
      (na? || other_money.na?) ? Currency.na :
        Currency.new(cents - other_money.cents)
    end

    # Multiply money by amount
    def *(amount)
      return Currency.new(nil) if na?
      new_cents = amount * cents;
      new_cents = new_cents.round if new_cents.respond_to? :round
      Currency.new(new_cents)
    end

    # Divide money by amount
    def /(amount)
      return Currency.new(nil) if na?
      new_cents = cents / amount;
      new_cents = new_cents.round if new_cents.respond_to? :round
      Currency.new(new_cents)
    end

    # Returns the formatted version of the amount in local currency.
    # If <tt>:code => true</tt> is specified, format using international
    # 3-letter currency code. If <tt>:country</tt> is specified as well, 
    # use that country's currency code for formatting.
    def format(options = {})
      return :no_price_available.t("call for price") if na?

      force_cents = options[:force_cents]
			if options[:code]
        currency_code = options[:country] ? 
          options[:country].currency_code : 
          ( Locale.active? ? Locale.active.currency_code : nil )
        currency_code ? 
					self.amount(false, force_cents) + " " + currency_code : 
					self.amount(false, force_cents)
      else
        if Locale.active?
          fmt = Locale.active.currency_format || '$%n'
          fmt.sub('%n', self.amount(false, force_cents))
        else
          self.amount false, force_cents
        end
      end
    end

    # Returns the formatted version of the amount, but without the currency symbol.
    # If +unlocalized+ is true, do not format the number according to the current locale,
    # so <tt>Currency.new(1234567) -> 12345.67</tt>. This is useful for sending the 
    # amount to payment gateways.
    def amount(unlocalized = false, force_cents = false)
      return nil if na?
      decimal_sep = unlocalized ?
        '.' :
        (Locale.active? ? 
          (Locale.active.currency_decimal_sep || Locale.active.decimal_sep || '.') :
          '.')
      dollar_str = unlocalized ? dollar_part.to_s : dollar_part.localize
      result = dollar_str
      result << decimal_sep + sprintf("%02d", cent_part) unless 
        self.class.no_cents && !force_cents
      return result
    end

    # Same as #format with no arguments.
    def to_s
      self.format
    end

    # Parse a string or number into a currency object. Easier to use than #new.
    def self.parse(num)
      case
      when num.is_a?(String)
        raise ArgumentError, "Not an amount (#{num})" if num.delete("^0-9").empty?
        _dollars, _cents = num.delete("^0-9.").split('.', 2)
        _cents = _cents ? _cents[0,2] : 0
        Currency.new(_dollars.to_i * 100 + _cents.to_i)
      when num.is_a?(Numeric)
        Currency.new(num * 100)
      when num.is_a?(NilClass)
        Currency.na
      else
        raise ArgumentError, "Unrecognized object #{num.class.name} for Currency"
      end
    end

    # Conversion to self
    def to_currency
      self
    end

    # Is the value 0? Is it free?
    def empty?
      cents == 0
    end

    # Is the value unknown?
    def na?
      cents.nil?
    end

    private
      def dollar_part
        na? ? nil : cents / 100
      end

      def cent_part
        na? ? nil : cents % 100
      end

  end
end
