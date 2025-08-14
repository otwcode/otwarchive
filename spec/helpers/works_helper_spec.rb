require 'spec_helper'

describe WorksHelper do
  describe '#all_coauthor_skins' do
    before do
      @users = Array.new(5) { FactoryBot.create(:user) }
      @work = create(:work, authors: @users.flat_map(&:pseuds))
    end

    context 'no public work skins or private work skins' do
      it 'returns an empty array' do
        expect(helper.all_coauthor_skins).to be_empty
      end
    end

    context 'public work skins exist' do
      before do
        create(:work_skin, :public, title: "Z Public Skin")
        create(:work_skin, :public, title: "B Public Skin")
      end

      context 'no private work skins' do
        it 'returns public work skins, ordered by title' do
          expect(helper.all_coauthor_skins.pluck(:title)).to eq(['B Public Skin', 'Z Public Skin'])
        end
      end

      context 'private work skins exist' do
        before do
          create(:work_skin, :private, title: "A Private Skin", author: @users[3])
          create(:work_skin, :private, title: "M Private Skin", author: @users[0])
          create(:work_skin, :private, title: "Unowned Private Skin")
        end

        it 'returns public work skins and skins belonging to allpseuds, ordered by title' do
          expect(helper.all_coauthor_skins.pluck(:title)).to eq(['A Private Skin',
                                                                 'B Public Skin',
                                                                 'M Private Skin',
                                                                 'Z Public Skin'])
        end

        it 'does not return unassociated private work skins' do
          expect(helper.all_coauthor_skins.pluck(:title)).not_to include(['Unowned Private Skin'])
        end
      end
    end
  end

  describe '#sorted_languages' do
    it 'returns all languages sorted alphabetically' do
      # only english language exists
      expect(Language.count).to eq(1)
      english = Language.find_by(short: 'en', sortable_name: '')

      # create 3 new languages
      german = Language.create(name: 'Deutsch', short: 'de', sortable_name: '')
      finnish = Language.create(name: 'Suomi', short: 'fi', sortable_name: 'su')
      indonesian = Language.create(name: 'Bahasa Indonesia', short: 'id', sortable_name: 'ba')

      # sort them
      expect(sorted_languages).to eq([indonesian, german, english, finnish])
    end
  end

  describe "#get_endnotes_link" do
    let(:work) { create(:work) }
    let(:chapter) { create(:chapter, work: work) }
    let(:unposted_work) { create(:draft) }

    context "not on chapters#show" do
      before { allow(helper).to receive(:current_page?).and_return(false) }

      it "returns #work_endnotes" do
        expect(helper.get_endnotes_link(work)).to eq("#work_endnotes")
      end
    end

    context "chapters#show for a posted work" do
      before { allow(helper).to receive(:current_page?).and_return(true) }

      it "returns path to last posted chapter's endnotes" do
        expect(helper.get_endnotes_link(work)).to eq(chapter_path(work.last_posted_chapter, anchor: "work_endnotes"))
      end

      it "returns path to last chapter's endnotes if no posted chapters" do
        chapter.destroy!
        expect(helper.get_endnotes_link(work)).to eq(chapter_path(work.last_chapter, anchor: "work_endnotes"))
      end
    end

    context "chapters#show for a draft work" do
      before { allow(helper).to receive(:current_page?).and_return(true) }

      it "returns path to last chapter's endnotes" do
        expect(helper.get_endnotes_link(unposted_work)).to eq(chapter_path(unposted_work.last_chapter, anchor: "work_endnotes"))
      end
    end
  end

  describe "#og_title_meta" do
    let(:user) { create(:user) }
    let(:work) { create(:work, title: "My Epic", authors: [user.default_pseud]) }

    context "work title and byline are within character limit" do
      it "returns the work title first" do
        expect(helper.og_title_meta(work)).to eq("#{work.title} by #{user.default_pseud.byline}")
      end
    end

    context "work title exceeds character limit" do
      it "returns the byline first" do
        work.title = Faker::Lorem.characters(number: 71)
        expect(helper.og_title_meta(work)).to eq("#{user.default_pseud.byline}: #{work.title}")
      end
    end
  end

  describe "#og_description_meta" do
    let(:work) { create(:work, summary: "This is my first fic! I'm going to show the world!", fandom_string: "Fandom,Original Work", relationship_string: "abc/def", character_string: "abc,def,xyz") }

    context "work summary is present" do
      it "returns the work summary" do
        expect(helper.og_description_meta(work)).to eq(work.summary)
      end
    end

    context "work summary is absent" do
      before do
        work.summary = ""
      end

      it "returns fandom, relationship and character tags" do
        expect(helper.og_description_meta(work)).to eq("Fandom, Original Work, abc/def, abc, def, xyz")
      end

      context "relationship tags are absent" do
        it "gracefully returns fandom and character tags only" do
          work.relationship_string = ""
          expect(helper.og_description_meta(work)).to eq("Fandom, Original Work, abc, def, xyz")
        end
      end
    end
  end
end
