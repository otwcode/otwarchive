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
end
