# super useful for rspec testing with files, based on: http://blog.gabebw.com/2011/03/21/temp-files-in-rspec/
# see logfile_reader_spec.rb for usage
module UsesTempFiles
  def self.included(example_group)
    example_group.extend(self)
  end

  def in_directory_with_files(dirname, filenames)
    before do
      @pwd = Dir.pwd
      @tmp_dir = File.join(File.dirname(__FILE__), 'tmp')
      FileUtils.mkdir_p(@tmp_dir)
      Dir.chdir(@tmp_dir)
      
      # take off a leading / 
      @dirname = dirname.gsub(/^\//, '') 

      FileUtils.mkdir_p(@dirname)
      filenames.each do |filename| 
        FileUtils.touch(@dirname + filename)
      end
    end

    define_method(:content_for_file) do |filename, content|
      f = File.new(File.join(@tmp_dir, @dirname, filename), 'a+')
      f.write(content)
      f.flush # VERY IMPORTANT
      f.close
    end

    define_method(:mtime_for_file) do |filename, mtime|
      FileUtils.touch(@dirname + filename, mtime: mtime)
    end

    after do
      Dir.chdir(@pwd)
      FileUtils.rm_rf(@tmp_dir)
    end
  end
end
