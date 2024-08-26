class ReportAttachmentJob < ApplicationJob
  def perform(ticket_id, work)
    download = Download.new(work, mime_type: "text/html")
    html = DownloadWriter.new(download).generate_html
    FeedbackReporter.new.send_attachment!(ticket_id, "#{download.file_name}.html", html)
  end
end
