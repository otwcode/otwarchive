require "spec_helper"

describe "rake skins:cache_chooser_skins", default_skin: true do
  let(:css) { ".selector { color: yellow; }" }
  let!(:default_skin) { Skin.find(AdminSetting.default_skin_id) }
  let!(:chooser_skin) { create(:skin, in_chooser: true, css: css) }
  let!(:user_skin) { create(:skin, css: css) }

  it "calls cache! on in_chooser skins" do
    expect do
      subject.invoke
    end.to change { chooser_skin.reload.public }
      .from(false).to(true)
      .and change { chooser_skin.official }
      .from(false).to(true)
      .and change { chooser_skin.cached }
      .from(false).to(true)
      .and avoid_changing { default_skin.reload.public }
      .and avoid_changing { default_skin.official }
      .and change { default_skin.cached }
      .from(false).to(true)
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

describe "rake skins:clear_unofficial_public_skins" do
  let!(:unapproved_site_skin) { create(:skin) }
  let!(:rejected_site_skin) { create(:skin, rejected: true) }
  let!(:approved_site_skin) { create(:skin, official: true) }
  let!(:unapproved_work_skin) { create(:work_skin) }
  let!(:rejected_work_skin) { create(:work_skin, rejected: true) }
  let!(:approved_work_skin) { create(:work_skin, official: true) }

  # Skins can't be public unless they have preview images, so we need to set
  # public to true after creation while skipping the validation.
  before do
    Skin.all.each do |skin|
      skin.public = true
      skin.save(validate: false)
    end
  end

  it "sets public to false on unapproved skins" do
    expect do
      subject.invoke
    end.to change { unapproved_site_skin.reload.public }
      .from(true).to(false)
      .and change { unapproved_work_skin.reload.public }
      .from(true).to(false)
      .and output("Finished clearing unofficial public skins.\n").to_stdout
  end

  it "sets public and rejected to false on rejected skins" do
    expect do
      subject.invoke
    end.to change { rejected_site_skin.reload.public }
      .from(true).to(false)
      .and change { rejected_site_skin.rejected }
      .from(true).to(false)
      .and change { rejected_work_skin.reload.public }
      .from(true).to(false)
      .and change { rejected_work_skin.rejected }
      .from(true).to(false)
      .and output("Finished clearing unofficial public skins.\n").to_stdout
  end

  it "doesn't change approved skins" do
    expect do
      subject.invoke
    end.to avoid_changing { approved_site_skin.reload.public }
      .and avoid_changing { approved_work_skin.reload.public }
      .and output("Finished clearing unofficial public skins.\n").to_stdout
  end
end
