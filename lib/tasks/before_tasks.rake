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

  desc "Convert collection participants with the removed Invited role to None"
  task(remove_invited_collection_participant_role: :environment) do
    updated = 0
    failed = []
    CollectionParticipant.where(participant_role: "Invited")
      .find_each do |participant|
        if participant.update(participant_role: CollectionParticipant::NONE)
          updated += 1
        else
          failed << participant.id
        end
      end
    puts "Converted #{updated} invited #{'participant'.pluralize(updated)} to None"
    puts "Failed to convert: #{failed.join(', ')}" unless failed.empty?
  end
end
