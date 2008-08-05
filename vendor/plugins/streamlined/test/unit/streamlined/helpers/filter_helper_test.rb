require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/helpers/filter_helper'

describe "Streamlined::FilterHelper" do
  include Streamlined::Helpers::FilterHelper

  it "advanced filtering defaults to false" do
    assert !advanced_filtering
  end

end