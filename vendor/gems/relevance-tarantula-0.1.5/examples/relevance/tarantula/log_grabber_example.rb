require File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb")

describe 'Relevance::Tarantula::LogGrabber' do
  before do
    @grabber = Relevance::Tarantula::LogGrabber.new(log_file)
    FileUtils.mkdir_p(test_output_dir)
  end

  def log_file
    File.join(File.join(test_output_dir, "example.log"))
  end

  it "can clear the log file" do
    File.open(log_file, "w") {|f| f.print "sample log"}
    File.size(log_file).should == 10
    @grabber.clear!
    File.size(log_file).should == 0
  end

  it "can grab the log file" do
    File.open(log_file, "w") {|f| f.print "sample log"}
    @grabber.grab!.should == "sample log"
    File.size(log_file).should == 0
  end

end
