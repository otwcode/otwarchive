# frozen_string_literal: true

require "spec_helper"

describe ReportAttachmentJob do
  let(:work) { build(:work) }
  let(:writer_mock) { instance_double(DownloadWriter) }
  let(:reporter) { instance_double(FeedbackReporter) }

  before do
    download_mock = instance_double(Download)
    allow(Download).to receive(:new).with(work, { mime_type: "text/html" }).and_return(download_mock)
    allow(download_mock).to receive(:file_name).and_return("filename")
    allow(DownloadWriter).to receive(:new).with(download_mock).and_return(writer_mock)
    allow(writer_mock).to receive(:generate_html)
    allow(FeedbackReporter).to receive(:new).and_return(reporter)
    allow(reporter).to receive(:send_attachment!)
  end

  it "attaches a download of the given work" do
    ReportAttachmentJob.perform_now(0, work)
    expect(writer_mock).to have_received(:generate_html)
    expect(reporter).to have_received(:send_attachment!)
  end
end
