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
      expect(Download.new(work).file_name).to eq("hdh ml jdyd")

      # Chinese
      work.title = "我哥好像被奇怪的人盯上了怎么破"
      expect(Download.new(work).file_name).to eq("Wo Ge Hao Xiang Bei Qi")

      # Japanese
      work.title = "二重スパイは接点を持つ"
      expect(Download.new(work).file_name).to eq("Er Zhong supaihaJie Dian")

      # Hebrew
      work.title = "לחזור הביתה"
      expect(Download.new(work).file_name).to eq("lkhzvr hbyth")
    end

    it "removes HTML entities and emojis" do
      work.title = "Two of Hearts <3 &amp; >.< &"
      expect(Download.new(work).file_name).to eq("Two of Hearts 3")

      work.title = "Emjoi 🤩 Yay 🥳"
      expect(Download.new(work).file_name).to eq("Emjoi Yay")
    end

    it "appends work ID if too short" do
      work.id = 999_999
      work.title = "Uh"
      expect(Download.new(work).file_name).to eq("Uh Work 999999")

      work.title = ""
      expect(Download.new(work).file_name).to eq("Work 999999")

      work.title = "wat"
      expect(Download.new(work).file_name).to eq("wat")
    end

    it "truncates if too long" do
      work.title = "123456789-123456789-123456789-"
      expect(Download.new(work).file_name).to eq("123456789-123456789-1234")

      work.title = "123456789 123456789 123456789"
      expect(Download.new(work).file_name).to eq("123456789 123456789")
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
end
