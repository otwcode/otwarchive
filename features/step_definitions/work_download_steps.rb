Then /^I should receive a file of type "([^"]*)"$/ do |filetype|
  mime_type = filetype == "azw3" ? "application/x-mobi8-ebook" : MIME::Types.type_for("foo.#{filetype}").first
  page.driver.response.headers['Content-Disposition'].should =~ /filename=.+\.#{filetype}/
  page.response_headers['Content-Type'].should == mime_type
end

Then /^I should be able to download all versions of "(.*)"$/ do |title|
  (ArchiveConfig.DOWNLOAD_FORMATS - ['html']).each do |filetype|
    step %{I should be able to download the #{filetype} version of "#{title}"}
  end
end

Then /^I (?:should be able to )?download the (\w+) version of "(.*)"$/ do |filetype, title|
  work = Work.find_by_title(title)
  download = Download.new(work, format: filetype)
  visit work_url(work)
  step %{I follow "#{filetype.upcase}"}
  filename = download.file_path # the full path of the download file we expect to exist
  mime_type = filetype == "azw3" ? "application/x-mobi8-ebook" : MIME::Types.type_for(filename).first
  assert File.exist?(filename), "#{filename} does not exist"
  page.driver.response.headers['Content-Disposition'].should =~ /filename=\"#{File.basename(filename)}\"/
  page.response_headers['Content-Type'].should == mime_type
end

Then /^I should not be able to download the (\w+) version of "(.*)"$/ do |filetype, title|
  work = Work.find_by_title(title)
  download = Download.new(work, format: filetype)
  visit work_url(work)
  step %{I follow "#{filetype.upcase}"}
  filename = download.file_path # the full path of the download file we expect to exist
  mime_type = filetype == "azw3" ? "application/x-mobi8-ebook" : MIME::Types.type_for(filename).first
  page.driver.response.headers['Content-Disposition'].should_not =~ /filename=\"#{File.basename(filename)}\"/
  page.response_headers['Content-Type'].should_not == mime_type
end

Then /^I should not be able to manually download the (\w+) version of "(.*)"$/ do |filetype, title|
  work = Work.find_by_title(title)
  download = Download.new(work, format: filetype)
  download_url = "#{ArchiveConfig.APP_URL}#{download.public_path}"
  filename = download.file_path # the full path of the download file we expect to exist
  mime_type = filetype == "azw3" ? "application/x-mobi8-ebook" : MIME::Types.type_for(filename).first
  visit download_url
  page.driver.response.headers['Content-Disposition'].should_not =~ /filename=\"#{File.basename(filename)}\"/
  page.response_headers['Content-Type'].should_not == mime_type
end

Then /^the (.*) version of "([^"]*)" should exist$/ do |filetype, title|
  work = Work.find_by_title(title)
  filename = "#{work.download_basename}.#{filetype}" # the full path of the download file we expect to exist
  assert Download.new(work, format: filetype).exists?, "#{filename} does not exist"
end

Then /^the (.*) version of "([^"]*)" should not exist$/ do |filetype, title|
  work = Work.find_by_title(title)
  assert !Download.new(work, format: filetype).exists?, "#{filename} does exist"
end
