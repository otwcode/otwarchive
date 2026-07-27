# frozen_string_literal: true

class GeneratedDownloadJob < ApplicationJob
  queue_as :utilities

  def perform(generated_download)
    return if generated_download.expired?

    generated_download.update!(status: "processing", error: nil)

    case generated_download.kind
    when "work"
      attach_work(generated_download)
    when "challenge_signups", "tag_wrangler", "bulk_user_search"
      attach_csv(generated_download)
    else
      raise ArgumentError, "Unknown generated download kind: #{generated_download.kind}"
    end

    generated_download.update!(status: "ready")
  rescue StandardError => e
    generated_download.update_columns(status: "failed", error: e.message, updated_at: Time.current)
    raise
  end

  private

  def attach_work(generated_download)
    arguments = generated_download.arguments
    download = Download.new(
      Work.find(arguments.fetch("work_id")),
      format: arguments.fetch("format")
    ).generate
    raise "Download generation failed" unless download.exists?

    file_path = File.join(download.dir, File.basename(download.file_path))
    File.open(file_path, "rb") do |file|
      generated_download.file.attach(
        io: file,
        filename: generated_download.filename,
        content_type: download.mime_type
      )
    end
  ensure
    download&.remove
  end

  def attach_csv(generated_download)
    tempfile = Tempfile.new(["generated-download", ".csv"])
    tempfile.binmode
    ExportsHelper.write_csv(tempfile, csv_rows(generated_download))
    tempfile.rewind
    generated_download.file.attach(
      io: tempfile,
      filename: generated_download.filename,
      content_type: "text/csv"
    )
  ensure
    tempfile&.close!
  end

  def csv_rows(generated_download)
    arguments = generated_download.arguments
    case generated_download.kind
    when "tag_wrangler"
      tag_wrangler_rows(arguments.fetch("user_id"))
    when "bulk_user_search"
      bulk_user_search_rows(arguments.fetch("emails"))
    when "challenge_signups"
      challenge_signup_rows(arguments.fetch("collection_id"))
    end
  end

  def tag_wrangler_rows(user_id)
    wrangler = User.find(user_id)
    rows = [["Name", "Last Updated", "Type", "Merger", "Fandoms", "Unwrangleable"]]
    Tag.where(last_wrangler: wrangler)
      .limit(ArchiveConfig.WRANGLING_REPORT_LIMIT)
      .includes(:merger, :parents)
      .find_each(order: :desc) do |tag|
        fandoms = tag.parents
          .filter_map { |parent| parent.name if parent.is_a?(Fandom) }
          .join(", ")
        rows << [tag.name, tag.updated_at, tag.type, tag.merger&.name || "", fandoms, tag.unwrangleable]
      end
    rows
  end

  def bulk_user_search_rows(emails)
    found_users, not_found_emails = User.search_multiple_by_email(emails)
    [%w[Email Username]] +
      found_users.map { |user| [user.email, user.login] } +
      not_found_emails.map { |email| [email, ""] }
  end

  def challenge_signup_rows(collection_id)
    collection = Collection.find(collection_id)
    controller = ChallengeSignupsController.new
    controller.instance_variable_set(:@collection, collection)
    controller.instance_variable_set(:@challenge, collection.challenge)
    controller.define_singleton_method(:collection_signup_url) do |requested_collection, signup|
      Rails.application.routes.url_helpers.collection_signup_url(
        requested_collection,
        signup,
        host: ArchiveConfig.APP_HOST,
        protocol: "https"
      )
    end
    controller.send("#{collection.challenge.class.name.underscore}_to_csv")
  end
end
