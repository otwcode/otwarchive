Given /^I wait (\d+) seconds?$/ do |number|
  Kernel::sleep number.to_i
end
