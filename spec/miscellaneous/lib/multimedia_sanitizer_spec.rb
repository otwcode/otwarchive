require 'spec_helper'

describe OTWSanitize::Multimedia do
  describe ".transformer" do
    it "returns a callable object" do
      transform = OTWSanitize::Multimedia.transformer
      expect(transform).to respond_to(:call)
    end

    context "when sanitizing" do
      let(:config) do
        Sanitize::Config.merge(
          Sanitize::Config::BASIC,
          transformers: [
            OTWSanitize::Multimedia.transformer
          ]
        )
      end
      it "allows audio elements" do
        html = "<audio></audio>"
        content = Sanitize.fragment(html, config)
        expect(content).to match(/audio/)
      end
      it "allows video elements" do
        html = "<video></video>"
        content = Sanitize.fragment(html, config)
        expect(content).to match(/video/)
      end
      it "adds video defaults" do
        html = "<video></video>"
        content = Sanitize.fragment(html, config)
        expect(content).to match("controls=\"controls\"")
        expect(content).to match("crossorigin=\"anonymous\"")
        expect(content).to match("preload=\"metadata\"")
        expect(content).to match("playsinline=\"playsinline\"")
      end
      it "adds audio defaults" do
        html = "<audio></audio>"
        content = Sanitize.fragment(html, config)
        expect(content).to match("controls=\"controls\"")
        expect(content).to match("crossorigin=\"anonymous\"")
        expect(content).to match("preload=\"metadata\"")
        expect(content).to match("controls=\"controls\"")
      end
      it "allows source elements" do
        html = %q{
          <video controls width="250">
            <source src="example.com/flower.webm" type="video/webm">
            <source src="example.com/flower.mp4" type="video/mp4">
            Sorry, your browser doesn't support embedded videos.
          </video>}
        content = Sanitize.fragment(html, config)
        expect(content).to match("flower.webm")
      end
    end
  end
end
