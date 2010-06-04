Given /^I wait (\d+) seconds?$/ do |number|
  Kernel::sleep number.to_i
end

When 'the system processes jobs' do
  Delayed::Job.work_off
end
