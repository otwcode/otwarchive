namespace :opendoors do
  desc "Map import urls based on spreadsheet data - required fields: 'AO3 id', 'URL Imported From', 'Original URL'"
  task :import_url_mapping, [:csv] => :environment do |_t, args|
    loc = if args[:csv].nil?
            puts "Where is the Open Doors CSV located?"
            $stdin.gets.chomp
          else
            args[:csv]
          end

    begin
      f = File.open("opendoors_result.txt", "w")
      
      CSV.foreach(loc, headers: true) do |row|
        result = Opendoors.update_work_from_csv(row)
        puts result
        f.write(result)
      end
    rescue TypeError => e # No or invalid CSV file
      puts "Error parsing CSV file #{loc}: #{e.message}"
    ensure
      f.close
    end
  end
end
