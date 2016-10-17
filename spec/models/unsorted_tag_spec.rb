require 'spec_helper'

describe UnsortedTag do
  let(:bookmarker) { create(:user, :active) }
  let(:work) do
    create(
      :work,
      authors: [create(:user, :active).pseuds.first],
      chapters: [create(:chapter)]
    )
  end

  it "should be created from a bookmark" do
    create(
      :bookmark,
      bookmarkable_id: work.id,
      pseud_id: bookmarker.pseuds.first.id,
      tag_string: 'bookmark tag'
    )

    expect(Tag.find_by_name('bookmark tag')).to be_a(UnsortedTag)
  end

  describe "recategorize" do
    %w(Fandom Character Relationship Freeform).each do |new_type|
      it "should return a tag of type #{new_type}" do
        tag = create(:unsorted_tag)
        expect(tag.recategorize(new_type)).to be_a(new_type.constantize)
      end
    end
  end
end
