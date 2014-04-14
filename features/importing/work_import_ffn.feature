@works
Feature: Import Works from fanfiction.net
  In order to have an archive full of works
  As an author
  I want to create new works by importing them from fanfiction.net
  @import_ffn
  Scenario: Creating a new work from an FFN story with automatic metadata
    Given basic tags
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://www.fanfiction.net/s/3129674/1/What_More_Than_Usual_Light"
    When I press "Import"
    Then I should see "Imports from fanfiction.net are no longer available"
    # Then I should see "Preview"
    #   And I should see "Firefly" within "dd.fandom"
    #   And I should see "Mature" within "dd.rating"
    #   And I should see "Romance" within "dd.freeform"
    #   And I should see "Published:2006-08-29"
    #   And I should see "What More Than Usual Light?" within "h2.title"
    #   And I should not see "FanFiction" within "h2.title"
    #   And I should see "Thanks to my brilliant beta, Parenthetical." within "div.notes"
    #   And I should see "'So you'll take the job then?'"
    #   And I should see "The title comes from Ben Jonson's Hymenæi."
    #   And I should not see "FanFiction.Net"
    #   And I should not see "unleash your imagination"
    #   And I should not see "Tenar"
    #   And I should not see "Reviews:"
    # When I press "Post"
    # Then I should see "Work was successfully posted."
    # When I am on cosomeone's user page
    #   Then I should see "What More Than Usual Light?"

  @import_ffn_multi_chapter
  Scenario: Creating a new multichapter work from an FFN story
    Given basic tags
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://www.fanfiction.net/s/6646765/1/IChing"
    When I press "Import"
    Then I should see "Imports from fanfiction.net are no longer available"
    # Then I should see "Preview"
    #   And I should see "Firefly" within "dd.fandom"
    #   And I should see "Mature" within "dd.rating"
    #   And I should see "Drama" within "dd.freeform"
    #   And I should see "Published:2011-01-12"
    #   And I should see "IChing" within "h2.title"
    #   And I should not see "FanFiction" within "h2.title"
    #   And I should see "Bellumhydrochlorate trial: day 7"
    #   And I should see "Combat aids for soldiers responding to civil unrest on the edges of the system might be rendered unnecessary if it proves possible to treat the problem at its source."
    #   And I should not see "FanFiction.Net"
    #   And I should not see "unleash your imagination"
    #   And I should not see "Tenar"
    #   And I should not see "Reviews:"
    # When I press "Post"
    # Then I should see "Work was successfully posted."
    # Then I should see "Chapters:2/2"
    #   And I should see "Bellumhydrochlorate trial: day 7"
    #   And I should see "Combat aids for soldiers responding to civil unrest on the edges of the system might be rendered unnecessary if it proves possible to treat the problem at its source."
    # When I follow "Next Chapter"
    # Then I should see "Jayne. You'll keep a civil tongue in that mouth or I will sew it shut, is there an understanding between us?"
    #   And I should see "There wasn't no place for a rutting lunatic on the ship. No rutting way."
    # When I am on cosomeone's user page
    #   Then I should see "IChing"

