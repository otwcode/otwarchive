require 'spec_helper'

describe DownloadableOwner do
  before(:each) do
    @author = User.find_by_login("someone") ||
      FactoryGirl.create(:user, login: "someone", email: "someone@somewhere.com")
    @work = FactoryGirl.create(:work, authors: [@author.pseuds.first])
    FileUtils.mkdir_p @work.download_dir
    @filename = @work.download_basename + ".mobi"
    FileUtils.touch(@filename)
    expect(File.exists?(@filename)).to be_true
  end
  
  it "will clean up downloads when the pseud name is changed" do
    @author.pseuds.first.name = "someone_else" 
    @author.pseuds.first.save
    expect(File.exists?(@work.download_dir)).to be_false
  end
  
  it "will clean up downloads when the login is changed" do
    @author.login = "someone_new"
    @author.save
    expect(File.exists?(@work.download_dir)).to be_false
  end

  it "will clean up downloads when the work is orphaned" do
    Creatorship.orphan(@author.pseuds, [@work])
    expect(File.exists?(@work.download_dir)).to be_false
  end

end