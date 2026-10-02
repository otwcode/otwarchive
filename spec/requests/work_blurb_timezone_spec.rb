# frozen_string_literal: true

require "spec_helper"

describe "Work blurb time zones" do
  include LoginMacros

  let(:author) { create(:user) }
  let(:work) { create(:work, authors: [author.default_pseud], revised_at: 40.days.ago.utc.change(hour: 10)) }

  before do
    AdminSetting.first.update_attribute(:enable_test_caching, true)
  end

  it "shows the revision date in the viewer's time zone even when the blurb is cached" do
    east_user = create(:user)
    east_user.preference.update_attribute(:time_zone, "Auckland")
    west_user = create(:user)
    west_user.preference.update_attribute(:time_zone, "International Date Line West")

    east_date = work.revised_at.in_time_zone("Auckland").to_date.to_formatted_s(:rfc822)
    west_date = work.revised_at.in_time_zone("International Date Line West").to_date.to_formatted_s(:rfc822)
    expect(east_date).not_to eq(west_date)

    fake_login_known_user(east_user)
    get user_path(author)
    expect(response.body).to include(east_date)

    fake_login_known_user(west_user)
    get user_path(author)
    expect(response.body).to include(west_date)
  end
end
