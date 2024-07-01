class ReportAttachmentJob < ApplicationJob
  def perform(ticket_id, work)
    download = Download.new(work, mime_type: "text/html")
    html = DownloadWriter.new(download).generate_html
    reporter.send_attachment!(ticket_id, html)
  end
end
