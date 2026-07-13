# frozen_string_literal: true

require 'open-uri'
download = URI.open('https://www.unicode.org/Public/security/latest/confusables.txt')

download.each_line do |line|
  latest_version = line.scan(/^# Version: (.*)$/) if line.scan(/^# Version: (.*)$/)
end




File.foreach

if true# no confusables in directory
  puts "do you want to save the latest version (#{latest_version}) as ./confusables.txt ?"



  IO.copy_stream(download, './confusables.txt')

elsif # latest_version != existing
  puts "do you want to update?"
end

