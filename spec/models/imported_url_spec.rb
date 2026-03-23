require "spec_helper"

describe ImportedUrl do
  it "sets formatted urls on save" do
    let(:url) { ImportedUrl.new }
    formatter = UrlFormatter.new("http://www.trickster.org/llwyden/misc/cracked.html")
    url.original = formatter.original
    url.save

    expect(url.minimal).to eq(formatter.minimal)
    expect(url.minimal_no_protocol_no_www).to eq(formatter.minimal_no_protocol_no_www)
    expect(url.no_www).to eq(formatter.no_www)
    expect(url.with_www).to eq(formatter.with_www)
    expect(url.with_http).to eq(formatter.with_http)
    expect(url.with_https).to eq(formatter.with_https)
    expect(url.encoded).to eq(formatter.encoded)
    expect(url.decoded).to eq(formatter.decoded)
  end
end