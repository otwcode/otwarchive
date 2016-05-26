# -*- coding: utf-8 -*-
require 'spec_helper'

describe StatCounter do

  before(:each) do
    @work = FactoryGirl.create(:work)
  end

  it "should be created for a new work" do
    expect(@work.stat_counter.nil?).not_to be_truthy
  end

end