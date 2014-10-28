require 'spec_helper'

describe Admin, :ready do

   context 'edit_user' do
     let(:existing_user) { create(:user) }
     let(:admin)         { create(:admin) }
     before do
       visit '/admin/login'
       fill_in 'Admin user name', with: "#{admin.login}"
       fill_in 'Admin password', with: 'password'
       click_button 'Log in as admin'
     end
     after do 
       visit '/admin/logout'
     end

     it 'find a user in the admin interface' do
       fill_in 'Name or email', with: "#{existing_user.email}"
       click_button 'Find'
       page.should have_content('1 user found')
     end
 
     it 'suspend a user without a note' do
       visit "/admin/users/#{existing_user.login}"
       choose 'admin_action_suspend'
       fill_in 'suspend_days', with: '5'
       click_button 'Update'
       page.should have_content('You must include notes in order to perform this action')
     end

     it 'suspend a user' do
       visit "/admin/users/#{existing_user.login}"
       choose 'admin_action_suspend'
       fill_in 'suspend_days', with: '5'
       fill_in 'admin_note', with: 'This poor user is victimised'
       click_button 'Update'
       page.should have_content('This poor user is victimised')
       page.should have_content('User has been temporarily suspended')
       choose 'admin_action_unsuspend'
       fill_in 'admin_note', with: 'This poor user is victimised so let them play'
       click_button 'Update'
       page.should have_content('This poor user is victimised so let them play')
       page.should have_content('Suspension has been lifted')
     end

     it 'ban a user' do
       visit "/admin/users/#{existing_user.login}"
       choose 'admin_action_ban'
       fill_in 'admin_note', with: 'This poor user is very naughty'
       click_button 'Update'
       page.should have_content('User has been permanently suspended')
       page.should have_content('This poor user is very naughty')
       choose 'admin_action_unban'
       fill_in 'admin_note', with: 'This poor user is has promised to be good'
       click_button 'Update'
       page.should have_content('This poor user is has promised to be good')
       page.should have_content('Suspension has been lifted')
     end

     it 'record a warning' do
       visit "/admin/users/#{existing_user.login}"
       choose 'admin_action_warn'
       fill_in 'admin_note', with: 'This poor user is annoying me'
       click_button 'Update'
       page.should have_content('This poor user is annoying me')
       page.should have_content('Warning was recorded')
     end

     it 'hide and show a work' do
       work = FactoryGirl.create(:work)
       visit "/admin/user_creations/#{work.id}/hide?creation_type=Work&hidden=true"
       page.should have_content('Item has been hidden.')
       visit "/admin/user_creations/#{work.id}/hide?creation_type=Work&hidden=false"
       page.should have_content('Item is no longer hidden.')
     end

  end
end
