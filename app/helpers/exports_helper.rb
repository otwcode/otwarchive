# frozen_string_literal: true

module ExportsHelper
  def queue_csv_download(kind:, arguments:, filename:)
    generated_download = GeneratedDownload.create!(
      kind: kind,
      arguments: arguments,
      filename: filename
    )
    GeneratedDownloadJob.perform_later(generated_download)
    redirect_to generated_download_path(token: generated_download.token), status: :see_other
  end

  # Tab-separated CSV with utf-16le encoding (unicode) and byte order
  # mark. This seems to be the only variant Excel can get
  # automatically into proper table format. OpenOffice handles it
  # well, too.
  def export_csv(content_array)
    io = StringIO.new("".b)
    ExportsHelper.write_csv(io, content_array)
    io.string.force_encoding("utf-16le")
  end

  def self.write_csv(io, rows)
    io.write("\uFEFF".encode("utf-16le"))
    rows.each do |row|
      encoded_row = row.to_csv(col_sep: "\t", encoding: "utf-8").encode(
        "utf-16le", "utf-8", invalid: :replace, undef: :replace, replace: ""
      )
      io.write(encoded_row)
    end
  end
end
