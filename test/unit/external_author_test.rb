require 'test_helper'

class ExternalAuthorTest < ActiveSupport::TestCase

  context "an external author" do
    create_external_author
    
    should_validate_presence_of :email, :message => /Please enter/
    should_validate_uniqueness_of :email, :case_sensitive => false, :message => /Sorry/
    should_ensure_length_in_range :email, (3..300), :short_message => /too short/, :long_message => /too long/
    should_not_allow_values_for :email, "noatsign", "user@badbadbad", :message => /valid email/
    should_allow_values_for :email, random_email    
  end


  def test_claim
    
    external_author = create_external_author(:user => nil)
    archivist = create_user
    work = create_work(:authors => [archivist.default_pseud], :chapters => [new_chapter(:authors => [archivist.default_pseud])]) 
    work.add_default_tags
    assert work.save 
    creatorship = create_external_creatorship(:external_author => external_author, :creation => work, :archivist => archivist)
    
    # a new user comes along
    user = create_user
    
    # the user is not currently the owner
    assert work.users.include?(archivist)
    assert !work.users.include?(user)
    
    # user claims external authorship
    assert external_author.claim!(user)
    
    # this user should now have the external authorship
    assert user.external_authors.include?(external_author)
    assert_equal user, external_author.user
    assert external_author.claimed?
    
    #debugger 
    
    # this user should now be an author on the work
    assert !work.users.include?(archivist)
    assert work.users.include?(user)
    
    # unclaim
    assert external_author.unclaim!
    assert work.users.include?(archivist)
    assert !work.users.include?(user)
    
  end

end
