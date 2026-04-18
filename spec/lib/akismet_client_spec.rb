require "spec_helper"

describe AkismetClient do
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

  context "with a valid api key" do
    before(:all) do
      skip "Missing valid Akismet API key" unless AkismetClient.valid_key?
    end
    
    ham_attributes = { user_ip: "127.0.0.1", user_role: "administrator" }
    spam_attributes = { user_ip: "127.0.0.1", comment_author: "akismet-guaranteed-spam" }

    before do
      allow(AkismetClient).to receive(:spam_submission_enabled?).and_return(true)
      allow(AkismetClient).to receive(:enabled?).and_return(true)
    end

    describe "#spam?" do
      context "for guaranteed spam" do
        it "returns true" do
          expect(AkismetClient.spam?(spam_attributes)).to be_truthy
        end
      end

      context "for guaranteed ham" do
        it "returns false" do
          expect(AkismetClient.spam?(ham_attributes)).to be_falsy
        end
      end
    end

    describe "#submit_spam" do
      it "accepts spam" do
        expect(AkismetClient.submit_spam(spam_attributes)).to be_truthy
      end
    end

    describe "#submit_ham" do
      it "accepts ham" do
        expect(AkismetClient.submit_ham(ham_attributes)).to be_truthy
      end
    end
  end

  context "when akismet disabled" do
    before do
      allow(AkismetClient).to receive(:enabled?).and_return(false)
      allow(AkismetClient).to receive(:spam_submission_enabled?).and_return(false)
    end

    comment_attributes = { user_ip: "127.0.0.1", comment_author: "akismet-guaranteed-spam" }

    describe "#spam?" do
      it "returns false" do
        expect(AkismetClient).not_to receive(:encode_body)
        expect(AkismetClient.spam?(comment_attributes)).to be_falsy
      end
    end

    describe "#submit_spam" do
      it "accepts spam" do
        expect(AkismetClient).not_to receive(:encode_body)
        expect(AkismetClient.submit_spam(comment_attributes)).to be_truthy
      end
    end

    describe "#submit_ham" do
      it "accepts ham" do
        expect(AkismetClient).not_to receive(:encode_body)
        expect(AkismetClient.submit_ham(comment_attributes)).to be_truthy
      end
    end
  end
end
