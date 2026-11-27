# frozen_string_literal: true

# Use in request specs: controller specs don't store the session in a cookie.
shared_examples "an action whose flash fits in the session cookie" do
  it "doesn't overflow the session cookie" do
    make_request

    expect(response).to have_http_status(:redirect)
    expect(flash.to_hash.values.join(" ")).to include(expected_flash_text)
  end
end
