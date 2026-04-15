namespace :OwnedTagSet do
  desc "Deduplicate owners for owned tag sets"
  task(deduplicate_owners: :environment) do
    # It's only possible to have duplicate ownership with more than one ownership record
    OwnedTagSet.find_in_batches do |batch|
      batch.each do |owned_tag_set|
        # Again, we can only have this bug if we have more than one owner
        next unless owned_tag_set.owners.count > 1

        # Deduplicate existing records
        unique_ownerships = Set[]
        owned_tag_set.tag_set_ownerships.each do |ownership|
          # by construction, all ownerships are inside a single OwnedTagSet
          # so just track which pairs of (psued, owner/maintainer) exist
          pseud_owner = [ownership.pseud_id, ownership.owner]
          # Keep the first assignment for each pseud and role, remove others
          if unique_ownerships.include?(pseud_owner)
            ownership.destroy
          else
            unique_ownerships.add(pseud_owner)
          end
        end
        print "+"
      end
      print "."
    end

    puts "Duplicate owners for owned tag sets have been removed"
  end
end
