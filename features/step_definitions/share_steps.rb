Then /^the share modal should contain social share buttons$/ do
  with_scope("#share") do
    expect(page).to have_css("li.twitter", text: "Twitter")
    expect(page).to have_css("li.tumblr", text: "Tumblr")
  end
end

Then /^the (twitter|tumblr) share link should( not)? include "([^"]*)"$/ do |site, notinclude, text|
  href = CGI.unescape(find("#share li.#{site} a")[:href])
  if notinclude
    expect(href).not_to include(text)
  else
    expect(href).to include(text)
  end
end
