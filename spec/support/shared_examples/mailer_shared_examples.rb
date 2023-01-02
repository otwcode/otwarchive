shared_examples_for "a multipart email" do
  it "generates a multipart message (plain text and html)" do
    expect(email.body.parts.length).to eq(2)
    expect(email.body.parts.map(&:content_type)).to eq(["text/plain; charset=UTF-8", "text/html; charset=UTF-8"])
  end

  it "does not have exposed HTML" do
    expect(email).not_to have_html_part_content("&lt;")
  end
end

shared_examples_for "a translated email" do
  it "does not have missing translations in HTML version" do
    expect(email).not_to have_html_part_content("translation missing")
  end

  it "does not have missing translations in text version" do
    expect(email).not_to have_text_part_content("translation missing")
  end
end

shared_examples_for "an email with a valid sender" do
  it "is delivered from Archive of Our Own <do-not-reply@example.org>" do
    expect(email).to deliver_from("Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>")
  end
end

shared_examples_for "an unsent email" do
  it "is not delivered" do
    expect(email.message).to be_a(ActionMailer::Base::NullMail)
  end
end

shared_examples "it retries and fails on" do |error|
  it "retries 3 times and ultimately fails with a #{error}" do
    assert_performed_jobs 3, only: ApplicationMailerJob do
      expect { subject.deliver_later }.to raise_exception(error)
    end
  end
end

shared_examples "an email with a deleted work attached" do
  it "has html and txt attachments" do
    expect(email.attachments.length).to eq(2)
    expect(email.attachments).to contain_exactly(
      an_object_having_attributes(filename: "#{work.title}.html"),
      an_object_having_attributes(filename: "#{work.title}.txt")
    )
  end

  it "includes draft chapters in attachments" do
    download = Download.new(work, mime_type: "text/html", include_draft_chapters: true)
    html = DownloadWriter.new(download).generate_html
    encoded_html = ::Mail::Encodings::Base64.encode(html)
    expect(email.attachments["#{work.title}.html"].body.raw_source).to eq(encoded_html)
    expect(email.attachments["#{work.title}.txt"].body.raw_source).to eq(encoded_html)
  end
end
