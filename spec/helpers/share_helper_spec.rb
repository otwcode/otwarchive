require "spec_helper"

describe ShareHelper do
  before do
    # The admin check is defined in ApplicationController
    # and is unavailable for helper specs.
    allow(helper).to receive(:logged_in_as_admin?).and_return(false)

    # Stub a Devise helper for creator checks
    allow(helper).to receive(:current_user)
  end

  describe "#get_tumblr_embed_link_title" do
    context "on anonymous works" do
      let(:work) { build_stubbed(:work, in_anon_collection: true) }

      it "does not link to a user's profile" do
        expect(helper.get_tumblr_embed_link_title(work)).to include("by Anonymous")
      end
    end
  end

  describe "#get_tweet_text" do
    context "on unrevealed works" do
      let(:work) { build_stubbed(:work, in_unrevealed_collection: true) }

      it "returns 'Mystery Work'" do
        expect(helper.get_tweet_text(work)).to eq("Mystery Work")
      end
    end

    context "on anonymous works" do
      let(:work) { build_stubbed(:work, in_anon_collection: true) }

      it "lists the creator as 'Anonymous'" do
        expect(helper.get_tweet_text(work)).to include "by Anonymous"
      end
    end

    context "when work has three or more fandoms" do
      let(:work) { create(:work, fandom_string: "saiki k, mob psycho 100, spy x family") }

      it "lists the fandom as 'Multifandom'" do
        expect(helper.get_tweet_text(work)).to include " - Multifandom"
        expect(helper.get_tweet_text(work)).not_to include "saiki k"
      end
    end

    context "when work is revealed, non-anonymous, and has one fandom" do
      let(:work) { create(:work, title: "the coffee shop at the end of the universe") }

      it "includes all info" do
        text = "the coffee shop at the end of the universe by #{work.pseuds.first.byline} - Testing"
        expect(helper.get_tweet_text(work)).to eq(text)
      end
    end
  end

  describe "#get_tweet_text_for_bookmark" do
    context "on bookmarked works" do
      let(:work) { create(:work, title: "MAMA 2020", fandom_string: "K/DA") }
      let(:bookmark) { build_stubbed(:bookmark, bookmarkable: work) }

      it "returns a formatted tweet" do
        text = "Bookmark of MAMA 2020 by #{work.pseuds.first.byline} - K/DA".truncate(83)
        expect(helper.get_tweet_text_for_bookmark(bookmark)).to eq(text)
      end
    end
  end

  describe "#sharing_button" do
    context "with invalid site" do
      it "returns nil" do
        expect(helper.sharing_button("facebook", "https://facebook.com", "Facebook")).to be_nil
      end
    end

    context "with valid site" do
      context "when site is bluesky" do
        it "returns HTML for a Bluesky button" do
          share_button = '<a href="https://bsky.app" class="resp-sharing-button__link" aria-label="Follow us on Bluesky"><div class="resp-sharing-button resp-sharing-button--bluesky resp-sharing-button--medium"><div class="resp-sharing-button__icon resp-sharing-button__icon--solid" aria-hidden="true"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12 10.8c-1.087 -2.114 -4.046 -6.053 -6.798 -7.995C2.566 0.944 1.561 1.266 0.902 1.565 0.139 1.908 0 3.08 0 3.768c0 0.69 0.378 5.65 0.624 6.479 0.815 2.736 3.713 3.66 6.383 3.364 0.136 -0.02 0.275 -0.039 0.415 -0.056 -0.138 0.022 -0.276 0.04 -0.415 0.056 -3.912 0.58 -7.387 2.005 -2.83 7.078 5.013 5.19 6.87 -1.113 7.823 -4.308 0.953 3.195 2.05 9.271 7.733 4.308 4.267 -4.308 1.172 -6.498 -2.74 -7.078a8.741 8.741 0 0 1 -0.415 -0.056c0.14 0.017 0.279 0.036 0.415 0.056 2.67 0.297 5.568 -0.628 6.383 -3.364 0.246 -0.828 0.624 -5.79 0.624 -6.478 0 -0.69 -0.139 -1.861 -0.902 -2.206 -0.659 -0.298 -1.664 -0.62 -4.3 1.24C16.046 4.748 13.087 8.687 12 10.8Z" /></svg></div>Follow us on Bluesky</div></a>'
          expect(helper.sharing_button("bluesky", "https://bsky.app", "Follow us on Bluesky")).to eq(share_button)
        end
      end

      context "when site is tumblr" do
        it "returns HTML for a Tumblr button" do
          share_button = '<a href="https://tumblr.com" class="resp-sharing-button__link" aria-label="Share on Tumblr"><div class="resp-sharing-button resp-sharing-button--tumblr resp-sharing-button--medium"><div class="resp-sharing-button__icon resp-sharing-button__icon--solid" aria-hidden="true"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M13.5.5v5h5v4h-5V15c0 5 3.5 4.4 6 2.8v4.4c-6.7 3.2-12 0-12-4.2V9.5h-3V6.7c1-.3 2.2-.7 3-1.3.5-.5 1-1.2 1.4-2 .3-.7.6-1.7.7-3h3.8z" /></svg></div>Share on Tumblr</div></a>'
          expect(helper.sharing_button("tumblr", "https://tumblr.com", "Share on Tumblr")).to eq(share_button)
        end
      end

      context "when site is twitter" do
        it "returns HTML for a Twitter button" do
          share_button = '<a href="https://twitter.com" class="resp-sharing-button__link" aria-label="Share on Twitter"><div class="resp-sharing-button resp-sharing-button--twitter resp-sharing-button--medium"><div class="resp-sharing-button__icon resp-sharing-button__icon--solid" aria-hidden="true"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.44 4.83c-.8.37-1.5.38-2.22.02.93-.56.98-.96 1.32-2.02-.88.52-1.86.9-2.9 1.1-.82-.88-2-1.43-3.3-1.43-2.5 0-4.55 2.04-4.55 4.54 0 .36.03.7.1 1.04-3.77-.2-7.12-2-9.36-4.75-.4.67-.6 1.45-.6 2.3 0 1.56.8 2.95 2 3.77-.74-.03-1.44-.23-2.05-.57v.06c0 2.2 1.56 4.03 3.64 4.44-.67.2-1.37.2-2.06.08.58 1.8 2.26 3.12 4.25 3.16C5.78 18.1 3.37 18.74 1 18.46c2 1.3 4.4 2.04 6.97 2.04 8.35 0 12.92-6.92 12.92-12.93 0-.2 0-.4-.02-.6.9-.63 1.96-1.22 2.56-2.14z" /></svg></div>Share on Twitter</div></a>'
          expect(helper.sharing_button("twitter", "https://twitter.com", "Share on Twitter")).to eq(share_button)
        end
      end
    end

    context "with target argument" do
      it "returns button with target attribute for link" do
        share_button = '<a href="https://twitter.com" target="_blank" class="resp-sharing-button__link" aria-label="Share on Twitter"><div class="resp-sharing-button resp-sharing-button--twitter resp-sharing-button--medium"><div class="resp-sharing-button__icon resp-sharing-button__icon--solid" aria-hidden="true"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.44 4.83c-.8.37-1.5.38-2.22.02.93-.56.98-.96 1.32-2.02-.88.52-1.86.9-2.9 1.1-.82-.88-2-1.43-3.3-1.43-2.5 0-4.55 2.04-4.55 4.54 0 .36.03.7.1 1.04-3.77-.2-7.12-2-9.36-4.75-.4.67-.6 1.45-.6 2.3 0 1.56.8 2.95 2 3.77-.74-.03-1.44-.23-2.05-.57v.06c0 2.2 1.56 4.03 3.64 4.44-.67.2-1.37.2-2.06.08.58 1.8 2.26 3.12 4.25 3.16C5.78 18.1 3.37 18.74 1 18.46c2 1.3 4.4 2.04 6.97 2.04 8.35 0 12.92-6.92 12.92-12.93 0-.2 0-.4-.02-.6.9-.63 1.96-1.22 2.56-2.14z" /></svg></div>Share on Twitter</div></a>'
        expect(helper.sharing_button("twitter", "https://twitter.com", "Share on Twitter", target: "_blank")).to eq(share_button)
      end
    end
  end
end
