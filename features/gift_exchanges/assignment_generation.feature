@collections
Feature: Assignment Generation
  Scenario: Assignment generation should use augmenting paths
    # This is a fairly complex set of sign-ups, which results in the following
    # set of potential matches:
    # - alice's potential writers: beth
    # - beth's potential writers: carol (preferred) or diana
    # - carol's potential writers: alice (preferred) or diana
    # - diana's potential writers: alice (preferred), beth, or carol
    #
    # In the old approach, the assignments for the four participants would be
    # generated in (roughly) the same order as their names, and the "preferred"
    # writer would be selected for both beth and carol, leaving diana with no
    # assignments (either as recipient or giver):
    # - alice writes for carol
    # - beth writes for alice
    # - carol writes for beth
    # - diana has no assignment
    #
    # The new algorithm starts with similar assignments, but uses augmenting
    # paths to make sure that diana gets an assignment -- specifically, her
    # preferred writer alice. This may result in slightly less plum
    # assignments for the other participants, but ensures that all assignments
    # are complete.
    Given I create the gift exchange "MaximumAssignments" with the following options
        | value      | minimum | maximum | match |
        | prompts    | 1       | 1       | 1     |
        | characters | 1       | 4       | 1     |
      And the user "alice" signs up for "MaximumAssignments" with the following prompts
        | type    | characters                   |
        | request | Viola                        |
        | offer   | Xandra, Yolanda, Ursula      |
      And the user "beth" signs up for "MaximumAssignments" with the following prompts
        | type    | characters                   |
        | request | Wendy, Zelda                 |
        | offer   | Viola                        |
      And the user "carol" signs up for "MaximumAssignments" with the following prompts
        | type    | characters                   |
        | request | Xandra, Yolanda, Ursula      |
        | offer   | Wendy, Zelda                 |
      And the user "diana" signs up for "MaximumAssignments" with the following prompts
        | type    | characters                   |
        | request | Xandra, Zelda, Viola, Ursula |
        | offer   | Xandra, Zelda                |
    When I have generated matches for "MaximumAssignments"
    Then the potential matches for "MaximumAssignments" should be
        | offer   | request |
        | alice   | carol   |
        | alice   | diana   |
        | beth    | alice   |
        | beth    | diana   |
        | carol   | beth    |
        | carol   | diana   |
        | diana   | beth    |
        | diana   | carol   |
      And the assignments for "MaximumAssignments" should be
        | giver   | recipient |
        | alice   | diana     |
        | beth    | alice     |
        | carol   | beth      |
        | diana   | carol     |

  Scenario: Assignment generation should try to avoid cycles
    # Although alice and beth have a lot of overlapping tags, and carol and
    # diana have a lot of overlapping tags, we don't just want to assign them
    # in pairs.
    Given I create the gift exchange "AvoidCycles" with the following options
        | value      | minimum | maximum | match |
        | prompts    | 1       | 1       | 1     |
        | characters | 1       | 4       | 1     |
      And the user "alice" signs up for "AvoidCycles" with the following prompts
        | type    | characters                   |
        | request | Xandra, Yolanda, Ursula      |
        | offer   | Xandra, Yolanda              |
      And the user "beth" signs up for "AvoidCycles" with the following prompts
        | type    | characters                   |
        | request | Xandra, Yolanda              |
        | offer   | Xandra, Yolanda, Viola       |
      And the user "carol" signs up for "AvoidCycles" with the following prompts
        | type    | characters                   |
        | request | Wendy, Zelda, Viola          |
        | offer   | Wendy, Zelda                 |
      And the user "diana" signs up for "AvoidCycles" with the following prompts
        | type    | characters                   |
        | request | Wendy, Zelda                 |
        | offer   | Wendy, Zelda, Ursula         |
    When I have generated matches for "AvoidCycles"
    Then the potential matches for "AvoidCycles" should be
        | offer   | request |
        | alice   | beth    |
        | beth    | alice   |
        | beth    | carol   |
        | carol   | diana   |
        | diana   | alice   |
        | diana   | carol   |
      And the assignments for "AvoidCycles" should be
        | giver   | recipient |
        | alice   | beth      |
        | beth    | carol     |
        | carol   | diana     |
        | diana   | alice     |
