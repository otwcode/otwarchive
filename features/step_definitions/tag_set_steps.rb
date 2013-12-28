# encoding: utf-8

When /^I follow the add new tag ?set link$/ do
  step %{I follow "New Tag Set"}
end

# This takes strings like:
# ...with the fandom tags "x, y, z" and the character tags "a, b, c"
When /^I set up the tag ?set "([^\"]*)" with (.*)$/ do |title, tags|
  unless OwnedTagSet.find_by_title("#{title}").present?
    step %{I go to the new tag set page}
      fill_in("owned_tag_set_title", :with => title)
      fill_in("owned_tag_set_description", :with => "Here's my tagset")
      tags.scan(/the (\w+) tags "([^\"]*)"/).each do |type, tags|
        fill_in("owned_tag_set_tag_set_attributes_#{type}_tagnames_to_add", :with => tags)
      end
    step %{I submit}
    step %{I should see a create confirmation message}
  end
end

When /^I add (.*) to the tag ?set "([^\"]*)"$/ do |tags, title|
  step %{I go to the "#{title}" tag set edit page}
    tags.scan(/the (\w+) tags "([^\"]*)"/).each do |type, tags| 
      fill_in("owned_tag_set_tag_set_attributes_#{type}_tagnames_to_add", :with => tags)
    end
    step %{I submit}
  step %{I should see an update confirmation message}
end  

When /^I set up the nominated tag ?set "([^\"]*)" with (.*) fandom noms? and (.*) character noms?$/ do |title, fandom_count, char_count|
  unless OwnedTagSet.find_by_title("#{title}").present?
    step %{I go to the new tag set page}
      fill_in("owned_tag_set_title", :with => title)
      fill_in("owned_tag_set_description", :with => "Here's my tagset")
      check("Currently taking nominations?")
      fill_in("Fandom nomination limit", :with => fandom_count)
      fill_in("Character nomination limit", :with => char_count)
    step %{I submit}
    step %{I should see a create confirmation message}
  end
end

When /^I nominate (.*) fandoms and (.*) characters in the "([^\"]*)" tag ?set as "([^\"]*)"/ do |fandom_count, char_count, title, login|
  step %{I am logged in as "#{login}"}
  step %{I go to the "#{title}" tag set page}
  step %{I follow "Nominate"}
  1.upto(fandom_count.to_i) do |i|
    fill_in("Fandom #{i}", :with => "Blah #{i}")
    0.upto(char_count.to_i - 1) do |j|
      fill_in("tag_set_nomination_fandom_nominations_attributes_#{i-1}_character_nominations_attributes_#{j}_tagname", :with => "Foobar #{i} #{j}")
    end
  end
end

When /^I have (?:a|the) nominated tag ?set "([^\"]*)"/ do |title|
  step %{I am logged in as "tagsetter"}
  step %{I set up the nominated tag set "#{title}" with 3 fandom noms and 3 character noms}
  step %{I nominate 3 fandoms and 3 characters in the "#{title}" tagset as "nominator"}
  step %{I submit}
  step %{I should see a success message}
end

When /^I nominate fandoms? "([^\"]*)" and characters? "([^\"]*)" in "([^\"]*)"/ do |fandom, char, title|
  step %{I am logged in as "nominator"}
  step %{I go to the "#{title}" tag set page}
  step %{I follow "Nominate"}
  @fandoms = fandom.split(/, ?/)
  @chars = char.split(/, ?/)
  char_index = 0
  chars_per_fandom = @chars.size/@fandoms.size
  1.upto(@fandoms.size) do |i|
    fill_in("Fandom #{i}", :with => @fandoms[i-1])
    0.upto(chars_per_fandom - 1) do |j|
      fill_in("tag_set_nomination_fandom_nominations_attributes_#{i-1}_character_nominations_attributes_#{j}_tagname", :with => @chars[char_index])
      char_index += 1
    end
  end
  step %{I submit}
  step %{I should see a success message}
end
  
When /^I review nominations for "([^\"]*)"/ do |title|
  step %{I am logged in as "tagsetter"}
  step %{I go to the "#{title}" tag set page}
  step %{I follow "Review Nominations"}
end

When /^I review associations for "([^\"]*)"/ do |title|
  step %{I am logged in as "tagsetter"}
  step %{I go to the "#{title}" tag set page}
  step %{I follow "Review Associations"}
end
  
When /^I nominate and approve fandom "([^\"]*)" and character "([^\"]*)" in "([^\"]*)"/ do |fandom, char, title|
  step %{I am logged in as "tagsetter"}
  step %{I set up the nominated tag set "#{title}" with 3 fandom noms and 3 character noms}
  step %{I nominate fandom "#{fandom}" and character "#{char}" in "#{title}"}
  step %{I review nominations for "#{title}"}
  step %{I check "fandom_approve_#{fandom}"}
  step %{I check "character_approve_#{char}"}
  step %{I submit}
  step %{I should see "Successfully added to set: #{fandom}"}
  step %{I should see "Successfully added to set: #{char}"}
end

When /^I nominate and approve tags with Unicode characters in "([^\"]*)"/ do |title|
  tags = "The Hobbit - All Media Types, Dís, Éowyn, Kíli, Bifur/Óin, スマイルプリキュア, 新白雪姫伝説プリーティア".split(', ')
  step %{I am logged in as "tagsetter"}
  step %{I set up the nominated tag set "#{title}" with 7 fandom noms and 0 character noms}
  step %{I am logged in as "nominator"}
  step %{I go to the "#{title}" tag set page}
  step %{I follow "Nominate"}
  tags.each_with_index do |tag, i|
    fill_in("Fandom #{i+1}", :with => tag)
  end
  step %{I submit}
  step %{I should see a success message}
  step %{I review nominations for "#{title}"}
  tags.each do |tag|
    step %{I check "fandom_approve_#{tag}"}
  end
  step %{I submit}
  step %{I should see "Successfully added to set"}
end

When /^I should see the tags with Unicode characters/ do
  tags = "The Hobbit - All Media Types, Dís, Éowyn, Kíli, Bifur/Óin, スマイルプリキュア, 新白雪姫伝説プリーティア".split(', ')
  tags.each do |tag|
    step %{I should see "#{tag}"}
  end
end
