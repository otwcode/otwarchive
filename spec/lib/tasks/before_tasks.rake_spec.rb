require "spec_helper"

describe "Before:backfill_language_sortable_name" do
  it "does not backfill when sortable_name is present" do
    language = create(:language, sortable_name: "Hello!")
    expect { subject.invoke }
      .not_to change { language.reload.sortable_name }
  end

  it "backfills sortable_name with name when sortable_name is absent" do
    language = build(:language, sortable_name: "")
    language.save!(validate: false)
    expect { subject.invoke }
      .to change { language.reload.sortable_name }
      .to(language.name)
  end
end
