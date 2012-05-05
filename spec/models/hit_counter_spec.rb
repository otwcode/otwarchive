# -*- coding: utf-8 -*-
require 'spec_helper'

describe HitCounter do
  
  before(:each) do
    @work = Factory.create(:work)
  end

  it "should be created for a new work" do
    @work.hit_counter.nil?.should_not be_true
  end
  
end