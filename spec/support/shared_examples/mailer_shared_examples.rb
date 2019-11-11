shared_examples_for "multipart email" do
  it "generates a multipart message (plain text and html)" do
    expect(email.body.parts.length).to eq(2)
    expect(email.body.parts.collect(&:content_type)).to eq(["text/plain; charset=UTF-8", "text/html; charset=UTF-8"])
  end
end

shared_examples_for "a translated email" do
  it "does not have missing translations in HTML version" do
    expect(get_message_part(email, /html/)).not_to include("translation missing")
  end

  it "does not have missing translations in text version" do
    expect(get_message_part(email, /plain/)).not_to include("translation missing")
  end
end

shared_examples_for "an email with a valid sender" do
  it "is delivered from Archive of Our Own <do-not-reply@example.org>" do
    expect(email).to deliver_from("Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>")
  end
end

shared_examples_for "a well formed HTML email" do
  it "does not have exposed HTML" do
    expect(get_message_part(email, /html/)).not_to include("&lt;")
  end
end
