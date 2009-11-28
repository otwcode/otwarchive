require 'test_helper'

class ExternalCreatorshipTest < ActiveSupport::TestCase
  context "An External Creatorship" do
    should_belong_to :external_author_name, :creation
    should_belong_to :archivist
  end
end
