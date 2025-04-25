module Opendoors
  def self.table_name_prefix
    'opendoors_'
  end

  def self.update_work_from_csv(row)
    work = Work.find(row["AO3 id"])
    # TODO: AO3-6979
    if work&.imported_from_url.blank? || work&.imported_from_url == row["URL Imported From"]
      work.imported_from_url = row["Original URL"]
      work.save!
      work.import_url!(row["Original URL"])
      "#{work.id}\twas updated: its import url is now #{work.imported_from_url}"
    else
      "#{work.id}\twas not changed: its import url is #{work.imported_from_url}"
    end
  rescue StandardError => e
    "#{row['AO3 id']}\twas not changed: #{e}"
  end
end
