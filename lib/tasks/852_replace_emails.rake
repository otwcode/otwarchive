namespace :massimport852 do
  desc "Replace emails in files"
  task(:replace_emails) do |t|
    require 'fileutils'
    src_dir = ""
    dest_dir = ""

    until src_dir.present? && Dir.exists?(src_dir)
      puts "Couldn't find source: #{src_dir}!"
      src_dir = ask("Please enter the SOURCE directory: ")
    end
    src_dir += '/' unless src_dir.match(/\/$/)


    until dest_dir.present? && Dir.exists?(dest_dir)
      puts "Couldn't find destination: #{dest_dir}!"
      dest_dir = ask("Please enter the DESTINATION base directory: ")
    end
    dest_dir += '/' unless dest_dir.match(/\/$/)

    puts "Source: " + src_dir
    puts "Destination: " + dest_dir

    #read current file to
    Dir.glob(src_dir + '**/*.html').each do |file|

      "File: " + file

      filedir = File.absolute_path(file, src_dir).slice((file.index('test/'))..file.index(file.split("/").last)-1)
      filename = file.split("/").last

      puts "filedir: " + filedir
      puts "filename: " + filename

      dest = File.join(dest_dir, filedir)
      FileUtils.mkdir_p(dest)

      puts "Output: " + dest

      storyfile = File.open(File.absolute_path(file))
      story = ""
      storyfile.each {|line|
        story << line
      }

      # assign stories to different email addresses (criteria to be defined)
      if filedir.match(/^test\/1/)
        newemail="test1@example.org"
      else
        newemail="test2@example.org"
      end
      oldemail=""
      
      if story.match(/<a href=(?:"|')?(mailto:|&#109;&#97;&#105;&#108;&#116;&#111;&#58;)?(.+@[^'">]+)(?:"|')?>(.+)<\/a>/i)
        oldemail = $2
      end
      # Replace emails with tester emails
      story.gsub!(/(<a href=(?:"|')?(mailto:|&#109;&#97;&#105;&#108;&#116;&#111;&#58;)?)(.+@[^'">]+)((?:"|')?>(.+)<\/a>)/i, '\1' + newemail + '\4')

      puts "Replaced " + oldemail + " with " + newemail


      @doc = Nokogiri::HTML.parse(story) rescue ""
      content = (@doc/"html").inner_html
      
      

      File.open(dest + filename, "w") do |f|
        f.write(content)
      end

    end

  end

end
