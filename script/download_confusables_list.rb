# frozen_string_literal: true
require 'net/http'

# todo finalize
CONFUSABLES_TXT_DIRECTORY = "./confusables.txt"

# todo add comment
def fetch_version(text)
  text.each_line do |line|
    if (match = line.match(/^# Version: (.*)$/))
      return match.captures
    end
  end
end


# todo catch possible errors
response = Net::HTTP.start("unicode.org") { |http| http.get("/Public/security/latest/confusables.txt") }

latest_version = fetch_version(response.body)
unless latest_version
  # todo raise some kind of error and exit maybe
  puts "Could not find version data on latest list. Format might be changed making it necessary to update the script."
end

begin
  existing_version = open(CONFUSABLES_TXT_DIRECTORY, "rb") { |file| fetch_version(file) }
rescue => e
  puts "Couldn't find confusables.txt #{e}"
end

if not existing_version# no confusables in directory
  puts "We don't have confusables.txt, do you want to save the latest version (#{latest_version}) as #{CONFUSABLES_TXT_DIRECTORY}? (y/N)"
  open(CONFUSABLES_TXT_DIRECTORY, "wb") { |file| file.write(response.body) } if gets.chomp == "y"
elsif latest_version != existing_version
  puts "We have the version #{existing_version} while the latest is #{latest_version}. Do you want to update? (y/N)"
  open(CONFUSABLES_TXT_DIRECTORY, "wb") { |file| file.write(response.body) } if gets.chomp == "y"
else # they're equal then
  puts "We already have the latest version (#{existing_version})."
end
