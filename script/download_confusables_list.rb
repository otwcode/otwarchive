# frozen_string_literal: true

# This script is for downloading and updating Unicode's confusables list which
# we use for checking guest comment names' likeness to forbidden names at
# app/validators/not_forbidden_name_validator.rb
#
# Run this script with:
#   bundle exec rails r script/download_confusables_list.rb

require "net/http"

# The directory which the confusables are stored in the otwarchive repository.
CONFUSABLES_DIRECTORY = "./script/confusables.txt"

# Uses regex to find the line that starts with "# Version:" and returns what
# comes after as string. Takes a string object as an argument.
def fetch_version(text)
  text.each_line do |line|
    if (match = line.match(/^# Version: (.*)$/))
      return match[1]
    end
  end
end

response = Net::HTTP.get_response(URI.parse("https://unicode.org/Public/security/latest/confusables.txt"))

if response.nil? || !response.is_a?(Net::HTTPSuccess)
  puts "Could not get confusables.txt. Try visiting"
  puts "https://unicode.org/Public/security/latest/confusables.txt to find"
  puts "the error."
  return
end

unless (latest_version = fetch_version(response.body))
  puts "Could not find version data on latest list. Format might be changed"
  puts "making it necessary to update this script."
  return
end

existing_version = File.open(CONFUSABLES_DIRECTORY, "rb") { |f| fetch_version(f) } if File.exist?(CONFUSABLES_DIRECTORY)
if !existing_version
  puts "We don't have confusables.txt, do you want to save the latest version"
  puts "#{latest_version} as #{CONFUSABLES_DIRECTORY}? (Y/n)"
elsif latest_version == existing_version
  puts "We already have the latest version which is #{existing_version}. Do you still want"
  puts "to download? (Y/n)"
else
  puts "We have the version #{existing_version} while the latest is #{latest_version}. Do you want to"
  puts "update? (Y/n)"
end

unless gets.chomp == "n"
  File.open(CONFUSABLES_DIRECTORY, "wb") { |f| f.write(response.body) }
  puts File.exist?(CONFUSABLES_DIRECTORY) ? "Save successful." : "Save failed."
end
