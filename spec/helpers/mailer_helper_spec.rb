require "spec_helper"

describe MailerHelper do
  describe "style_creation_link" do
    it "nests red link inside bold inside italics" do
      work = create(:work)
      expect(style_creation_link(work.title, work_url(work))).to eq("<i><b><a style=\"color:#990000\" href=\"#{work_url(work)}\">#{work.title}</a></b></i>")
    end
  end

  describe "#work_metadata_label" do
    it "appends the metadata indicator to a string" do
      expect(work_metadata_label("Text")).to eq("Text: ")
    end
  end

  describe "#work_tag_metadata_label" do
    {
      "Fandom" => ["Fandom: ", "Fandoms: "],
      "Rating" => ["Rating: ", "Ratings: "],
      "ArchiveWarning" => ["Warning: ", "Warnings: "],
      "Relationship" => ["Relationship: ", "Relationships: "],
      "Character" => ["Character: ", "Characters: "],
      "Freeform" => ["Additional Tag: ", "Additional Tags: "]
    }.each_pair do |klass, labels|
      context "when given one #{klass.underscore.humanize.downcase.singularize}" do
        let(:tags) { build_list(:tag, 1, type: klass) }

        it "returns \"#{labels[0]}\"" do
          expect(work_tag_metadata_label(tags)).to eq(labels[0])
        end
      end

      context "when given multiple #{klass.underscore.humanize.downcase.pluralize}" do
        let(:tags) { build_list(:tag, 2, type: klass) }

        it "returns \"#{labels[1]}\"" do
          expect(work_tag_metadata_label(tags)).to eq(labels[1])
        end
      end
    end
  end

  describe "#work_tag_metadata_list" do
    %w[Fandom Rating ArchiveWarning Relationship Character Freeform].each do |klass|
      context "when given one #{klass.underscore.humanize.downcase.singularize}" do
        let(:tag) { create(:tag, type: klass) }
        let(:tags) { [tag] }

        it "returns a string with the tag name" do
          expect(work_tag_metadata_list(tags)).to eq(tag.name)
        end
      end

      context "when given multiple #{klass.underscore.humanize.downcase.pluralize}" do
        let(:tag1) { create(:tag, type: klass) }
        let(:tag2) { create(:tag, type: klass) }
        let(:tags) { [tag1, tag2] }

        it "returns a string of tag names joined by a comma and a space" do
          expect(work_tag_metadata_list(tags)).to eq("#{tag1.name}, #{tag2.name}")
        end
      end
    end
  end

  describe "#work_tag_metadata" do
    {
      "Fandom" => ["Fandom: ", "Fandoms: "],
      "Rating" => ["Rating: ", "Ratings: "],
      "ArchiveWarning" => ["Warning: ", "Warnings: "],
      "Relationship" => ["Relationship: ", "Relationships: "],
      "Character" => ["Character: ", "Characters: "],
      "Freeform" => ["Additional Tag: ", "Additional Tags: "]
    }.each_pair do |klass, labels|
      context "when given one #{klass.underscore.humanize.downcase.singularize}" do
        let(:tag) { create(:tag, type: klass) }
        let(:tags) { [tag] }

        it "returns \"#{labels[0]}\" followed by the tag name" do
          expect(work_tag_metadata(tags)).to eq("#{labels[0]}#{tag.name}")
        end
      end

      context "when given multiple #{klass.underscore.humanize.downcase.pluralize}" do
        let(:tag1) { create(:tag, type: klass) }
        let(:tag2) { create(:tag, type: klass) }
        let(:tags) { [tag1, tag2] }

        it "returns \"#{labels[1]}\" followed by a comma-separated list of tag names" do
          expect(work_tag_metadata(tags)).to eq("#{labels[1]}#{tag1.name}, #{tag2.name}")
        end
      end
    end
  end

  describe "#style_work_tag_metadata_list" do
    context "when given one fandom" do
      let(:fandom) { create(:fandom) }
      let(:fandoms) { [fandom] }

      it "returns a red link to the fandom" do
        link = link_to(fandom.name, fandom_url(fandom), style: "color:#990000")
        expect(style_work_tag_metadata_list(fandoms)).to eq(link)
      end
    end

    context "when given multiple fandoms" do
      let(:fandom1) { create(:fandom) }
      let(:fandom2) { create(:fandom) }
      let(:fandoms) { [fandom1, fandom2] }

      it "returns red links to the fandoms combined using to_sentence" do
        link1 = link_to(fandom1.name, fandom_url(fandom1), style: "color:#990000")
        link2 = link_to(fandom2.name, fandom_url(fandom2), style: "color:#990000")
        expect(style_work_tag_metadata_list(fandoms)).to eq("#{link1} and #{link2}")
      end
    end

    %w[Rating ArchiveWarning Relationship Character Freeform].each do |klass|
      context "when given one #{klass.underscore.humanize.downcase.singularize}" do
        let(:tag) { create(:tag, type: klass) }
        let(:tags) { [tag] }

        it "returns a string with the tag name" do
          expect(style_work_tag_metadata_list(tags)).to eq(tag.name)
        end
      end

      context "when given multiple #{klass.underscore.humanize.downcase.pluralize}" do
        let(:tag1) { create(:tag, type: klass) }
        let(:tag2) { create(:tag, type: klass) }
        let(:tags) { [tag1, tag2] }

        it "returns a string of tag names joined by a comma and a space" do
          expect(style_work_tag_metadata_list(tags)).to eq("#{tag1.name}, #{tag2.name}")
        end
      end
    end
  end

  describe "#style_work_tag_metadata" do
    context "when given one fandom" do
      let(:fandom) { create(:fandom) }
      let(:fandoms) { [fandom] }

      it "returns \"Fandom: \" styled bold and red followed by a link to the fandom" do
        label = "<b style=\"color:#990000\">Fandom: </b>"
        link = link_to(fandom.name, fandom_url(fandom), style: "color:#990000")
        expect(style_work_tag_metadata(fandoms)).to eq("#{label}#{link}")
      end
    end

    context "when given multiple fandoms" do
      let(:fandom1) { create(:fandom) }
      let(:fandom2) { create(:fandom) }
      let(:fandoms) { [fandom1, fandom2] }

      it "returns \"Fandoms: \" styled bold and red followed by links to the fandoms combined using to_sentence" do
        label = "<b style=\"color:#990000\">Fandoms: </b>"
        link1 = link_to(fandom1.name, fandom_url(fandom1), style: "color:#990000")
        link2 = link_to(fandom2.name, fandom_url(fandom2), style: "color:#990000")
        list = "#{link1} and #{link2}"
        expect(style_work_tag_metadata(fandoms)).to eq("#{label}#{list}")
      end
    end

    {
      "Rating" => ["Rating:", "Ratings:"],
      "ArchiveWarning" => ["Warning:", "Warnings:"],
      "Relationship" => ["Relationship:", "Relationships:"],
      "Character" => ["Character:", "Characters:"],
      "Freeform" => ["Additional Tag:", "Additional Tags:"]
    }.each_pair do |klass, labels|
      context "when given one #{klass.underscore.humanize.downcase.singularize}" do
        let(:tag) { create(:tag, type: klass) }
        let(:tags) { [tag] }

        it "returns \"#{labels[0]} \" styled bold and red followed by the tag name" do
          label = "<b style=\"color:#990000\">#{labels[0]} </b>"
          expect(style_work_tag_metadata(tags)).to eq("#{label}#{tag.name}")
        end
      end

      context "when given multiple #{klass.underscore.humanize.downcase.pluralize}" do
        let(:tag1) { create(:tag, type: klass) }
        let(:tag2) { create(:tag, type: klass) }
        let(:tags) { [tag1, tag2] }

        it "returns \"#{labels[1]} \" styled bold and red followed by a comma-separated list of tag names" do
          label = "<b style=\"color:#990000\">#{labels[1]} </b>"
          list = "#{tag1.name}, #{tag2.name}"
          expect(style_work_tag_metadata(tags)).to eq("#{label}#{list}")
        end
      end
    end
  end
end
