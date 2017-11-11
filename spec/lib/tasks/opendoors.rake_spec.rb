require 'spec_helper'
require 'rake'

describe 'Update imported urls' do
  before do
    @rake = Rake.application
    begin
      @rake.init
    rescue SystemExit
    end
    @rake.load_rakefile
  end

  context "Rake task" do
    it 'runs and takes a parameter' do
      task_name = "opendoors:import_url_mapping"
      expect(@rake[task_name].prerequisites).to include("environment")
      @rake[task_name].invoke("foo")
    end
  end
  
  context "UrlUpdater" do
    let(:url_updater) { UrlUpdater.new }
    let(:work_with_temp_url) { create(:work, imported_from_url: "http://temp/1") }
    let(:work_with_no_url) { create(:work, imported_from_url: nil) }
    let(:work_with_other_url) { create(:work, imported_from_url: "http://another/1") }
    
    it "returns an error if the work is not found" do
      row = {
        "URL Imported From" => "http://temp/1",
        "Original URL" => "http://another/2",
        "AO3 id" => 7777773
      }
      result = url_updater.update_work(row)
      expect(result).to eq("7777773\twas not changed: Couldn't find Work with 'id'=7777773")
    end
    
    it "returns a message if the work already has another imported URL" do
      row = {
        "URL Imported From" => "http://temp/1",
        "Original URL" => "http://another/2",
        "AO3 id" => work_with_other_url.id
      }
      result = url_updater.update_work(row)
      expect(result).to match("\\d+\twas not changed: its import url is http://another/1")
    end
    
    it "updates the work if it has no imported URL" do
      row = {
        "URL Imported From" => "http://temp/1",
        "Original URL" => "http://another/2",
        "AO3 id" => work_with_no_url.id
      }
      result = url_updater.update_work(row)
      expect(result).to match("\\d+\twas updated: its import url is now http://another/2")
    end
    
    it "updates the work if it has the temp site imported URL" do
      row = {
        "URL Imported From" => "http://temp/1",
        "Original URL" => "http://another/2",
        "AO3 id" => work_with_temp_url.id
      }
      result = url_updater.update_work(row)
      expect(result).to match("\\d+\twas updated: its import url is now http://another/2")
    end
  end
end
