# -*- coding: utf-8 -*-
require 'spec_helper'

describe Series do
  
  let(:unrestricted_work) { FactoryGirl.create(:work, :restricted => false) }
  let(:restricted_work) { FactoryGirl.create(:work, :restricted => true) }
  
  before(:each) do
    @series = FactoryGirl.create(:series)
  end
  
  it "should be unrestricted when it has unrestricted works" do
    @series.works = [unrestricted_work]
    @series.reload
    @series.restricted.should_not be_true
  end
  
  it "should be restricted when it has no unrestricted works" do
    @series.works = [restricted_work]
    @series.reload
    @series.restricted.should be_true
  end
  
  it "should be unrestricted when it has both restricted and unrestricted works" do
    @series.works = [restricted_work, unrestricted_work]
    @series.reload
    @series.restricted.should_not be_true
  end
  
end
