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
  
  def test_default_name
    email = 'foo@bar.com'
    external_author = create_external_author(:email => email, :user => nil)
    external_author.save
    assert external_author.default_name
    assert_equal email, external_author.default_name.name
  end


  def test_claim

    test_name = "Testing"
    email = "blah@foo.com"
    
    external_author = create_external_author(:user => nil, :email => email)
    external_name = create_external_author_name(:name => test_name, :external_author => external_author)
    external_author.external_author_names << external_name
    assert external_author.save
    assert external_author.names.length == 2
    
    archivist = create_user(:login => "archivist")
    @test_work = create_work(:authors => [archivist.default_pseud], :chapters => [new_chapter(:authors => [archivist.default_pseud])]) 
    @test_work.add_default_tags
    creatorship = create_external_creatorship(:external_author_name => external_name, :creation => @test_work, :archivist => archivist)
    #@test_work.external_creatorships << creatorship
    assert @test_work.save 


    # a new user comes along
    test_user = create_user(:login => "claimer")
    test_pseud = create_pseud(:user => test_user, :name => test_name)
    test_user.pseuds << test_pseud
    assert test_user.save
    
    # the user is not currently the owner
    assert @test_work.users.include?(archivist)
    assert !@test_work.users.include?(test_user)
    
    # user claims external authorship
    assert external_author.claim!(test_user)
    @work_after_claim = Work.find(@test_work.id)

    # this user should now have the external authorship
    assert test_user.external_authors.include?(external_author)
    assert_equal test_user, external_author.user
    assert external_author.claimed?

    
    # the user should have the work under the matching pseud
    assert @work_after_claim.pseuds.include?(test_pseud)
    assert !@work_after_claim.pseuds.include?(test_user.default_pseud)
    
    # this user should now be an author on the work
    assert !@work_after_claim.users.include?(archivist)
    assert @work_after_claim.users.include?(test_user)
    
    # unclaim
    assert external_author.unclaim!
    assert @work_after_claim.users.include?(archivist)
    assert !@work_after_claim.users.include?(test_user)
    
  end

end
