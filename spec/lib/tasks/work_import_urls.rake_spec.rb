require "spec_helper"
require "rake"

describe "rake work_import_urls:backfill" do
  it "should import the urls" do
    work = create(:work)
    work.imported_from_url = "http://www.trickster.org/llwyden/misc/cracked.html"
    work.save!(validate: false)

    work_not_migrate = create(:work)
    work_not_migrate.imported_from_url = ""
    work_not_migrate.save!(validate: false)

    subject.invoke

    expect(ImportedUrl.count).to eq(1)
    expect(ImportedUrl.first.original).to eq(work.imported_from_url)

    subject.invoke

    expect(ImportedUrl.count).to eq(1)
  end
end
