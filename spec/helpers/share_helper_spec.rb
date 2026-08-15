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
          share_button = '<a href="https://bsky.app" class="resp-sharing-button__link" aria-label="Follow us on Bluesky"><div class="resp-sharing-button resp-sharing-button--bluesky resp-sharing-button--medium"><div class="resp-sharing-button__icon resp-sharing-button__icon--solid" aria-hidden="true"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><!--!Font Awesome Free v7.0.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path d="M439.8 358.7C436.5 358.3 433.1 357.9 429.8 357.4C433.2 357.8 436.5 358.3 439.8 358.7zM320 291.1C293.9 240.4 222.9 145.9 156.9 99.3C93.6 54.6 69.5 62.3 53.6 69.5C35.3 77.8 32 105.9 32 122.4C32 138.9 41.1 258 47 277.9C66.5 343.6 136.1 365.8 200.2 358.6C203.5 358.1 206.8 357.7 210.2 357.2C206.9 357.7 203.6 358.2 200.2 358.6C106.3 372.6 22.9 406.8 132.3 528.5C252.6 653.1 297.1 501.8 320 425.1C342.9 501.8 369.2 647.6 505.6 528.5C608 425.1 533.7 372.5 439.8 358.6C436.5 358.2 433.1 357.8 429.8 357.3C433.2 357.7 436.5 358.2 439.8 358.6C503.9 365.7 573.4 343.5 593 277.9C598.9 258 608 139 608 122.4C608 105.8 604.7 77.7 586.4 69.5C570.6 62.4 546.4 54.6 483.2 99.3C417.1 145.9 346.1 240.4 320 291.1z" /></svg></div>Follow us on Bluesky</div></a>'
          expect(helper.sharing_button("bluesky", "https://bsky.app", "Follow us on Bluesky")).to eq(share_button)
        end
      end

      context "when site is tumblr" do
        it "returns HTML for a Tumblr button" do
          share_button = '<a href="https://tumblr.com" class="resp-sharing-button__link" aria-label="Share on Tumblr"><div class="resp-sharing-button resp-sharing-button--tumblr resp-sharing-button--medium"><div class="resp-sharing-button__icon resp-sharing-button__icon--solid" aria-hidden="true"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><!--!Font Awesome Free v7.0.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path d="M469.9 544.3C456.3 558.8 419.9 576 372.5 576C251.7 576 225.5 487.2 225.5 435.4L225.5 291.4L178 291.4C172.5 291.4 168 286.9 168 281.4L168 213.4C168 206.2 172.5 199.8 179.3 197.4C241.3 175.6 260.8 121.4 263.6 80.3C264.4 69.3 270.1 64 279.7 64L350.6 64C356.1 64 360.6 68.5 360.6 74L360.6 189.2L443.6 189.2C449.1 189.2 453.6 193.6 453.6 199.1L453.6 280.8C453.6 286.3 449.1 290.8 443.6 290.8L360.2 290.8L360.2 424C360.2 458.2 383.9 477.6 428.2 459.8C433 457.9 437.2 456.6 440.9 457.6C444.4 458.5 446.7 461 448.3 465.5L470.3 529.8C472.1 534.8 473.6 540.4 469.9 544.3z" /></svg></div>Share on Tumblr</div></a>'
          expect(helper.sharing_button("tumblr", "https://tumblr.com", "Share on Tumblr")).to eq(share_button)
        end
      end

      context "when site is twitter" do
        it "returns HTML for a Twitter button" do
          share_button = '<a href="https://twitter.com" class="resp-sharing-button__link" aria-label="Share on Twitter"><div class="resp-sharing-button resp-sharing-button--twitter resp-sharing-button--medium"><div class="resp-sharing-button__icon resp-sharing-button__icon--solid" aria-hidden="true"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><!--!Font Awesome Free v7.0.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path d="M523.4 215.7C523.7 220.2 523.7 224.8 523.7 229.3C523.7 368 418.1 527.9 225.1 527.9C165.6 527.9 110.4 510.7 64 480.8C72.4 481.8 80.6 482.1 89.3 482.1C138.4 482.1 183.5 465.5 219.6 437.3C173.5 436.3 134.8 406.1 121.5 364.5C128 365.5 134.5 366.1 141.3 366.1C150.7 366.1 160.1 364.8 168.9 362.5C120.8 352.8 84.8 310.5 84.8 259.5L84.8 258.2C98.8 266 115 270.9 132.2 271.5C103.9 252.7 85.4 220.5 85.4 184.1C85.4 164.6 90.6 146.7 99.7 131.1C151.4 194.8 229 236.4 316.1 240.9C314.5 233.1 313.5 225 313.5 216.9C313.5 159.1 360.3 112 418.4 112C448.6 112 475.9 124.7 495.1 145.1C518.8 140.6 541.6 131.8 561.7 119.8C553.9 144.2 537.3 164.6 515.6 177.6C536.7 175.3 557.2 169.5 576 161.4C561.7 182.2 543.8 200.7 523.4 215.7z" /></svg></div>Share on Twitter</div></a>'
          expect(helper.sharing_button("twitter", "https://twitter.com", "Share on Twitter")).to eq(share_button)
        end
      end
    end

    context "with target argument" do
      it "returns button with target attribute for link" do
        share_button = '<a href="https://twitter.com" target="_blank" class="resp-sharing-button__link" aria-label="Share on Twitter"><div class="resp-sharing-button resp-sharing-button--twitter resp-sharing-button--medium"><div class="resp-sharing-button__icon resp-sharing-button__icon--solid" aria-hidden="true"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><!--!Font Awesome Free v7.0.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path d="M523.4 215.7C523.7 220.2 523.7 224.8 523.7 229.3C523.7 368 418.1 527.9 225.1 527.9C165.6 527.9 110.4 510.7 64 480.8C72.4 481.8 80.6 482.1 89.3 482.1C138.4 482.1 183.5 465.5 219.6 437.3C173.5 436.3 134.8 406.1 121.5 364.5C128 365.5 134.5 366.1 141.3 366.1C150.7 366.1 160.1 364.8 168.9 362.5C120.8 352.8 84.8 310.5 84.8 259.5L84.8 258.2C98.8 266 115 270.9 132.2 271.5C103.9 252.7 85.4 220.5 85.4 184.1C85.4 164.6 90.6 146.7 99.7 131.1C151.4 194.8 229 236.4 316.1 240.9C314.5 233.1 313.5 225 313.5 216.9C313.5 159.1 360.3 112 418.4 112C448.6 112 475.9 124.7 495.1 145.1C518.8 140.6 541.6 131.8 561.7 119.8C553.9 144.2 537.3 164.6 515.6 177.6C536.7 175.3 557.2 169.5 576 161.4C561.7 182.2 543.8 200.7 523.4 215.7z" /></svg></div>Share on Twitter</div></a>'
        expect(helper.sharing_button("twitter", "https://twitter.com", "Share on Twitter", target: "_blank")).to eq(share_button)
      end
    end
  end
end
