# A challenge assignment generator that uses Hopcroft-Karp to try to get a
# maximum matching (thus maximizing the number of complete assignments, and
# minimizing the number of assignments with no recipient or no giver). Sorts
# the potential matches (using the default sort, which relies on the fields
# num_prompts_matched and max_tags_matched) and uses that order to process
# outgoing edges in the depth-first search, so that we prioritize "good"
# matches.
#
# Follows the pseudocode from Wikipedia:
# https://en.wikipedia.org/wiki/Hopcroft-Karp_algorithm
#
# This class also has some extra steps to try to reduce the number of "cycles"
# (where person A is assigned to write for person B, and person B is assigned
# to write for person A). It's not guaranteed to be the minimum possible, but
# it might make the assignments nicer.
class AssignmentGenerator
  # Save the collection we're working with.
  def initialize(collection)
    @collection = collection
    @settings = @collection.challenge.potential_match_settings
  end

  # Generate all assignments for the desired collection.
  def generate
    load_potential_matches

    set_up_assignments

    while improve_assignments
      # Do nothing, just continue improving.
    end

    reduce_cycles

    raise "Invalid assignments!" unless validate_assignments

    ChallengeAssignment.transaction do
      save_complete_assignments
      save_placeholder_assignments
    end
  end

  private

  # Load information about potential matches from the collection.
  def load_potential_matches
    potential_matches = if @settings.nil? || @settings.no_match_required?
                          # Randomize if we have unconstrained matching.
                          @collection.potential_matches.all.shuffle
                        else
                          # Otherwise, order by potential match "goodness",
                          # highest to lowest, so that we prioritize better
                          # matches.
                          @collection.potential_matches.all.sort.reverse
                        end

    # Load the list of offers associated with each signup. Because we sorted the
    # potential matches list, each individual list of offers will be ordered by
    # match "goodness."
    @potential_givers = {}
    potential_matches.each do |pm|
      @potential_givers[pm.request_signup_id] ||= []
      @potential_givers[pm.request_signup_id] << pm.offer_signup_id
    end

    # Get a list of all signups that are matchable as a recipient, ordered by
    # the number of potential matches (in increasing order). This way, we
    # prioritize recipients who don't have very many people who could write for
    # them. Also introduce a random element to break ties.
    @recipients_by_priority = @potential_givers.keys.sort_by do |key|
      [@potential_givers[key].size, rand]
    end
  end

  # Set up the hashtables we use to store our current assignments.
  def set_up_assignments
    # This table will contain a mapping from each request to the offer
    # that they've been (temporarily) assigned to.
    @assignment_as_recipient = {}

    # This table will contain a mapping from each offer to the request
    # that they've been (temporarily) assigned to.
    @assignment_as_giver = {}
  end

  # Try to "improve" the assignments by looking for augmenting paths.
  def improve_assignments
    distance = augmenting_path_layers
    return false if distance.nil?

    # If we've reached this point, there is at least one augmenting path. It's
    # time to use depth-first search to find as many as possible.
    @recipients_by_priority.each do |recipient|
      # We try to find a giver for each unassigned recipient.
      next if @assignment_as_recipient[recipient]

      find_giver_for_recipient(distance, recipient)
    end

    true
  end

  # Double check that the @assignment_as_giver and @assignment_as_recipient
  # tables are consistent with each other, and that each recipient/giver pair is
  # compatible (listed in the @potential_givers table). This should be
  # guaranteed by the algorithm, but it's nice to know that it's not going to go
  # catastrophically wrong.
  def validate_assignments
    @assignment_as_recipient.each_pair do |recipient, giver|
      return false unless @assignment_as_giver[giver] == recipient
      return false unless @potential_givers[recipient].include?(giver)
    end

    @assignment_as_giver.each_pair do |giver, recipient|
      return false unless @assignment_as_recipient[recipient] == giver
    end

    true
  end

  # Save the assignments we calculated to the database.
  def save_complete_assignments
    # First, build assignments for all of the signups that have been matched.
    @assignment_as_recipient.each_pair do |recipient, giver|
      # This should never happen, but just in case:
      next if recipient.nil? || giver.nil?

      ChallengeAssignment.create(collection_id: @collection.id,
                                 request_signup_id: recipient,
                                 offer_signup_id: giver)
    end

    # Update the challenge_signups to indicate whether they've been assigned.
    #
    # TODO: These fields are no longer used for anything. Can the columns be
    # dropped from the ChallengeSignup table?
    ChallengeSignup.where(id: @assignment_as_recipient.keys)
      .update_all(assigned_as_request: true)
    ChallengeSignup.where(id: @assignment_as_recipient.values)
      .update_all(assigned_as_offer: true)
  end

  # Add blank assignments for any users that couldn't be assigned.
  def save_placeholder_assignments
    # Get the list of all signups (including those that we can't match, and
    # which won't be included in the @recipients_by_priority list).
    signup_ids = @collection.signups.pluck(:id)

    unmatched_recipients = signup_ids - @assignment_as_recipient.keys
    unmatched_givers = signup_ids - @assignment_as_recipient.values

    # Add blank assignments for all of the unmatched recipients.
    unmatched_recipients.each do |recipient|
      ChallengeAssignment.create(collection_id: @collection.id,
                                 request_signup_id: recipient)
    end

    # Add blank assignments for all of the unmatched givers.
    unmatched_givers.each do |giver|
      ChallengeAssignment.create(collection_id: @collection.id,
                                 offer_signup_id: giver)
    end
  end

  # Do breadth-first search in the augmenting path graph. This is the equivalent
  # of the BFS() function in Wikipedia's pseudo-code for the Hopcroft-Karp
  # algorithm.
  #
  # Returns nil if there are no augmenting paths.
  #
  # Otherwise, returns a map from offers to layer number/distance.
  def augmenting_path_layers
    queue = []
    distance = {}

    # Initialize the queue with all signups that have no assigned giver.
    @recipients_by_priority.each do |recipient|
      next if @assignment_as_recipient[recipient]

      queue << recipient
      distance[recipient] = 0
    end

    # Standard BFS loop: add to the end of the queue, and pull off of the
    # beginning with shift until the queue is empty.
    until queue.empty?
      recipient = queue.shift

      @potential_givers[recipient].each do |giver|
        # Automatically traverse the edge in the matching.
        assignment = @assignment_as_giver[giver]

        # Skip if we've already traversed the assignment.
        next if distance.key?(assignment)

        # Set the distance of the assignment. Note that we don't do any checking
        # for the case where assignment = nil here -- we'll just store the
        # distance regardless. This ensures that distance[nil] will always be
        # set if there is a path to an offer with no assigned recipient, and it
        # will not be set if there is no such path.
        distance[assignment] = distance[recipient] + 1

        # If the assignment isn't nil, enqueue them so that we reach them in our
        # breadth-first search.
        queue << assignment if assignment
      end
    end

    # The queue has nothing else for us to process!
    #
    # As discussed above, if distance[nil] is set, that means that at some point
    # we came across an offer with no assigned recipient -- meaning that there
    # is an augmenting path, and we should return the mapping from signup IDs to
    # layers. Otherwise, there is no augmenting path, and we should return nil.
    distance.key?(nil) ? distance : nil
  end

  # Performs depth-first search to find a new giver for this recipient. This is
  # the equivalent of the DFS(u) function in Wikipedia's pseudo-code for the
  # Hopcroft-Karp algorithm.
  #
  # Flips the augmenting path as it goes if it finds the new giver.
  #
  # Returns true if we found a new giver, false otherwise.
  def find_giver_for_recipient(layers, recipient)
    # Special case: if the recipient is nil, we don't need to find a giver for
    # them -- they're already covered. So we're good.
    return true if recipient.nil?

    @potential_givers[recipient].each do |giver|
      # Calculate the recipient currently assigned to the giver we want.
      assignment = @assignment_as_giver[giver]

      # Skip the assignment if we've already processed them.
      next unless layers.key?(assignment)

      # Check the layering.
      #
      # Also, this check means that if the giver is already assigned to us (i.e.
      # assignment = recipient), we won't end up falsely claiming that we can
      # switch our assignment to someone else.
      next unless layers[assignment] == layers[recipient] + 1

      # Do the recursive call to see if it would be possible to juggle the
      # assignments to free up the giver (so that we can steal them ourselves).
      if find_giver_for_recipient(layers, assignment)
        @assignment_as_recipient[recipient] = giver
        @assignment_as_giver[giver] = recipient
        layers.delete recipient
        return true
      end
    end

    # We failed to figure out how to assign ourselves to a different giver.
    # Time to declare that we've been processed, and signal that we can't be
    # matched with anyone else.
    layers.delete recipient
    false
  end

  # Find cycles (where a participant is assigned to write for their own writer)
  # and try to eliminate them if possible.
  def reduce_cycles
    # Reverse the priority so that we remove givers for low-priority recipients
    # first (which makes us less likely to remove the only potential giver for a
    # recipient).
    @recipients_by_priority.reverse.each do |recipient|
      # Skip recipients who have no other giver, because there's no point trying
      # to assign them to someone else.
      next if @potential_givers[recipient].size <= 1

      # Skip recipients that don't have an assignment.
      next unless (giver = @assignment_as_recipient[recipient])

      if giver == @assignment_as_giver[recipient]
        try_remove_potential_giver(recipient)
      end
    end
  end

  # See if we can remove the recipient's current assignment without increasing
  # the number of unassigned participants.
  def try_remove_potential_giver(recipient)
    # Store information about the old configuration.
    giver = @assignment_as_recipient[recipient]
    old_givers = @potential_givers[recipient].dup

    # Delete the potential giver and delete the assignment.
    @potential_givers[recipient].delete(giver)
    @assignment_as_recipient.delete(recipient)
    @assignment_as_giver.delete(giver)

    # If we can find another way to assign this recipient, then we've
    # (hopefully) reduced the number of cycles by deleting that particular
    # potential giver, without reducing the total number of complete
    # assignments. So we don't want to add back the potential giver we removed.
    distance = augmenting_path_layers
    return if distance && find_giver_for_recipient(distance, recipient)

    # If we couldn't reassign the recipient, then the assignment that we deleted
    # is critical, and we should stop trying to delete it.
    @potential_givers[recipient] = old_givers
    @assignment_as_recipient[recipient] = giver
    @assignment_as_giver[giver] = recipient
  end
end
