namespace :opendoors do
  desc "Map import urls based on spreadsheet data"
  task(:import_url_mapping => :environment) do
    puts "Where is the Open Doors CSV located?"
    loc = gets.chomp
    CSV.foreach(loc, headers: true) do |row|
      begin
        work = Work.where(imported_from_url: row["URL Imported From"]).first
        if work
          work.imported_from_url = row["Original URL"]
          puts work.imported_from_url
          work.save!
        end
      rescue
        puts "Could not update work from #{row["Original URL"]}"
      end
    end
  end
end