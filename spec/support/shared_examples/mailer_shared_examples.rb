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

shared_examples_for "an added_to_collection_notification email" do |linked_user_collection_items_page|
  it_behaves_like "an email with a valid sender"
  it_behaves_like "an added_to_collection_notification with the correct subject line"
  it_behaves_like "a multipart email"
  it_behaves_like "a translated email"
  it_behaves_like "an added_to_collection_notification with the correct content", linked_user_collection_items_page
end

shared_examples_for "an added_to_collection_notification with the correct subject line" do
  it "has the correct subject line" do
    subject = "[#{ArchiveConfig.APP_SHORT_NAME}][#{collection.title}] Your work was added to a collection"
    expect(email).to have_subject(subject)
  end
end

shared_examples_for "an added_to_collection_notification with the correct content" do |linked_user_collection_items_page|
  it "has the correct content in HTML version" do
    expect(email).to have_html_part_content(">#{collection.title}</a> have added your work <")
    expect(email).to have_html_part_content("previously elected to allow automatic inclusion")
    expect(email).to have_html_part_content("#{linked_user_collection_items_page} page")
  end

  it "has the correct content in text version" do
    expect(email).to have_text_part_content("#{collection.title} have added your work (#{work.title})")
    expect(email).to have_text_part_content("previously elected to allow automatic inclusion")
    expect(email).to have_text_part_content("#{linked_user_collection_items_page} page")
  end
end
