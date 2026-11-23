# frozen_string_literal: true

# Needs a request spec, since only the full middleware stack stores the session
# in a cookie, and a `make_request` that performs the request. An overflow
# raises ActionDispatch::Cookies::CookieOverflow, which fails the example.
shared_examples "a bulk action that fits in the session cookie" do
  it "doesn't overflow the session cookie" do
    make_request

    expect(response).to have_http_status(:redirect)
  end
end
