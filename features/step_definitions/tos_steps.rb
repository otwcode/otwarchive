Given "the terms of service prompt is enabled" do
  allow(ApplicationHelper).to receive(:tos_exempt_page?).and_call_original
end
