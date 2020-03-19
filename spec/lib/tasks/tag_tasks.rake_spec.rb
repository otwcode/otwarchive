require "spec_helper"

describe "rake Tag:destroy_invalid_common_taggings" do
  it "deletes CommonTaggings with a missing child" do
    parent = create(:canonical_fandom)
    child = create(:character)
    common_tagging = CommonTagging.create(filterable: parent, common_tag: child)
    child.delete

    expect { subject.invoke }.not_to raise_exception
    expect { common_tagging.reload }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  it "deletes CommonTaggings with a missing parent" do
    parent = create(:canonical_fandom)
    child = create(:character)
    common_tagging = CommonTagging.create(filterable: parent, common_tag: child)
    parent.delete

    expect { subject.invoke }.not_to raise_exception
    expect { common_tagging.reload }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  it "deletes CommonTaggings with a non-canonical parent" do
    parent = create(:fandom)
    child = create(:character)
    common_tagging = CommonTagging.new(filterable: parent, common_tag: child)
    common_tagging.save(validate: false)

    expect { subject.invoke }.not_to raise_exception
    expect { common_tagging.reload }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  it "deletes CommonTaggings with mismatched types" do
    parent = create(:canonical_character)
    child = create(:fandom)
    common_tagging = CommonTagging.new(filterable: parent, common_tag: child)
    common_tagging.save(validate: false)

    expect { subject.invoke }.not_to raise_exception
    expect { common_tagging.reload }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  it "doesn't delete valid CommonTaggings" do
    parent = create(:canonical_fandom)
    child = create(:character)
    common_tagging = CommonTagging.create(filterable: parent, common_tag: child)

    expect { subject.invoke }.not_to raise_exception
    expect { common_tagging.reload }.not_to raise_exception
  end
end

describe "rake Tag:destroy_invalid_meta_taggings" do
  it "deletes MetaTaggings with a missing child" do
    parent = create(:canonical_fandom)
    child = create(:canonical_fandom)
    meta_tagging = MetaTagging.create(meta_tag: parent, sub_tag: child)
    child.delete

    expect { subject.invoke }.not_to raise_exception
    expect { meta_tagging.reload }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  it "deletes MetaTaggings with a missing parent" do
    parent = create(:canonical_fandom)
    child = create(:canonical_fandom)
    meta_tagging = MetaTagging.create(meta_tag: parent, sub_tag: child)
    parent.delete

    expect { subject.invoke }.not_to raise_exception
    expect { meta_tagging.reload }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  it "deletes MetaTaggings with a non-canonical child" do
    parent = create(:canonical_fandom)
    child = create(:fandom)
    meta_tagging = MetaTagging.new(meta_tag: parent, sub_tag: child)
    meta_tagging.save(validate: false)

    expect { subject.invoke }.not_to raise_exception
    expect { meta_tagging.reload }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  it "deletes MetaTaggings with a non-canonical parent" do
    parent = create(:fandom)
    child = create(:canonical_fandom)
    meta_tagging = MetaTagging.new(meta_tag: parent, sub_tag: child)
    meta_tagging.save(validate: false)

    expect { subject.invoke }.not_to raise_exception
    expect { meta_tagging.reload }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  it "deletes MetaTaggings with mismatched types" do
    parent = create(:canonical_character)
    child = create(:canonical_fandom)
    meta_tagging = MetaTagging.new(meta_tag: parent, sub_tag: child)
    meta_tagging.save(validate: false)

    expect { subject.invoke }.not_to raise_exception
    expect { meta_tagging.reload }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  it "doesn't delete valid MetaTaggings" do
    parent = create(:canonical_fandom)
    child = create(:canonical_fandom)
    meta_tagging = MetaTagging.create(meta_tag: parent, sub_tag: child)

    expect { subject.invoke }.not_to raise_exception
    expect { meta_tagging.reload }.not_to raise_exception
  end
end
