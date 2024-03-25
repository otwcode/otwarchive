@errors
Feature: Error messages should work

  Scenario: Some pages with non existent things raise errors
    Given the user "KnownUser" exists and is activated
      And the following activated tag wrangler exists
      | login          |
      | wranglerette   |

    Then visiting "/admin_posts/999999999" should fail with a not found error
      And visiting "/users/UnknownUser/bookmarks" should fail with a not found error
      And visiting "/users/KnownUser/pseuds/unknown_pseud/bookmarks" should fail with a not found error
      And visiting "/tags/UnknownTag/bookmarks" should fail with a not found error
      And visiting "/collections/unknowncollection" should fail with a not found error
      And visiting "/media/UnknownMediaType/fandoms" should fail with a not found error
      And visiting "/users/KnownUser/pseuds/unknown_pseud" should fail with a not found error
      And visiting "/series/999" should fail with a not found error
      And visiting "/users/KnownUser/pseuds/unknown_pseud/series" should fail with a not found error
      And visiting "/users/UnknownUser/pseuds/unknown_pseud/series" should fail with a not found error
      And visiting "/tags/NonexistentTag" should fail with a not found error
      And visiting "/tags/999999999/feed.atom" should fail with a not found error
      And visiting "/works/999999999" should fail with a not found error
      And visiting "/tags/UnknownTag/works" should fail with a not found error
    When I am logged in as "wranglerette"
      And visiting "/tags/NonexistentTag/edit" should fail with a not found error

  Scenario: Error messages should be able to display '^'
    Given I am logged in as a random user
      And I post the work "Work 1"
      And I view the work "Work 1"
      And I follow "Edit Tags"
    When I fill in "Fandoms" with "^"
      And I press "Post"
    Then I should see "Sorry! We couldn't save this work because: Tag name '^' cannot include the following restricted characters: , ^ * < > { } = ` ， 、 \ %"
