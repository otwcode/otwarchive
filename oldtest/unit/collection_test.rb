require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  context "a collection with an owner" do
    setup do
      assert create_collection
    end
    should_validate_presence_of :name, :message => /Please enter a name/
    should_validate_uniqueness_of :name, :case_sensitive => false, :message => /already taken/
    should_ensure_length_in_range :name, ArchiveConfig.TITLE_MIN..ArchiveConfig.TITLE_MAX, :short_message => /must be at least/, :long_message => /must be less/

    should_validate_presence_of :title, :message => /Please enter a title/
    should_ensure_length_in_range :title, ArchiveConfig.TITLE_MIN..ArchiveConfig.TITLE_MAX, :short_message => /must be at least/, :long_message => /must be less/
    should_have_many :collection_items, :works, :bookmarks, :participants, :owners, :moderators, :members, :users
    should_have_one :collection_profile, :collection_preference
    should_not_allow_values_for :name, "_startswithunderscore", "endswithunderscore_", "with spaces", :message => /must/
    should_allow_values_for :name, "underscore_in_the_middle", "words1with2numbers", "ends123", "123start"
    should_not_allow_values_for :email, "noatsign", "user@badbadbad", :message => /valid address/
    should_allow_values_for :email, random_email
  
    should_not_allow_values_for :header_image_url, "adjf afsd;jfa", "http://foobar.com/pic.jpg;execute(my_javascript)", "http://hello.com/"
    should_allow_values_for :header_image_url, "http://skitch.com/hello.jpg", "http://whee.com/pic.gif"
  end

end
