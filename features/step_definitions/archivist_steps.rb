### GIVEN

Given /^I have an archivist "([^\"]*)"$/ do |name|
  Given %{I am logged in as "#{name}"}
    And %{I have loaded the "roles" fixture}
  When %{I am logged in as an admin}
      And %{I fill in "query" with "elynross"}
      And %{I press "Find"}
    When %{I check "user_roles_4"}
      And %{I press "Update"}
      And %{I follow "Log out"}
end

### WHEN

### THEN

Then /^the email should contain invitation warnings$/ do
  Then %{the email should contain "Hello from the Archive of Our Own!"}
  Then %{the email should contain "elynross has backed up a fanfiction archive to the Archive of Our Own, and their"}
  Then %{the email should contain "archive includes some of your works. This gets you an automatic invitation to our site"}
  Then %{the email should contain "you would like to join; if so, when you create your account using this invitation, you will"}
  Then %{the email should contain "find all of your uploaded stories in your account."}
  Then %{the email should contain "Please note: by default, when an archivist backs up an archive to the AO3, all of the works"}
  Then %{the email should contain "are locked to registered users only, so your works will not appear in Google searches"}
  Then %{the email should contain "We hope that you don't mind having your stories backed up or transferred onto the AO3, but if you"}
  Then %{the email should contain "do, you don't need to create an account to remove them -- you can just follow the link and you will"}
  Then %{the email should contain "be given the option to orphan or delete your stories."}
  Then %{the email should contain "Orphaning allows you to remove your name from"}
  Then %{the email should contain "your stories while leaving them on the Archive."}
  Then %{the email should contain "You can also choose not to be notified in future when"}
  Then %{the email should contain "stories are imported with this email address, and/or to block any future stories for"}
  Then %{the email should contain "this email address from being imported into the archive."}
  Then %{the email should contain "If your stories have been uploaded by someone you never gave permission to archive, let us know!"}
  Then %{the email should contain "We only offer this backup service to archivists who run archives where writers either upload stories"}
  Then %{the email should contain "for themselves or give permission to archive."}
  Then %{the email should contain "That Shall Achieve The Sword"}
  Then %{the email should contain "Merlin UK"}
end
