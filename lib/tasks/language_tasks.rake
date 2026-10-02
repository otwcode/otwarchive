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

  # Fallback for the migration that copied the languages table.
  # Use only if the locale_languages data needs to be re-synced.
  desc "Populate locale_languages table from languages table"
  task populate_locale_languages_table: :environment do
    created = 0
    updated = 0
    failed = 0

    Language.find_each do |language|
      locale_language = LocaleLanguage.find_or_initialize_by(id: language.id)
      new_record = locale_language.new_record?
      locale_language.assign_attributes(
        name: language.name,
        short: language.short,
        support_available: language.support_available,
        abuse_support_available: language.abuse_support_available,
        sortable_name: language.sortable_name
      )

      if locale_language.save
        new_record ? created += 1 : updated += 1
      else
        failed += 1
        errors = locale_language.errors.full_messages.to_sentence
        puts "Failed to sync locale language for language #{language.id} " \
             "(#{language.short}): #{errors}"
      end
    end

    puts "Done: #{created} created, #{updated} updated, #{failed} failed."
  end
end
