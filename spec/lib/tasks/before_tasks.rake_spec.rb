require "spec_helper"

describe "Before:backfill_language_sortable_name" do
  it "does not backfill when sortable_name is present" do
    language = create(:language, sortable_name: "Hello!")
    expect { subject.invoke }
      .not_to change { language.reload.sortable_name }
  end

  it "backfills sortable_name with name when sortable_name is absent" do
    language = build(:language)
    language.sortable_name = ""
    language.save!(validate: false)
    expect { subject.invoke }
      .to change { language.reload.sortable_name }
      .to(language.name)
  end
end

describe "Before:remove_invited_collection_participant_role" do
  let(:collection) { create(:collection) }
  let!(:member) do
    create(:collection_participant, collection: collection,
                                    participant_role: CollectionParticipant::MEMBER)
  end
  let!(:invited) do
    participant = build(:collection_participant, collection: collection)
    participant.participant_role = "Invited"
    participant.save!(validate: false)
    participant
  end

  it "converts invited participants to none" do
    subject.invoke
    expect(invited.reload.participant_role).to eq(CollectionParticipant::NONE)
  end

  it "does not change other participants" do
    subject.invoke
    expect(member.reload.participant_role).to eq(CollectionParticipant::MEMBER)
  end

  it "outputs the participants it could not update" do
    allow_any_instance_of(CollectionParticipant).to \
      receive(:update).and_return(false)

    expect { subject.invoke }
      .to output(/Failed to convert: #{invited.id}/).to_stdout
  end
end
