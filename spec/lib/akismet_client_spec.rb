require "spec_helper"

describe AkismetClient do
  before do
    WebMock.disable_net_connect!
  end

  after do
    WebMock.allow_net_connect!
  end

  describe "#enabled?" do
    before do
      allow(AkismetClient).to receive(:enabled?).and_call_original
    end

    context "when AKISMET_KEY is unset" do
      before do
        allow(ArchiveConfig).to receive(:AKISMET_KEY).and_return("")
      end

      it "returns false" do
        expect(AkismetClient.enabled?).to be_falsy
      end
    end
    
    context "when AKISMET_NAME is unset" do
      before do
        allow(ArchiveConfig).to receive(:AKISMET_NAME).and_return("")
      end

      it "returns false" do
        expect(AkismetClient.enabled?).to be_falsy
      end
    end

    context "when AKISMET_KEY and AKISMET_NAME are set" do
      before do
        allow(ArchiveConfig).to receive(:AKISMET_KEY).and_return("1234ab5678cd")
        allow(ArchiveConfig).to receive(:AKISMET_NAME).and_return("http://transformativeworks.org")
      end

      it "returns true" do
        expect(AkismetClient.enabled?).to be_truthy
      end
    end
  end

  context "when spam checking is enabled" do
    comment_attributes = {
      comment_type: "fanwork-comment",
      user_ip: "127.0.0.1",
      user_agent: "Mozilla/5.0 (X11; Linux x86_64; rv:149.0) Gecko/20100101 Firefox/149.0",
      comment_author_email: "nobody@example.com",
      comment_content: "Oh, wow!"
    }

    before do
      allow(ArchiveConfig).to receive(:AKISMET_NAME).and_return("http://transformativeworks.org")
      allow(ArchiveConfig).to receive(:AKISMET_KEY).and_return("679f25dc720c")
      allow(AkismetClient).to receive(:enabled?).and_call_original
      allow(AkismetClient).to receive(:spam_submission_enabled?).and_return(true)
    end

    describe "#spam?" do
      let!(:stub) { WebMock.stub_request(:post, "https://rest.akismet.com/1.1/comment-check") }
      
      it "encodes the attributes" do
        expect(AkismetClient.spam?(comment_attributes)).to be_falsey
        
        expect(WebMock).to have_requested(:post, "https://rest.akismet.com/1.1/comment-check")
          .with(
            body: hash_including(comment_attributes.merge(blog: "http://transformativeworks.org", key: "679f25dc720c")),
            headers: { "Content-Type": "application/x-www-form-urlencoded" }
          )
      end
      
      context "for spam" do
        let!(:stub) { super().to_return(body: "true") }

        it "returns true" do
          expect(AkismetClient.spam?(comment_attributes)).to be_truthy
          expect(stub).to have_been_requested
        end
      end

      context "for ham" do
        let!(:stub) { super().to_return(body: "false") }

        it "returns false" do
          expect(AkismetClient.spam?(comment_attributes)).to be_falsy
          expect(stub).to have_been_requested
        end
      end
    end

    describe "#submit_spam" do
      let!(:stub) do
        WebMock.stub_request(:post, "https://rest.akismet.com/1.1/submit-spam")
          .to_return(body: "Thanks for making the web a better place.")
      end

      it "accepts spam" do
        expect(AkismetClient.submit_spam(comment_attributes)).to be_truthy
        expect(stub).to have_been_requested
      end
    end

    describe "#submit_ham" do
      let!(:stub) do
        WebMock.stub_request(:post, "https://rest.akismet.com/1.1/submit-ham")
          .to_return(body: "Thanks for making the web a better place.")
      end

      it "accepts ham" do
        expect(AkismetClient.submit_ham(comment_attributes)).to be_truthy
        expect(stub).to have_been_requested
      end
    end
  end

  context "when spam checking is disabled" do
    before do
      allow(AkismetClient).to receive(:enabled?).and_return(false)
      allow(AkismetClient).to receive(:spam_submission_enabled?).and_return(false)
    end

    comment_attributes = { user_ip: "127.0.0.1", comment_author: "akismet-guaranteed-spam" }

    describe "#spam?" do
      it "returns false" do
        expect(AkismetClient).not_to receive(:encode_body)
        expect(AkismetClient.spam?(comment_attributes)).to be_falsy
        expect(WebMock).not_to have_requested(:post, "rest.akismet.com")
      end
    end

    describe "#submit_spam" do
      it "accepts spam" do
        expect(AkismetClient).not_to receive(:encode_body)
        expect(AkismetClient.submit_spam(comment_attributes)).to be_truthy
        expect(WebMock).not_to have_requested(:post, "rest.akismet.com")
      end
    end

    describe "#submit_ham" do
      it "accepts ham" do
        expect(AkismetClient).not_to receive(:encode_body)
        expect(AkismetClient.submit_ham(comment_attributes)).to be_truthy
        expect(WebMock).not_to have_requested(:post, "rest.akismet.com")
      end
    end
  end
end
