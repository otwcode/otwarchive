class ReportAttachmentJob < ApplicationJob
  def perform(ticket_id, work)
    download = Download.new(work, mime_type: "text/html").generate
    reporter.send_attachment!(ticket_id, download)
  end
end
