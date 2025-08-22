require "spec_helper"

describe "rake skins:cache_chooser_skins", default_skin: true do
  let(:css) { ".selector { color: yellow; }" }
  let!(:default_skin) { Skin.find(AdminSetting.default_skin_id) }
  let!(:chooser_skin) { create(:skin, in_chooser: true, css: css) }
  let!(:user_skin) { create(:skin, css: css) }

  it "calls cache! on in_chooser skins" do
    expect do
      subject.invoke
    end.to change { chooser_skin.reload.public }.from(false).to(true)
      .and change { chooser_skin.official }.from(false).to(true)
      .and change { chooser_skin.cached }.from(false).to(true)
      .and avoid_changing { default_skin.reload.public }
      .and avoid_changing { default_skin.official }
      .and change { default_skin.cached }.from(false).to(true)
      .and avoid_changing { user_skin.reload.public }
      .and avoid_changing { user_skin.official }
      .and avoid_changing { user_skin.cached }
  end

  it "outputs names of skins that were cached" do
    expect do
      subject.invoke
    end.to output("\nCached #{default_skin.title},#{chooser_skin.title}\n").to_stdout
  end

  it "outputs names of skins that could not be cached" do
    allow_any_instance_of(Skin).to receive(:cache!).and_return(false)
    expect do
      subject.invoke
    end.to output("\nCouldn't cache #{default_skin.title},#{chooser_skin.title}\n").to_stdout
  end
end

describe "rake skins:load_user_skins" do
  before do
    allow($stdin).to receive(:gets).and_return("n")

    allow(Skin).to receive(:skin_dir_entries).with(user_skin_path, anything).and_return(["test_skin.css", "child_skin.css"])
    allow(File).to receive(:read).with(/.*css/).and_return(
      "/* SKIN: Test Skin */",
      "/* SKIN: Child */\n/* PARENTS: Parent */"
    )

    allow(Skin).to receive(:skin_dir_entries).with(parent_skin_path, anything).and_return(["parent_skin.css"])
    allow(File).to receive(:read).with(/.*parent_skin\.css/).and_return("/* SKIN: Parent */\n#unused-selector { content: none; },")
  end

  it "creates parent-only skins from the specified directory" do
    subject.invoke

    parent_skin = Skin.find_by(title: "Parent")
    expect(parent_skin).not_to be nil
    expect(parent_skin.unusable).to be true
    expect(parent_skin.in_chooser).to be false
  end

  it "creates user skins in the specified directory and adds them to skin chooser" do
    subject.invoke

    skin = Skin.find_by(title: "Test Skin")
    child_skin = Skin.find_by(title: "Child")

    expect(skin).not_to be nil
    expect(skin.unusable).to be false
    expect(skin.in_chooser).to be true

    expect(child_skin).not_to be nil
    expect(child_skin.unusable).to be false
    expect(child_skin.in_chooser).to be true
    expect(child_skin.skin_parents.length).to eq(1)
    expect(child_skin.skin_parents.first.parent_skin.title).to eq("Parent")
  end
end
