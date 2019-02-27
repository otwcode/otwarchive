Then /^I should receive a file of type "(.*?)"$/ do |filetype|
  mime_type = filetype == "azw3" ? "application/x-mobi8-ebook" : MIME::Types.type_for("foo.#{filetype}").first
  page.driver.response.headers['Content-Disposition'].should =~ /filename=.+\.#{filetype}/
  page.response_headers['Content-Type'].should == mime_type
end

Then /^I should be able to download all versions of "(.*?)"$/ do |title|
  (ArchiveConfig.DOWNLOAD_FORMATS - ['html']).each do |filetype|
    step %{I should be able to download the #{filetype} version of "#{title}"}
  end
end

Then /^I should be able to download the (\w+) version of "(.*?)"$/ do |filetype, title|
  step %{time is frozen at this second}
  work = Work.find_by_title(title)
  download = Download.new(work, format: filetype)
  visit work_url(work)
  step %{I follow "#{filetype.upcase}"}
  step %{I jump in our Delorean and return to the present}

  filename = download.file_path # the full path of the download file we expect to exist
  mime_type = filetype == "azw3" ? "application/x-mobi8-ebook" : MIME::Types.type_for(filename).first
  assert File.exist?(filename), "#{filename} does not exist"
  page.driver.response.headers['Content-Disposition'].should =~ /filename=\"#{File.basename(filename)}\"/
  page.response_headers['Content-Type'].should == mime_type
end
