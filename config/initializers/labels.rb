begin
  ActiveRecord::Base.connection  # if we have no database fall through to rescue
  ['Fandoms', 'Characters', 'Ratings', 'Warnings' ].each do |official|
    label = Label.find_or_create_by_name(official)
    label.meta = 'official'
    label.save
  end
rescue
  puts "Official labels may have not been initialized"
end
