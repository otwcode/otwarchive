Then /^the share modal should contain social share buttons$/ do
  with_scope("#share") do
    expect(page).to have_css("li.twitter", text: "Twitter")
    expect(page).to have_css("li.tumblr", text: "Tumblr")
  end
end

Then "the {word} share link should include {string}" do |site, text|
  href = CGI.unescape(find("#share li.#{site} a")[:href])
  expect(href).to include(text)
end

Then "the {word} share link should not include {string}" do |site, text|
  href = CGI.unescape(find("#share li.#{site} a")[:href])
  expect(href).not_to include(text)
end
