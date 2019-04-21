# -*- coding: utf-8 -*-
require 'spec_helper'

describe Series do
  let(:unrestricted_work) { FactoryGirl.create(:work, restricted: false, authors: User.current_user.pseuds) }
  let(:restricted_work) { FactoryGirl.create(:work, restricted: true, authors: User.current_user.pseuds) }

  before(:each) do
    User.current_user = FactoryGirl.create(:user)
    @series = FactoryGirl.create(:series)
  end

  it "should be unrestricted when it has unrestricted works" do
    @series.works = [unrestricted_work]
    @series.reload
    expect(@series.restricted).not_to be_truthy
  end

  it "should be restricted when it has no unrestricted works" do
    @series.works = [restricted_work]
    @series.reload
    expect(@series.restricted).to be_truthy
  end

  it "should be unrestricted when it has both restricted and unrestricted works" do
    @series.works = [restricted_work, unrestricted_work]
    @series.reload
    expect(@series.restricted).not_to be_truthy
  end

  it "has all of the pseuds from all of its serial works" do
    @series.works = [restricted_work, unrestricted_work]
    @series.reload
    expect(@series.work_pseuds).to match_array(User.current_user.pseuds)
  end

  describe 'cocreaters' do
    before(:each) do
      @creator = User.current_user
      @co_creator = FactoryGirl.create(:user)
      @co_creator1 = FactoryGirl.create(:user)
      @no_co_creator = FactoryGirl.create(:user)
      @co_creator.preference.allow_cocreator = true
      @co_creator1.preference.allow_cocreator = true
      @co_creator.preference.save
      @co_creator1.preference.save
    end

    it 'checks that normal co creator can co create' do
      @series.works = [restricted_work, unrestricted_work]
      @series.reload
      expect{ @series.pseuds = @creator.pseuds + @co_creator1.pseuds }.not_to raise_error
      expect(@series.work_pseuds).to match_array(User.current_user.pseuds )
    end

    it "raises an error when adding a co-creator whose preferences are not set to allow co-creation" do
      @series.works = [restricted_work, unrestricted_work]
      @series.reload
      expect { @series.pseuds = @creator.pseuds + @no_co_creator.pseuds }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Trying to add a invalid co creator' )
    end
  end
end
