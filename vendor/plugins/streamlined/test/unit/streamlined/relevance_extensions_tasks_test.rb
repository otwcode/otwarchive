require File.expand_path(File.join(File.dirname(__FILE__), '../../test_helper'))
require 'rake'

# Test the install process that runs on install that copies over static files required by Streamlined
describe "Streamlined::RakeTasks" do
  RAKE_FILE = File.join(File.dirname(__FILE__), '../../../tasks/relevance_extensions_tasks.rake')

  # We test the install task using real files and real directories, because mocks are to easy to give
  # us "false passes" when the code really doesn't work for all edge cases.
  
  # we have a root directory we create in the tmp dir to do all our work in
  # we have a "source" there which we use as a sandbox to create our test files, and a "destination"
  # which would correspond to RAILS_ROOT in a real project
  attr_with_default(:root) { "#{Dir.tmpdir}/streamlined_test" }
  attr_with_default(:source) { "#{root}/src" }
  attr_with_default(:destination) { "#{root}/dest" }

  # our stub directories and files that we will create and test against
  attr_with_default(:source_directories)   { ["/CVS", "/images", "/images/.svn/", "/javascripts", "/javascripts/nested_js"] }
  attr_with_default(:should_be_copied)     { %w[readme.txt foo.rb images/logo.png javascripts/foo.js javascripts/nested_js/bar.js] }
  attr_with_default(:should_not_be_copied) { %w[.svn .DS_STORE /images/.svn/svn_meta_data] }
  
  
  def setup
    load RAKE_FILE

    create_directory [source, destination]
    create_source_directories
    # touch the test files
    (should_be_copied + should_not_be_copied).each { |path| FileUtils.touch "#{source}/#{path}" }
    
    # swap the original and the temp directories we are using for the test
    @original_source, Streamlined::Assets.source = Streamlined::Assets.source, source
    @original_destination, Streamlined::Assets.destination = Streamlined::Assets.destination, destination
  end

  def teardown
    # replace the source and dest with the original values
    Streamlined::Assets.source = @original_source
    Streamlined::Assets.destination = @original_destination
    # clean up after ourselves
    FileUtils.rm_r root
    should_not_exist root
  end
  
  it "install skips dot files and CVS metadata" do
    Streamlined::Assets.install
    
    should_be_copied.each { |path| should_exist(path) }
    should_not_be_copied.each { |path| should_not_exist(path) }
  end
  
  # lets make sure things work fine using rake invoke, since thats how install.rb does it
  it "should be able to install using rake invoke" do
    Rake::Task['streamlined:install_files'].invoke

    should_be_copied.each { |path| should_exist(path) }
    should_not_be_copied.each { |path| should_not_exist(path) }
  end
  
  private

  def create_source_directories
    self.source_directories = source_directories.map { |dir| "#{source}/#{dir}"}
    create_directories source_directories
  end
  
  def should_exist(path)
    assert File.exists?(full_destination_path(path)), "The path '#{full_destination_path(path)}' should exist but does not."
  end
  
  def should_not_exist(path)
    assert_false File.exists?(full_destination_path(path)), "The path '#{full_destination_path(path)}' should not exist but does."
  end
  
  def full_destination_path(path)
    File.join(destination, path)
  end
  
  # creates 1 to many directories if they don't exist
  def create_directories(paths)
    paths = Array(paths)
    paths.each { |path| FileUtils.mkdir_p path unless File.exists? path }
  end
  alias_method :create_directory, :create_directories
  

end
