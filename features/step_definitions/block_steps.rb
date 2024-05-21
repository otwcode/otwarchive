Given "the user {string} has blocked the user {string}" do |blocker, blocked|
  blocker = ensure_user(blocker)
  blocked = ensure_user(blocked)
  Block.create!(blocker: blocker, blocked: blocked)
end

Given "there are {int} blocked users per page" do |amount|
  allow(Block).to receive(:per_page).and_return(amount)
end

Given "the maximum number of accounts users can block is {int}" do |count| 
  allow(ArchiveConfig).to receive(:MAX_BLOCKED_USERS).and_return(count) 
end

Then "the user {string} should have a block for {string}" do |blocker, blocked|
  blocker = User.find_by(login: blocker)
  blocked = User.find_by(login: blocked)
  expect(Block.find_by(blocker: blocker, blocked: blocked)).to be_present
end

Then "the user {string} should not have a block for {string}" do |blocker, blocked|
  blocker = User.find_by(login: blocker)
  blocked = User.find_by(login: blocked)
  expect(Block.find_by(blocker: blocker, blocked: blocked)).to be_blank
end

Then "the blurb should say when {string} blocked {string}" do |blocker, blocked|
  blocker = User.find_by(login: blocker)
  blocked = User.find_by(login: blocked)
  block = Block.where(blocker: blocker, blocked: blocked).first
  # Find the blurb for the specified block using the h4 with the blocked user's name, navigate back up to div, and then down to the datetime p
  expect(page).to have_xpath("//li/div/h4/a[text()[contains(., '#{blocked.login}')]]/parent::h4/parent::div/p[text()[contains(., '#{block.created_at}')]]")
end

Then "the blurb should not say when {string} blocked {string}" do |blocker, blocked|
  blocker = User.find_by(login: blocker)
  blocked = User.find_by(login: blocked)
  block = Block.where(blocker: blocker, blocked: blocked).first
  # Find the blurb for the specified block using the h4 with the blocked user's name, navigate back up to div, and then down to where the datetime p would be
  expect(page).not_to have_xpath("//li/div/h4/a[text()[contains(., '#{blocked.login}')]]/parent::h4/parent::div/p[text()[contains(., '#{block.created_at}')]]")
end
