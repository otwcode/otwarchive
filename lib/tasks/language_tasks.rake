namespace :db do
  desc "Check for duplicate language names before adding unique index migration"
  task check_language_name_duplicates: :environment do
    duplicates = Language.group(:name)
      .having("COUNT(*) > 1")
      .count

    if duplicates.any?
      puts "Duplicate language names found:"
      duplicates.each do |name, count|
        puts "#{name} appears #{count} times"
      end

      abort("Please resolve duplicate language names before running migrations.")
    else
      puts "No duplicate language names found."
    end
  end
end
