require 'spec_helper'
require 'webmock/rspec'

module ApiHelper

  # set up a valid token and some headers
  def valid_headers
    api = ApiKey.first_or_create!(name: "Test", access_token: "testabc")
    {
      "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Token.encode_credentials(api.access_token),
      "HTTP_ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json"
    }
  end

  # Values in API fake content
  def content_fields
    {
      title: "Foo Title", summary: "Foo summary", fandoms: "Foo Fandom", warnings: "Underage",
      characters: "foo 1, foo 2", rating: "Explicit", relationships: "foo 1/foo 2",
      categories: "F/F", freeform: "foo tag 1, foo tag 2", external_author_name: "bar",
      external_author_email: "bar@foo.com", notes: "This is a <i>content note</i>."
    }
  end

  def api_fields
    {
      title: "Bar Title", summary: "Bar summary", fandoms: "Bar Fandom", warnings: "Rape/Non-Con",
      characters: "bar 1, bar 2", rating: "General", relationships: "bar 1/bar 2",
      categories: "M/M", freeform: "bar tag 1, bar tag 2", external_author_name: "bar",
      external_author_email: "bar@foo.com", notes: "This is an <i>API note</i>."
    }
  end

  # Let the test get at external sites, but stub out anything containing certain keywords
  def mock_external
    WebMock.allow_net_connect!
    WebMock.stub_request(:any, /foo/).
      to_return(status: 200,
                body:
                  "Title: #{content_fields[:title]}
Summary:  #{content_fields[:summary]}
Fandom:  #{content_fields[:fandoms]}
Rating: #{content_fields[:rating]}
Warnings:  #{content_fields[:warnings]}
Characters:  #{content_fields[:characters]}
Pairings:  #{content_fields[:relationships]}
Category:  #{content_fields[:categories]}
Tags:  #{content_fields[:freeform]}
Author's notes:  #{content_fields[:notes]}

stubbed response", headers: {})

    WebMock.stub_request(:any, /no-metadata/).
      to_return(status: 200,
                body: "stubbed response",
                headers: {})

    WebMock.stub_request(:any, /no-content/).
      to_return(status: 200,
                body: "",
                headers: {})

    WebMock.stub_request(:any, /bar/).
      to_return(status: 404, headers: {})
  end
end
