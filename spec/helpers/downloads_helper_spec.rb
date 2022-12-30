# frozen_string_literal: true

require "spec_helper"

describe DownloadsHelper do
  describe "#downloadable?" do
    subject { helper.downloadable?(target) }

    context "when the target is a string" do
      let(:target) { "" }

      it { is_expected.to be false }
    end

    context "when the target is a non-downloadable model" do
      let(:target) { build_stubbed(:comment) }

      it { is_expected.to be false }
    end

    shared_examples "a downloadable model" do |model|
      let(:target) { build_stubbed(model) }

      context "when the target is not posted" do
        before do
          allow(target).to receive(:posted?).and_return(false)
          allow(target).to receive(:hidden_by_admin).and_return(false)
          allow(target).to receive(:in_unrevealed_collection).and_return(false)
        end

        it { is_expected.to be false }
      end

      context "when the target is hidden by an admin" do
        before do
          allow(target).to receive(:posted?).and_return(true)
          allow(target).to receive(:hidden_by_admin).and_return(true)
          allow(target).to receive(:in_unrevealed_collection).and_return(false)
        end

        it { is_expected.to be false }
      end

      context "when the target can be downloaded" do
        before do
          allow(target).to receive(:posted?).and_return(true)
          allow(target).to receive(:hidden_by_admin).and_return(false)
          allow(target).to receive(:in_unrevealed_collection).and_return(false)
        end

        it { is_expected.to be true }
      end
    end

    it_behaves_like "a downloadable model", :series
    it_behaves_like "a downloadable model", :work

    context "when the target is an unrevealed work" do
      let(:target) { build_stubbed(:work) }

      before do
        allow(target).to receive(:posted?).and_return(true)
        allow(target).to receive(:hidden_by_admin).and_return(false)
        allow(target).to receive(:in_unrevealed_collection).and_return(true)
      end

      it { is_expected.to be false }
    end
  end

  describe "#download_url_for" do
    let(:downloadable) { build_stubbed(:series) }
    let(:download) { instance_double(Download) }

    it "returns the download url" do
      expect(Download).to receive(:new)
        .with(downloadable, { format: "format" })
        .and_return(download)
      allow(download).to receive(:public_path).and_return("path")
      result = helper.download_url_for(downloadable, "format")
      expect(result).to eq("path?updated_at=#{downloadable.updated_at.to_i}")
    end
  end
end
