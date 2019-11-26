RSpec::Matchers.define :have_html_body_text do |expected_html_body_text|
  match do |email|
    expect(email.html_part.decoded).to include(expected_html_body_text)
  end

  failure_message do |email|
    "expected #{email.html_part.decoded} to include #{expected_html_body_text}."
  end
end
