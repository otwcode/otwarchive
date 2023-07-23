require "spec_helper"

describe MailerHelper do
  let(:work) { create(:work) }
  let(:chapter) { create(:chapter) }
  let(:series) { create(:series) }

  describe "style_creation_link" do
    it "nests red link inside bold inside italics" do
      expect(style_creation_link(work.title, work_url(work))).to eq("<i><b><a style=\"color:#990000\" href=\"#{work_url(work)}\">#{work.title}</a></b></i>")
    end
  end

  describe "#creation_title" do
    context "when creation is a series" do
      it "returns the series title" do
        expect(creation_title(series)).to eq(series.title)
      end
    end

    context "when creation is a work" do
      it "returns the work title" do
        expect(creation_title(work)).to eq(work.title)
      end
    end

    context "when creation is a chapter" do
      it "returns the work title with the chapter number" do
        expect(creation_title(chapter)).to eq("Chapter #{chapter.position} of #{work.title}")
      end
    end
  end

  describe "#creation_link_with_word_count" do
    context "when creation is a chapter" do
      it "returns hyperlinked full_chapter_title and parenthetical word count" do
        expect(creation_link_with_word_count(chapter, chapter_url(chapter))).to eq("<i><b><a style=\"color:#990000\" href=\"#{chapter_url(chapter)}\">#{chapter.full_chapter_title}</a></b></i> (#{chapter.word_count} words)")
      end
    end

    context "when creation is a series" do
      it "returns hyperlinked series title and parenthetical word count" do
        expect(creation_link_with_word_count(series, series_url(series))).to eq("<i><b><a style=\"color:#990000\" href=\"#{series_url(series)}\">#{series.title}</a></b></i> (#{series.word_count} words)")
      end
    end

    context "when creation is a work" do
      it "returns hyperlinked work title and parenthetical word count" do
        expect(creation_link_with_word_count(work, work_url(work))).to eq("<i><b><a style=\"color:#990000\" href=\"#{work_url(work)}\">#{work.title}</a></b></i> (#{work.word_count} words)")
      end
    end
  end

  describe "#creation_title_with_word_count" do
    context "when creation is a chapter" do
      it "returns full_chapter_title and parenthetical word count" do
        expect(creation_title_with_word_count(chapter)).to eq("\"#{chapter.full_chapter_title}\" (#{chapter.word_count} words)")
      end
    end

    context "when creation is a series" do
      it "returns series title and parenthetical word count" do
        expect(creation_title_with_word_count(series)).to eq("\"#{series.title}\" (#{series.word_count} words)")
      end
    end

    context "when creation is a work" do
      it "returns work title and parenthetical word count" do
        expect(creation_title_with_word_count(work)).to eq("\"#{work.title}\" (#{work.word_count} words)")
      end
    end
  end

  describe "#work_metadata_label" do
    it "appends the metadata indicator to a string" do
      expect(work_metadata_label("Text")).to eq("Text: ")
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

  describe "#batch_subscription_subject" do
    subject do
      batch_subscription_subject(subscription, creation, additional_entries)
    end
    let(:creator) { create(:user, login: "creator").default_pseud }
    let(:cocreator) { create(:user, login: "cocreator").default_pseud }
    let(:creator_byline) { creation.pseuds.first.byline }
    let(:cocreator_byline) { creation.pseuds.last.byline }
    let(:chapter_header) { creation.chapter_header }
    let(:app_nick) { "[#{ArchiveConfig.APP_SHORT_NAME}]" }

    [0, 1, 2].each do |number|
      context "when notification has #{number} additional entries" do
        let(:additional_entries) { number }
        let(:more) do
          additional_entries.zero? ? "" : " and #{additional_entries} more"
        end

        context "when subscription is to a series" do
          let(:work) do
            create(:work,
              authors: [creator],
              series: [create(:series, title: "Series Title")],
              title: "Work Title"
            )
          end
          let(:series) { work.series.first }
          let(:subscription) { create(:subscription, subscribable: series) }

          context "when main creation is a chapter" do
            let(:creation) { create(:chapter, work: work) }

            it { is_expected.to eq("#{app_nick} #{creator_byline} posted #{chapter_header} of #{work.title} in the #{series.title} series#{more}") }

            context "when chapter is co-created" do
              let(:creation) do
                create(:chapter,
                  authors: [creator, cocreator],
                  work: work
                )
              end

              it { is_expected.to eq("#{app_nick} #{creator_byline} and #{cocreator_byline} posted #{chapter_header} of #{work.title} in the #{series.title} series#{more}") }
            end

            context "when work is anonymous" do
              let(:work) do
                create(:work,
                  authors: [creator],
                  collections: [create(:anonymous_collection)],
                  title: "Work Title",
                  series: [create(:series, title: "Series Title")]
                )
              end

              it { is_expected.to eq("#{app_nick} Anonymous posted #{chapter_header} of #{work.title} in the #{series.title} series#{more}") }
            end
          end

          context "when main creation is a work" do
            let(:creation) do
              create(:work,
                authors: [creator],
                series: [series],
                title: "Work Title"
              )
            end

            it { is_expected.to eq("#{app_nick} #{creator_byline} posted #{creation.title} in the #{series.title} series#{more}") }

            context "when work is co-created" do
              let(:creation) do
                create(:work,
                  authors: [creator, cocreator],
                  series: [series],
                  title: "Work Title"
                )
              end

              it { is_expected.to eq("#{app_nick} #{creator_byline} and #{cocreator_byline} posted #{work.title} in the #{series.title} series#{more}") }
            end

            context "when work is anonymous" do
              let(:creation) do
                create(:work,
                  collections: [create(:anonymous_collection)],
                  series: [series],
                  title: "Work Title"
                  )
              end

              it { is_expected.to eq("#{app_nick} Anonymous posted #{work.title} in the #{series.title} series#{more}") }
            end
          end
        end

        context "when subscription is to a user" do
          let(:work) { create(:work, authors: [creator], title: "Work Title") }
          let(:anonymous_work) do
            create(:work,
              authors: [creator],
              collections: [create(:anonymous_collection)],
              title: "Work Title"
            )
          end
          let(:subscription) do
            create(:subscription, subscribable: creator.user)
          end

          context "when main creation is a chapter" do
            let(:creation) { create(:chapter, authors: [creator], work: work) }

            it { is_expected.to eq("#{app_nick} #{creator_byline} posted #{chapter_header} of #{work.title}#{more}") }

            context "when chapter is co-created" do
              let(:creation) do
                create(:chapter, authors: [creator, cocreator], work: work )
              end

              it { is_expected.to eq("#{app_nick} #{creator_byline} and #{cocreator_byline} posted #{chapter_header} of #{work.title}#{more}") }
            end

            context "when work is co-created but chapter is not" do
              let(:work) do
                create(:work,
                  authors: [creator, cocreator], title: "Work Title"
                )
              end
              let(:creation) do
                create(:chapter, work: work, authors: [creator])
              end

              it { is_expected.to eq("#{app_nick} #{creator_byline} posted #{chapter_header} of #{work.title}#{more}") }
            end
          end

          context "when main creation is a work" do
            let(:creation) do
              create(:work, authors: [creator], title: "Work Title")
            end

            it { is_expected.to eq("#{app_nick} #{creator_byline} posted #{creation.title}#{more}") }

            context "when work is co-created" do
              let(:creation) do
                create(:work,
                  authors: [creator, cocreator],
                  title: "Work Title"
                )
              end

              it { is_expected.to eq("#{app_nick} #{creator_byline} and #{cocreator_byline} posted #{creation.title}#{more}") }
            end
          end
        end

        context "when subscription is to a work" do
          let(:work) { create(:work, authors: [creator], title: "Work Title") }
          let(:creation) { create(:chapter, authors: [creator], work: work) }
          let(:subscription) { create(:subscription, subscribable: work) }

          it { is_expected.to eq("#{app_nick} #{creator_byline} posted #{chapter_header} of #{work.title}#{more}") }

          context "when work is anonymous" do
            let(:work) do
              create(:work, collections: [create(:anonymous_collection)])
            end

            it { is_expected.to eq("#{app_nick} Anonymous posted #{chapter_header} of #{work.title}#{more}") }
          end

          context "when chapter is co-created" do
            let(:creation) do
              create(:chapter, work: work, authors: [creator, cocreator])
            end

            it { is_expected.to eq("#{app_nick} #{creator_byline} and #{cocreator_byline} posted #{chapter_header} of #{work.title}#{more}") }
          end

          context "when work is co-created but chapter is not" do
            let(:work) do
              create(:work,
                authors: [creator, cocreator], title: "Work Title"
              )
            end
            let(:creation) do
              create(:chapter,
                authors: [creator],
                work: work
              )
            end

            it { is_expected.to eq("#{app_nick} #{creator_byline} posted #{chapter_header} of #{work.title}#{more}") }
          end
        end
      end
    end
  end
end
