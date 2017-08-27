namespace :opendoors do
  desc "Map import urls based on spreadsheet data"
  task(:import_url_mapping => :environment) do
    puts "Where is the Open Doors CSV located?"
    loc = gets.chomp
    CSV.foreach(loc, headers: true) do |row|
      row["AO3 URL"].match(/works\/(\d+)/)
      work = Work.find($1)
      if work.imported_from_url == row["URL Imported From"]
        work.imported_from_url = row["Original URL"]
        puts work.imported_from_url
        work.save
      end
    end
  end
end