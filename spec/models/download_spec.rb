# frozen_string_literal: true

require "spec_helper"

describe Download do
  describe "file_name" do
    let(:work) { Work.new }

    it "transliterates non-ASCII characters" do
      # Russian
      work.title = "Укрощение строптивых"
      expect(Download.new(work).file_name).to eq("Ukroshchieniie")

      # Arabic
      work.title = "هذا عمل جديد"
      expect(Download.new(work).file_name).to eq("hdh_ml_jdyd")

      # Chinese
      work.title = "我哥好像被奇怪的人盯上了怎么破"
      expect(Download.new(work).file_name).to eq("Wo_Ge_Hao_Xiang_Bei_Qi")

      # Japanese
      work.title = "二重スパイは接点を持つ"
      expect(Download.new(work).file_name).to eq("Er_Zhong_supaihaJie_Dian")

      # Hebrew
      work.title = "לחזור הביתה"
      expect(Download.new(work).file_name).to eq("lkhzvr_hbyth")
    end

    it "removes HTML entities and emojis" do
      work.title = "Two of Hearts <3 &amp; >.< &"
      expect(Download.new(work).file_name).to eq("Two_of_Hearts_3")

      work.title = "Emjoi 🤩 Yay 🥳"
      expect(Download.new(work).file_name).to eq("Emjoi_Yay")
    end

    it "strips leading space" do
      work.title = " Blank Space Baby"
      expect(Download.new(work).file_name).to eq("Blank_Space_Baby")
    end

    it "strips trailing space" do
      work.title = "Write your name: "
      expect(Download.new(work).file_name).to eq("Write_your_name")
    end

    it "replaces multiple spaces with single underscore" do
      work.title = "Space   Opera"
      expect(Download.new(work).file_name).to eq("Space_Opera")
    end

    it "replaces unicode space with underscores" do
      work.title = "No-break Space"
      expect(Download.new(work).file_name).to eq("No-break_Space")

      work.title = "En Quad Space"
      expect(Download.new(work).file_name).to eq("En_Quad_Space")

      work.title = "Em Quad Space"
      expect(Download.new(work).file_name).to eq("Em_Quad_Space")

      work.title = "En Space"
      expect(Download.new(work).file_name).to eq("En_Space")

      work.title = "Em Space"
      expect(Download.new(work).file_name).to eq("Em_Space")

      work.title = "3 Per Em Space"
      expect(Download.new(work).file_name).to eq("3_Per_Em_Space")

      work.title = "4 Per Em Space"
      expect(Download.new(work).file_name).to eq("4_Per_Em_Space")

      work.title = "6 Per Em Space"
      expect(Download.new(work).file_name).to eq("6_Per_Em_Space")

      work.title = "Figure Space"
      expect(Download.new(work).file_name).to eq("Figure_Space")

      work.title = "Punctuation Space"
      expect(Download.new(work).file_name).to eq("Punctuation_Space")

      work.title = "Thin Space"
      expect(Download.new(work).file_name).to eq("Thin_Space")

      work.title = "Hair Space"
      expect(Download.new(work).file_name).to eq("Hair_Space")

      work.title = "Narrow No-Break Space"
      expect(Download.new(work).file_name).to eq("Narrow_No-Break_Space")
    end

    it "appends work ID if too short" do
      work.id = 999_999
      work.title = "Uh"
      expect(Download.new(work).file_name).to eq("Uh_Work_999999")

      work.title = ""
      expect(Download.new(work).file_name).to eq("Work_999999")

      work.title = "wat"
      expect(Download.new(work).file_name).to eq("wat")
    end

    it "truncates if too long" do
      work.title = "123456789-123456789-123456789-"
      expect(Download.new(work).file_name).to eq("123456789-123456789-1234")

      work.title = "123456789 123456789 123456789"
      expect(Download.new(work).file_name).to eq("123456789_123456789")
    end
  end

  describe "author_names" do
    let(:work) { Work.new }
    let(:subject) { Download.new(work) }
    let(:simple_user) { build(:user, login: "SimpleAuthor") }
    let(:simple_author) { build(:pseud, name: "SimpleAuthor", user: simple_user) }
    let(:complex_user) { build(:user, login: "ComplexUser") }
    let(:complex_author) { build(:pseud, name: "ComplexAuthor", user: complex_user) }

    it "returns Anonymous when the work is anonymous" do
      allow(work).to receive(:anonymous?).and_return(true)

      expect(subject.author_names).to eq(["Anonymous"])
    end

    context "when the pseud is the same as the username" do
      it "returns the pseud by itself" do
        allow(work).to receive(:pseuds).and_return([simple_author])

        expect(subject.author_names).to eq(["SimpleAuthor"])
      end
    end

    context "when the pseud is different from the username" do
      it "returns the disambiguated pseud" do
        allow(work).to receive(:pseuds).and_return([complex_author])

        expect(subject.author_names).to eq(["ComplexAuthor (ComplexUser)"])
      end
    end

    context "for a work with multiple authors" do
      it "returns the pseuds in alphabetical order" do
        allow(work).to receive(:pseuds).and_return([simple_author, complex_author])

        expect(subject.author_names).to eq(["ComplexAuthor (ComplexUser)", "SimpleAuthor"])
      end
    end
  end

  describe "page_title" do
    let(:fandom1) { build(:canonical_fandom) }
    let(:fandom2) { build(:fandom, name: "Non-Canonical") }
    let(:pseud1) { build(:pseud, name: "First", user: build(:user, login: "Zeroth")) }
    let(:pseud2) { build(:pseud, name: "Second", user: build(:user)) }
    let(:work) { build(:work, fandoms: [fandom1, fandom2], title: "Foo bar") }
    let(:subject) { Download.new(work) }

    it "includes fandom names" do
      expect(subject.page_title).to include(fandom1.name)
      expect(subject.page_title).to include(fandom2.name)
    end

    it "leaves emojis alone" do
      work.title = "emoji 🥳 is 🚀 awesome"

      expect(subject.page_title).to include("emoji 🥳 is 🚀 awesome")
    end

    it "leaves long titles alone" do
      work.title = "no title is too long to print nor to read"

      expect(subject.page_title).to include("no title is too long to print nor to read")
    end

    context "for a work with multiple authors" do
      it "joins the author names with a comma and a space" do
        allow(work).to receive(:pseuds).and_return([pseud1, pseud2])

        expect(subject.page_title).to include("First (Zeroth), Second")
      end
    end

    it "leaves author names containing Chinese characters alone" do
      allow(pseud1).to receive(:byline).and_return("我哥好像被奇怪的人盯上了怎么破")
      allow(work).to receive(:pseuds).and_return([pseud1])

      expect(subject.page_title).to include(" - 我哥好像被奇怪的人盯上了怎么破 - ")
    end
  end

  describe "chapters" do
    let(:work) { create(:work) }
    let!(:draft_chapter) { create(:chapter, :draft, work: work, position: 2) }
    let(:subject) { Download.new(work) }

    it "includes only posted chapters by default" do
      expect(subject.chapters).to eq([work.chapters.first])
    end

    context "when include_draft_chapters is true" do
      let(:subject) { Download.new(work, include_draft_chapters: true) }

      it "includes both posted and draft chapters" do
        expect(subject.chapters).to eq([work.chapters.first, draft_chapter])
      end
    end

    context "when include_draft_chapters is false" do
      let(:subject) { Download.new(work, include_draft_chapters: false) }

      it "includes only posted chapters" do
        expect(subject.chapters).to eq([work.chapters.first])
      end
    end
  end
end
