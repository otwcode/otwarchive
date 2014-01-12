Then /^I should receive a file of type "([^"]*)"$/ do |filetype|
  page.driver.response.headers['Content-Disposition'].should =~ /filename=.+\.#{filetype}/
  page.response_headers['Content-Type'].should == MIME::Types.type_for("foo.#{filetype}").first
end

Then /^I should be able to download all versions of "(.*)"$/ do |title|
  (ArchiveConfig.DOWNLOAD_FORMATS_COMMON + ArchiveConfig.DOWNLOAD_FORMATS_EXTRA - ['html']).each do |filetype|
    step %{I should be able to download the #{filetype} version of "#{title}"}
  end
end

Then /^I should be able to download the (\w+) version of "(.*)"$/ do |filetype, title|
  work = Work.find_by_title(title)
  visit work_url(work)
  step %{I follow "#{filetype.upcase}"}
  filename = "#{work.download_basename}.#{filetype}" # the full path of the download file we expect to exist
  assert File.exists?(filename)
  page.driver.response.headers['Content-Disposition'].should =~ /filename=\"#{File.basename(filename)}\"/
  page.response_headers['Content-Type'].should == MIME::Types.type_for(filename).first
end

