Then /^I should receive a file of type "([^"]*)"$/ do |filetype|
  page.driver.response.headers['Content-Disposition'].should =~ /filename=.+\.#{filetype}/
  page.response_headers['Content-Type'].should == MIME::Types.type_for("foo.#{filetype}").first
end

Then /^I should be able to download all versions of "(.*)"$/ do |title|
  (ArchiveConfig.DOWNLOAD_FORMATS_COMMON + ArchiveConfig.DOWNLOAD_FORMATS_EXTRA - ['html']).each do |filetype|
    step %{I should be able to download the #{filetype} version of "#{title}"}
  end
end

Then /^I (?:should be able to )?download the (\w+) version of "(.*)"$/ do |filetype, title|
  work = Work.find_by_title(title)
  visit work_url(work)
  step %{I follow "#{filetype.upcase}"}
  filename = "#{work.download_basename}.#{filetype}" # the full path of the download file we expect to exist
  assert File.exists?(filename), "#{filename} does not exist"
  page.driver.response.headers['Content-Disposition'].should =~ /filename=\"#{File.basename(filename)}\"/
  page.response_headers['Content-Type'].should == MIME::Types.type_for(filename).first
end

Then /^I should not be able to download the (\w+) version of "(.*)"$/ do |filetype, title|
  work = Work.find_by_title(title)
  visit work_url(work)
  step %{I follow "#{filetype.upcase}"}
  filename = "#{work.download_basename}.#{filetype}" # the full path of the download file we expect to exist
  page.driver.response.headers['Content-Disposition'].should_not =~ /filename=\"#{File.basename(filename)}\"/
  page.response_headers['Content-Type'].should_not == MIME::Types.type_for(filename).first
end

Then /^I should not be able to manually download the (\w+) version of "(.*)"$/ do |filetype, title|
  work = Work.find_by_title(title)
  download_url = "#{ArchiveConfig.APP_URL}/#{work.download_folder}/#{work.download_title}.#{filetype}"
  filename = "#{work.download_basename}.#{filetype}" # the full path of the download file we expect to exist
  visit download_url
  page.driver.response.headers['Content-Disposition'].should_not =~ /filename=\"#{File.basename(filename)}\"/
  page.response_headers['Content-Type'].should_not == MIME::Types.type_for(filename).first
end

Then /^the (.*) version of "([^"]*)" should exist$/ do |filetype, title|
  work = Work.find_by_title(title)
  filename = "#{work.download_basename}.#{filetype}" # the full path of the download file we expect to exist
  assert File.exists?(filename), "#{filename} does not exist"
end

Then /^the (.*) version of "([^"]*)" should not exist$/ do |filetype, title|
  work = Work.find_by_title(title)
  filename = "#{work.download_basename}.#{filetype}" # the full path of the download file we expect to exist
  assert !File.exists?(filename), "#{filename} does exist"
end

When /^I try and fail to download the (\w+) version of "(.*)"$/ do |filetype, title|
  work = Work.find_by_title(title)
  download_url = "#{ArchiveConfig.APP_URL}/#{work.download_folder}/#{work.download_title}.#{filetype}?dont_generate_download=1"
  visit download_url
  filename = "#{work.download_basename}.#{filetype}" # the full path of the download file we expect to exist
  page.driver.response.headers['Content-Disposition'].should_not =~ /filename=\"#{File.basename(filename)}\"/
  page.response_headers['Content-Type'].should_not == MIME::Types.type_for(filename).first
end