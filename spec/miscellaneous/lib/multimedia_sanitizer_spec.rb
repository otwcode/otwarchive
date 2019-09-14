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
      it "removes unwhitelisted attributes" do
        html = %q{
          <video>
            <source onerror="alert(1)">
          </video>}
        content = Sanitize.fragment(html, config)
        expect(content).to match("source")
        expect(content).not_to match("onerror")
        expect(content).not_to match("alert")
      end
      it "removes javascript from poster attribute" do
        html = %q{
          <video poster=javascript:alert(1)>
          </video>}
        content = Sanitize.fragment(html, config)
        expect(content).not_to match("poster")
        expect(content).not_to match("javascript")
      end

      context "given a blacklisted source" do
        before do
          ArchiveConfig.BLACKLISTED_SRCS = ['google.com']
        end
        after do
          ArchiveConfig.BLACKLISTED_SRCS = []
        end

        it "strips the source element" do
          html = %q{
            <video controls width="250">
              <source src="https://google.com/flower.mp4" type="video/mp4">
            </video>}
          content = Sanitize.fragment(html, config)
          expect(content).not_to match("source")
          expect(content).not_to match("flower.mp4")
        end
        it "strips the video element" do
          html = %q{
            <video src="http://google.com/flower.mp4">
            </video>}
          content = Sanitize.fragment(html, config)
          expect(content).not_to match("video")
          expect(content).not_to match("flower.mp4")
        end
        it "strips the audio element" do
          html = %q{
            <audio src="google.com/tune.mp3">
            </audio>}
          content = Sanitize.fragment(html, config)
          expect(content).not_to match("audio")
          expect(content).not_to match("tune.mp3")
        end
      end
    end
  end
end
