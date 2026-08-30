namespace :Before do
  desc "Backfill language sortable_name"
  task(backfill_language_sortable_name: :environment) do
    languages_to_backfill = Language.all.select { |language| language.sortable_name.blank? }
    puts "Backfilling sortable_name for #{languages_to_backfill.count} languages"

    languages_to_backfill.each do |language|
      language.update!(sortable_name: language.name)
    end
    puts "Finished backfilling sortable_name"
  end
end
