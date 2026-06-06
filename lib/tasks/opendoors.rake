namespace :opendoors do
  def update_work(row)
    begin
      work = Work.find(row["AO3 id"])
      # ImportedUrl needs an original value, so we use the imported url temporarily and only save if we're actually updating it
      work.imported_url = ImportedUrl.new(:original => row["URL Imported From"]) if work.imported_url.nil?

      if work.imported_url.original == row["URL Imported From"]
        work.imported_url.original = row["Original URL"]
        work.imported_url.save!
        "#{work.id}\twas updated: its import url is now #{work.imported_url.original}"
      else
        "#{work.id}\twas not changed: its import url is #{work.imported_url.original}"
      end
    rescue StandardError => e
      "#{row["AO3 id"]}\twas not changed: #{e}"
    end
  end
  
  desc "Map import urls based on spreadsheet data - required fields: 'AO3 id', 'URL Imported From', 'Original URL'"
  task :import_url_mapping, [:csv] => :environment do |_t, args|
    loc = if args[:csv].nil?
            puts "Where is the Open Doors CSV located?"
             STDIN.gets.chomp
          else
            args[:csv]
          end

    begin
      f = File.open("opendoors_result.txt", "w")
      CSV.foreach(loc, headers: true) do |row|
        result = update_work(row)
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
