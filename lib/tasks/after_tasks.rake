namespace :After do
  # Keep only the most recent tasks, i.e., about two years' worth.
  # If you need older tasks, check GitHub.

  desc "Update the mapping for the work index"
  task(update_work_mapping: :environment) do
    WorkIndexer.create_mapping
  end

  desc "Fix tags with extra spaces"
  task(fix_tags_with_extra_spaces: :environment) do
    total_tags = Tag.count
    total_batches = (total_tags + 999) / 1000
    puts "Inspecting #{total_tags} tags in #{total_batches} batches"

    report_string = ["Tag ID", "Old tag name", "New tag name"].to_csv
    Tag.find_in_batches.with_index do |batch, index|
      batch_number = index + 1
      progress_msg = "Batch #{batch_number} of #{total_batches} complete"

      batch.each do |tag|
        next unless tag.name != tag.name.squish

        old_tag_name = tag.name
        new_tag_name = old_tag_name.gsub(/[[:space:]]/, "_")

        new_tag_name << "_" while Tag.find_by(name: new_tag_name)
        tag.update_attribute(:name, new_tag_name)

        report_row = [tag.id, old_tag_name, new_tag_name].to_csv
        report_string += report_row
      end

      puts(progress_msg) && STDOUT.flush
    end
    puts(report_string) && STDOUT.flush
  end

  desc "Fix works imported with a noncanonical Teen & Up Audiences rating tag"
  task(fix_teen_and_up_imported_rating: :environment) do
    borked_rating_tag = Rating.find_by!(name: "Teen & Up Audiences")
    canonical_rating_tag = Rating.find_by!(name: ArchiveConfig.RATING_TEEN_TAG_NAME)

    work_ids = []
    invalid_work_ids = []
    borked_rating_tag.works.find_each do |work|
      work.ratings << canonical_rating_tag
      work.ratings = work.ratings - [borked_rating_tag]
      if work.save
        work_ids << work.id
      else
        invalid_work_ids << work.id
      end
      print(".") && STDOUT.flush
    end

    unless work_ids.empty?
      puts "Converted '#{borked_rating_tag.name}' rating tag on #{work_ids.size} works:"
      puts work_ids.join(", ")
      STDOUT.flush
    end

    unless invalid_work_ids.empty?
      puts "The following #{invalid_work_ids.size} works failed validations and could not be saved:"
      puts invalid_work_ids.join(", ")
      STDOUT.flush
    end
  end

  desc "Clean up multiple rating tags"
  task(clean_up_multiple_ratings: :environment) do
    default_rating_tag = Rating.find_by!(name: ArchiveConfig.RATING_DEFAULT_TAG_NAME)
    es_results = $elasticsearch.search(index: WorkIndexer.index_name, body: {
                                         query: {
                                           bool: {
                                             filter: {
                                               script: {
                                                 script: {
                                                   source: "doc['rating_ids'].length > 1",
                                                   lang: "painless"
                                                 }
                                               }
                                             }
                                           }
                                         }
                                       })
    invalid_works = QueryResult.new("Work", es_results)

    puts "There are #{invalid_works.size} works with multiple ratings."

    fixed_work_ids = []
    unfixed_word_ids = []
    invalid_works.each do |work|
      work.ratings = [default_rating_tag]
      work.rating_string = default_rating_tag.name

      if work.save
        fixed_work_ids << work.id
      else
        unfixed_word_ids << work.id
      end
      print(".") && $stdout.flush
    end

    unless fixed_work_ids.empty?
      puts "Cleaned up having multiple ratings on #{fixed_work_ids.size} works:"
      puts fixed_work_ids.join(", ")
      $stdout.flush
    end

    unless unfixed_word_ids.empty?
      puts "The following #{unfixed_word_ids.size} works failed validations and could not be saved:"
      puts unfixed_word_ids.join(", ")
      $stdout.flush
    end
  end

  desc "Clean up noncanonical rating tags"
  task(clean_up_noncanonical_ratings: :environment) do
    canonical_not_rated_tag = Rating.find_by!(name: ArchiveConfig.RATING_DEFAULT_TAG_NAME)
    noncanonical_ratings = Rating.where(canonical: false)
    puts "There are #{noncanonical_ratings.size} noncanonical rating tags."

    next if noncanonical_ratings.empty?

    puts "The following noncanonical Ratings will be changed into Additional Tags:"
    puts noncanonical_ratings.map(&:name).join("\n")

    work_ids = []
    invalid_work_ids = []
    noncanonical_ratings.find_each do |tag|
      works_using_tag = tag.works
      tag.update_attribute(:type, "Freeform")

      works_using_tag.find_each do |work|
        next unless work.ratings.empty?

        work.ratings = [canonical_not_rated_tag]
        if work.save
          work_ids << work.id
        else
          invalid_work_ids << work.id
        end
        print(".") && STDOUT.flush
      end
    end

    unless work_ids.empty?
      puts "The following #{work_ids.size} works were left without a rating and successfully received the Not Rated rating:"
      puts work_ids.join(", ")
      STDOUT.flush
    end

    unless invalid_work_ids.empty?
      puts "The following #{invalid_work_ids.size} works failed validations and could not be saved:"
      puts invalid_work_ids.join(", ")
      STDOUT.flush
    end
  end

  desc "Clean up noncanonical category tags"
  task(clean_up_noncanonical_categories: :environment) do
    Category.where(canonical: false).find_each do |tag|
      tag.update_attribute(:type, "Freeform")
      puts "Noncanonical Category tag '#{tag.name}' was changed into an Additional Tag."
    end
    STDOUT.flush
  end

  desc "Add default rating to works missing a rating"
  task(add_default_rating_to_works: :environment) do
    work_count = Work.count
    total_batches = (work_count + 999) / 1000
    puts("Checking #{work_count} works in #{total_batches} batches") && STDOUT.flush
    updated_works = []

    Work.find_in_batches.with_index do |batch, index|
      batch_number = index + 1

      batch.each do |work|
        next unless work.ratings.empty?

        work.ratings << Rating.find_by!(name: ArchiveConfig.RATING_DEFAULT_TAG_NAME)
        work.save
        updated_works << work.id
      end
      puts("Batch #{batch_number} of #{total_batches} complete") && STDOUT.flush
    end
    puts("Added default rating to works: #{updated_works}") && STDOUT.flush
  end

  desc "Backfill renamed_at for existing users"
  task(add_renamed_at_from_log: :environment) do
    total_users = User.all.size
    total_batches = (total_users + 999) / 1000
    puts "Updating #{total_users} users in #{total_batches} batches"

    User.find_in_batches.with_index do |batch, index|
      batch.each do |user|
        renamed_at_from_log = user.log_items.where(action: ArchiveConfig.ACTION_RENAME).last&.created_at
        next unless renamed_at_from_log

        user.update_column(:renamed_at, renamed_at_from_log)
      end

      batch_number = index + 1
      progress_msg = "Batch #{batch_number} of #{total_batches} complete"
      puts(progress_msg) && STDOUT.flush
    end
    puts && STDOUT.flush
  end

  desc "Fix threads for comments from 2009"
  task(fix_2009_comment_threads: :environment) do
    def fix_comment(comment)
      comment.with_lock do
        if comment.reply_comment?
          comment.update_column(:thread, comment.commentable.thread)
        else
          comment.update_column(:thread, comment.id)
        end
        comment.comments.each { |reply| fix_comment(reply) }
      end
    end

    incorrect = Comment.top_level.where("thread != id")
    total = incorrect.count

    puts "Updating #{total} thread(s)"

    incorrect.find_each.with_index do |comment, index|
      fix_comment(comment)

      puts "Fixed thread #{index + 1} out of #{total}" if index % 100 == 99
    end
  end

  desc "Remove translation_admin role"
  task(remove_translation_admin_role: :environment) do
    r = Role.find_by(name: "translation_admin")
    r&.destroy
  end

  desc "Remove full-width and ideographic commas from tags"
  task(remove_invalid_commas_from_tags: :environment) do
    puts("Tags can only be renamed by an admin, who will be listed as the tag's last wrangler. Enter the admin login we should use:")
    login = $stdin.gets.chomp.strip
    admin = Admin.find_by(login: login)

    if admin.present?
      User.current_user = admin

      ["，", "、"].each do |comma|
        tags = Tag.where("name LIKE ?", "%#{comma}%")
        tags.each do |tag|
          new_name = tag.name.gsub(/#{comma}/, "")
          if tag.update(name: new_name) || tag.update(name: "#{new_name} - AO3-6626")
            puts(tag.reload.name)
          else
            puts("Could not rename #{tag.reload.name}")
          end
          $stdout.flush
        end
      end
    else
      puts("Admin not found.")
    end
  end

  desc "Add suffix to existing Underage Sex tag in preparation for Underage warning rename"
  task(add_suffix_to_underage_sex_tag: :environment) do
    puts("Tags can only be renamed by an admin, who will be listed as the tag's last wrangler. Enter the admin login we should use:")
    login = $stdin.gets.chomp.strip
    admin = Admin.find_by(login: login)

    if admin.present?
      User.current_user = admin

      tag = Tag.find_by_name("Underage Sex")

      if tag.blank?
        puts("No Underage Sex tag found.")
      elsif tag.is_a?(ArchiveWarning)
        puts("Underage Sex is already an Archive Warning.")
      else
        suffixed_name = "Underage Sex - #{tag.class}"
        if tag.update(name: suffixed_name)
          puts("Renamed Underage Sex tag to #{tag.reload.name}.")
        else
          puts("Failed to rename Underage Sex tag to #{suffixed_name}.")
        end
        $stdout.flush
      end
    else
      puts("Admin not found.")
    end
  end

  desc "Rename Underage warning to Underage Sex"
  task(rename_underage_warning: :environment) do
    puts("Tags can only be renamed by an admin, who will be listed as the tag's last wrangler. Enter the admin login we should use:")
    login = $stdin.gets.chomp.strip
    admin = Admin.find_by(login: login)

    if admin.present?
      User.current_user = admin

      tag = ArchiveWarning.find_by_name("Underage")

      if tag.blank?
        puts("No Underage warning tag found.")
      else
        new_name = "Underage Sex"
        if tag.update(name: new_name)
          puts("Renamed Underage warning tag to #{tag.reload.name}.")
        else
          puts("Failed to rename Underage warning tag to #{new_name}.")
        end
        $stdout.flush
      end
    else
      puts("Admin not found.")
    end
  end

  desc "Migrate collection icons to ActiveStorage paths"
  task(migrate_collection_icons: :environment) do
    require "aws-sdk-s3"
    require "open-uri"

    return unless Rails.env.staging? || Rails.env.production?

    bucket_name = ENV["S3_BUCKET"]
    prefix = "collections/icons/"
    s3 = Aws::S3::Resource.new(
      region: ENV["S3_REGION"],
      access_key_id: ENV["S3_ACCESS_KEY_ID"],
      secret_access_key: ENV["S3_SECRET_ACCESS_KEY"]
    )
    old_bucket = s3.bucket(bucket_name)
    new_bucket = s3.bucket(ENV["TARGET_BUCKET"])

    Collection.no_touching do
      old_bucket.objects(prefix: prefix).each do |object|
        # Path example: staging/icons/108621/original.png
        path_parts = object.key.split("/")
        next unless path_parts[-1]&.include?("original")
        next if ActiveStorage::Attachment.where(record_type: "Collection", record_id: path_parts[-2]).any?

        collection_id = path_parts[-2]
        old_icon = URI.open("https://s3.amazonaws.com/#{bucket_name}/#{object.key}")
        checksum = OpenSSL::Digest.new("MD5").tap do |result|
          while (chunk = old_icon.read(5.megabytes))
            result << chunk
          end
          old_icon.rewind
        end.base64digest

        key = nil
        ActiveRecord::Base.transaction do
          blob = ActiveStorage::Blob.create_before_direct_upload!(
            filename: path_parts[-1],
            byte_size: old_icon.size,
            checksum: checksum,
            content_type: Marcel::MimeType.for(old_icon)
          )
          key = blob.key
          blob.attachments.create(
            name: "icon",
            record_type: "Collection",
            record_id: collection_id
          )
        end

        new_bucket.put_object(key: key, body: old_icon, acl: "bucket-owner-full-control")
        puts "Finished collection #{collection_id}"
        $stdout.flush
      end
    end
  end

  desc "Migrate pseud icons to ActiveStorage paths"
  task(migrate_pseud_icons: :environment) do
    require "aws-sdk-s3"
    require "open-uri"

    return unless Rails.env.staging? || Rails.env.production?

    bucket_name = ENV["S3_BUCKET"]
    prefix = Rails.env.production? ? "icons/" : "staging/icons/"
    s3 = Aws::S3::Resource.new(
      region: ENV["S3_REGION"],
      access_key_id: ENV["S3_ACCESS_KEY_ID"],
      secret_access_key: ENV["S3_SECRET_ACCESS_KEY"]
    )
    old_bucket = s3.bucket(bucket_name)
    new_bucket = s3.bucket(ENV["TARGET_BUCKET"])

    Pseud.no_touching do
      old_bucket.objects(prefix: prefix).each do |object|
        # Path example: staging/icons/108621/original.png
        path_parts = object.key.split("/")
        next unless path_parts[-1]&.include?("original")
        next if ActiveStorage::Attachment.where(record_type: "Pseud", record_id: path_parts[-2]).any?

        pseud_id = path_parts[-2]
        old_icon = URI.open("https://s3.amazonaws.com/#{bucket_name}/#{object.key}")
        checksum = OpenSSL::Digest.new("MD5").tap do |result|
          while (chunk = old_icon.read(5.megabytes))
            result << chunk
          end
          old_icon.rewind
        end.base64digest

        key = nil
        ActiveRecord::Base.transaction do
          blob = ActiveStorage::Blob.create_before_direct_upload!(
            filename: path_parts[-1],
            byte_size: old_icon.size,
            checksum: checksum,
            content_type: Marcel::MimeType.for(old_icon)
          )
          key = blob.key
          blob.attachments.create(
            name: "icon",
            record_type: "Pseud",
            record_id: pseud_id
          )
        end

        new_bucket.put_object(key: key, body: old_icon, acl: "bucket-owner-full-control")
        puts "Finished pseud #{pseud_id}"
        $stdout.flush
      end
    end
  end

  desc "Migrate skin icons to ActiveStorage paths"
  task(migrate_skin_icons: :environment) do
    require "aws-sdk-s3"
    require "open-uri"

    return unless Rails.env.staging? || Rails.env.production?

    bucket_name = ENV["S3_BUCKET"]
    prefix = "skins/icons/"
    s3 = Aws::S3::Resource.new(
      region: ENV["S3_REGION"],
      access_key_id: ENV["S3_ACCESS_KEY_ID"],
      secret_access_key: ENV["S3_SECRET_ACCESS_KEY"]
    )
    old_bucket = s3.bucket(bucket_name)
    new_bucket = s3.bucket(ENV["TARGET_BUCKET"])

    Skin.no_touching do
      old_bucket.objects(prefix: prefix).each do |object|
        # Path example: staging/icons/108621/original.png
        path_parts = object.key.split("/")
        next unless path_parts[-1]&.include?("original")
        next if ActiveStorage::Attachment.where(record_type: "Skin", record_id: path_parts[-2]).any?

        skin_id = path_parts[-2]
        old_icon = URI.open("https://s3.amazonaws.com/#{bucket_name}/#{object.key}")
        checksum = OpenSSL::Digest.new("MD5").tap do |result|
          while (chunk = old_icon.read(5.megabytes))
            result << chunk
          end
          old_icon.rewind
        end.base64digest

        key = nil
        ActiveRecord::Base.transaction do
          blob = ActiveStorage::Blob.create_before_direct_upload!(
            filename: path_parts[-1],
            byte_size: old_icon.size,
            checksum: checksum,
            content_type: Marcel::MimeType.for(old_icon)
          )
          key = blob.key
          blob.attachments.create(
            name: "icon",
            record_type: "Skin",
            record_id: skin_id
          )
        end

        new_bucket.put_object(key: key, body: old_icon, acl: "bucket-owner-full-control")
        puts "Finished skin #{skin_id}"
        $stdout.flush
      end
    end
  end

  desc "Migrate pinch_request_signup to request_signup"
  task(migrate_pinch_request_signup: :environment) do
    count = ChallengeAssignment.where("pinch_request_signup_id IS NOT NULL AND request_signup_id IS NULL").update_all("request_signup_id = pinch_request_signup_id")
    puts("Migrated pinch_request_signup for #{count} challenge assignments.")
  end

  desc "Reindex tags associated with works that are hidden or unrevealed"
  task(reindex_hidden_unrevealed_tags: :environment) do
    hidden_count = Work.hidden.count
    hidden_batches = (hidden_count + 999) / 1_000
    puts "Inspecting #{hidden_count} hidden works in #{hidden_batches} batches"
    Work.hidden.find_in_batches.with_index do |batch, index|
      batch.each { |work| work.taggings.each(&:update_search) }
      puts "Finished batch #{index + 1} of #{hidden_batches}"
    end

    unrevealed_count = Work.unrevealed.count
    unrevealed_batches = (unrevealed_count + 999) / 1_000
    puts "Inspecting #{unrevealed_count} unrevealed works in #{unrevealed_batches} batches"
    Work.unrevealed.find_in_batches.with_index do |batch, index|
      batch.each { |work| work.taggings.each(&:update_search) }
      puts "Finished batch #{index + 1} of #{unrevealed_batches}"
    end

    puts "Finished reindexing tags on hidden and unrevealed works"
  end
  # This is the end that you have to put new tasks above.
end
