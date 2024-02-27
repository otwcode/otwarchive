# frozen_string_literal: true

module NumberHelper
  # Converts a precise number to an approximate with no more than 4 digits.
  #
  # @example
  #   estimate_number(2) # 2
  #   estimate_number(25) # 25
  #   estimate_number(308) # 308
  #   estimate_number(1234) # 1234
  #   estimate_number(120345) # 120300
  def estimate_number(number)
    digits = [(Math.log10([number, 1].max).to_i - 3), 0].max
    divide = 10**digits
    divide * (number / divide).to_i
  end
end
