Given "the user {string} has muted the user {string}" do |muter, muted|
  muter = ensure_user(muter)
  muted = ensure_user(muted)
  Mute.create!(muter: muter, muted: muted)
end

Given "there are {int} muted users per page" do |amount|
  allow(Mute).to receive(:per_page).and_return(amount)
end

Given "the maximum number of accounts users can mute is {int}" do |count| 
  allow(ArchiveConfig).to receive(:MAX_MUTED_USERS).and_return(count) 
end 

Then "the user {string} should have a mute for {string}" do |muter, muted|
  muter = User.find_by(login: muter)
  muted = User.find_by(login: muted)
  expect(Mute.find_by(muter: muter, muted: muted)).to be_present
end

Then "the user {string} should not have a mute for {string}" do |muter, muted|
  muter = User.find_by(login: muter)
  muted = User.find_by(login: muted)
  expect(Mute.find_by(muter: muter, muted: muted)).to be_blank
end

Then "the blurb should say when {string} muted {string}" do |muter, muted|
  muter = User.find_by(login: muter)
  muted = User.find_by(login: muted)
  mute = Mute.where(muter: muter, muted: muted).first
  # Find the blurb for the specified mute using the h4 with the muted user's name, navigate back up to div, and then down to the datetime p
  expect(page).to have_xpath("//li/div/h4/a[text()[contains(., '#{muted.login}')]]/parent::h4/parent::div/p[text()[contains(., '#{mute.created_at}')]]")
end

Then "the blurb should not say when {string} muted {string}" do |muter, muted|
  muter = User.find_by(login: muter)
  muted = User.find_by(login: muted)
  mute = Mute.where(muter: muter, muted: muted).first
  # Find the blurb for the specified mute using the h4 with the muted user's name, navigate back up to div, and then down to where the datetime p would be
  expect(page).not_to have_xpath("//li/div/h4/a[text()[contains(., '#{muted.login}')]]/parent::h4/parent::div/p[text()[contains(., '#{mute.created_at}')]]")
end
