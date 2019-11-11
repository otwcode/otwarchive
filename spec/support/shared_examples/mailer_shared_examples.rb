shared_examples_for "multipart email" do
  it "generates a multipart message (plain text and html)" do
    expect(email.body.parts.length).to eq(2)
    expect(email.body.parts.collect(&:content_type)).to eq(["text/plain; charset=UTF-8", "text/html; charset=UTF-8"])
  end
end

shared_examples_for "a translated email" do
  it "does not have missing translations in HTML version" do
    expect(email.html_part).not_to have_body_text("translation missing")
  end

  it "does not have missing translations in text version" do
    expect(email.text_part).not_to have_body_text("translation missing")
  end
end

shared_examples_for "an email with a valid sender" do
  it "is delivered from Archive of Our Own <do-not-reply@example.org>" do
    expect(email).to deliver_from("Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>")
  end
end

shared_examples_for "a well formed HTML email" do
  it "does not have exposed HTML" do
    expect(email.html_part).not_to have_body_text("&lt;")
  end
end
