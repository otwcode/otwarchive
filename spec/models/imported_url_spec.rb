require "spec_helper"

describe ImportedUrl do
  let(:url) { ImportedUrl.new }

  it "sets formatted urls on save" do
    formatter = UrlFormatter.new("http://www.trickster.org/llwyden/misc/cracked.html")
    url.original = formatter.original
    url.save

    expect(url.minimal).to eq("http://www.trickster.org/llwyden/misc/cracked.html")
    expect(url.minimal_no_protocol_no_www).to eq("trickster.org/llwyden/misc/cracked.html")
    expect(url.no_www).to eq("http://trickster.org/llwyden/misc/cracked.html")
    expect(url.with_www).to eq("http://www.www.trickster.org/llwyden/misc/cracked.html")
    expect(url.with_http).to eq("http://www.trickster.org/llwyden/misc/cracked.html")
    expect(url.with_https).to eq("https://www.trickster.org/llwyden/misc/cracked.html")
    expect(url.encoded).to eq("http://www.trickster.org/llwyden/misc/cracked.html")
    expect(url.decoded).to eq("http://www.trickster.org/llwyden/misc/cracked.html")
  end

  it "handles longer urls where the encoded column will be much larger gracefully" do
    # default string column max is 255 so we create an url with exactly 255 chars
    # and encoding that will extend the
    repeated_string = "#() {}" * 38
    long_url = "http://www.faikes.org/#{repeated_string}.html"

    formatter = UrlFormatter.new(long_url)
    url.original = formatter.original

    expect { url.save }
      .not_to raise_error
  end
end
