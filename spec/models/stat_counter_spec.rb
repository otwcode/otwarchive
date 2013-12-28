# -*- coding: utf-8 -*-
require 'spec_helper'

describe StatCounter do
  
  before(:each) do
    @work = FactoryGirl.create(:work)
  end

  it "should be created for a new work" do
    @work.stat_counter.nil?.should_not be_true
  end
  
end