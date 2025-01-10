# frozen_string_literal: true

Given "Zoho ticket creation is enabled" do
  allow_any_instance_of(Feedback).to receive(:zoho_enabled?).and_return(true)
  WebMock.stub_request(:get, %r{/contacts/search})
    .to_return(headers: { content_type: "application/json" }, body: '{"data":[{"id":"1"}]}')
  WebMock.stub_request(:post, %r{/tickets})
    .to_return(headers: { content_type: "application/json" }, body: '{"id":"3"}')
end

Given "{string} is a permitted Archive host" do |host|
  allow(ArchiveConfig).to receive(:PERMITTED_HOSTS).and_return([host])
end

Then "a Zoho ticket should be created with referer {string}" do |referer|
  # rubocop:disable Lint/AmbiguousBlockAssociation
  expect(WebMock).to have_requested(:post, "https://desk.zoho.com/api/v1/tickets")
    .with { |req| JSON.parse(req.body)["cf"]["cf_url"] == referer }
  # rubocop:enable Lint/AmbiguousBlockAssociation
end
