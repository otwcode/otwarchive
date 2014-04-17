# -*- coding: utf-8 -*-
require 'spec_helper'

describe Chapter do

  describe "save" do

    before(:each) do
      @work = FactoryGirl.create(:work)
      @chapter = Chapter.new(:work => @work, :content => "Cool story, bro!")
    end
    
    it "should save minimalistic chapter" do
      @chapter.save.should be_true
    end
    
  end

end
