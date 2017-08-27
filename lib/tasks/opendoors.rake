namespace :opendoors do
  desc "Update urls for hexfiles import"
  task(:url_update_hexfiles => :environment) do
    c = Collection.find_by(name: "thehexfiles")
    c.works.find_each do |work|
      if work.imported_from_url.match /astele.co.uk\/hex\/Chapter\/Details\/(\d+)/
        work.imported_from_url = "http://www.thehexfiles.net/viewstory.php?sid=#{$1}"
        puts work.imported_from_url
        work.save
      end        
    end
  end

  desc "Update urls for hpfandom import"
  task(:url_update_hpfandom => :environment) do
    c = Collection.find_by(name: "hpfandom")
    c.works.find_each do |work|
      if work.imported_from_url.match /astele.co.uk\/hpfandom\/Chapter\/Details\/(\d+)/
        work.imported_from_url = "http://www.hpfandom.net/eff/viewstory.php?sid=#{$1}"
        puts work.imported_from_url
        work.save
      end
    end
  end
end