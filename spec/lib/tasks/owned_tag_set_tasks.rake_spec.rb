require "spec_helper"

describe "rake OwnedTagSet:deduplicate_owners" do
  it "does not update owned tag sets with only one owner" do
    owned_tag_set = create(:owned_tag_set)
    # OwnedTagSet is implicitly created with a single owner
    expect(owned_tag_set.owners.count).to eq(1)
    expected_owners = owned_tag_set.owners

    subject.invoke

    expect(owned_tag_set.reload.owners).to eq(expected_owners)
  end

  it "does not update owned tag sets with no owner (orphaned)" do
    owned_tag_set = create(:owned_tag_set)
    # Manually orphan this OwnedTagSet
    owned_tag_set.owners = []
    owned_tag_set.save
    expect(owned_tag_set.owners.count).to eq(0)
    expected_owners = owned_tag_set.owners

    subject.invoke

    expect(owned_tag_set.reload.owners).to eq(expected_owners)
  end

  it "does update owned tag sets with duplicate owner" do
    owned_tag_set = create(:owned_tag_set)
    # Manually duplicate the owner, bypassing validation
    pseud = owned_tag_set.owners.first
    TagSetOwnership.new(pseud: pseud, owned_tag_set: owned_tag_set, owner: true).save(validate: false)
    owned_tag_set = owned_tag_set.reload
    expect(owned_tag_set.owners.count).to eq(2)
    expect(owned_tag_set.owners).to eq([pseud, pseud])

    subject.invoke

    owned_tag_set = owned_tag_set.reload
    expect(owned_tag_set.owners.count).to eq(1)
    expect(owned_tag_set.owners).to eq([pseud])
  end

  it "does update owned tag sets with multiple duplicates/multiple owners" do
    owned_tag_set = create(:owned_tag_set)
    # Manually duplicate the owner, bypassing validation
    pseud1 = owned_tag_set.owners.first
    pseud2 = create(:user).default_pseud
    pseud3 = create(:user).default_pseud
    TagSetOwnership.new(pseud: pseud3, owned_tag_set: owned_tag_set, owner: true).save(validate: false)
    TagSetOwnership.new(pseud: pseud1, owned_tag_set: owned_tag_set, owner: true).save(validate: false)
    TagSetOwnership.new(pseud: pseud3, owned_tag_set: owned_tag_set, owner: true).save(validate: false)
    TagSetOwnership.new(pseud: pseud2, owned_tag_set: owned_tag_set, owner: true).save(validate: false)
    TagSetOwnership.new(pseud: pseud3, owned_tag_set: owned_tag_set, owner: true).save(validate: false)
    owned_tag_set = owned_tag_set.reload
    expect(owned_tag_set.owners.count).to eq(6)

    # Don't rely on ordering of owners - just count how many of each are present
    def owner_count(owners)
      owners.group_by { |pseud| pseud }
        .transform_values { :length }
    end

    expect(owner_count(owned_tag_set.owners)).to eq({ pseud1 => 2, pseud2 => 1, pseud3 => 3 })

    subject.invoke

    owned_tag_set = owned_tag_set.reload
    expect(owned_tag_set.owners.count).to eq(3)
    expect(owner_count(owned_tag_set.owners)).to eq({ pseud1 => 1, pseud2 => 1, pseud3 => 1 })
  end
end
