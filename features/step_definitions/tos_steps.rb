Given "the terms of service prompt is enabled" do
  allow_any_instance_of(ApplicationHelper).to receive(:tos_exempt_page?).and_return(false)
end
