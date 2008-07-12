
Dir.chdir(File.dirname(__FILE__)) do
  Dir["unit/*.rb", "integration/*.rb"].each do |file|
    next if file =~ /unit_tests\.rb/
    puts "\n*** #{file} ***"
    system("ruby #{file}")
  end
end
