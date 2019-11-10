# frozen_string_literal: true

require 'benchmark'

if ARGV.size.zero? || ARGV.size > 2
  puts "
    Usage: rails runner benchmark_assignment.rb <EXCHANGE> [<TEST_MESSAGE>]

    Regenerates assignments for the specified exchange, recording the amount
    of time it takes.  If <TEST_MESSAGE> is specified, it will also log the
    results of the test to the file log/benchmark.log.
  "
  exit
end

exchange_name = ARGV[0]
test_name = ARGV[1]

collection = Collection.find_by(name: exchange_name)
count = collection.signups.count
matches = collection.potential_matches.count

bench = Benchmark.measure do
  ChallengeAssignment.delayed_generate collection.id
end

puts "Time Required: " + bench.to_s
puts "Signups: " + count.to_s
puts "Potential Matches: " + matches.to_s

puts "Assignments With No Giver: " + \
  collection.assignments.where(offer_signup_id: nil).count.to_s
puts "Assignments With No Recipient: " + \
  collection.assignments.where(request_signup_id: nil).count.to_s

# Retrieve all complete assignments from the database, so that we can check for
# "cycles" where A is assigned to B and B is assigned to A:
pairs = collection.assignments
  .where.not(offer_signup_id: nil)
  .where.not(request_signup_id: nil)
  .pluck(:offer_signup_id, :request_signup_id)
  .map(&:sort)
puts "Cycles: " + (pairs.size - pairs.uniq.size).to_s

unless test_name.nil?
  File.open('log/benchmark.log', 'a') do |f|
    f << "Generate Assignments\n"
    f << "#{test_name}\n"
    f << "#{exchange_name} (#{count} signups, #{matches} matches)\n"
    f << bench << "\n"
  end
end
