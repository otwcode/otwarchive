namespace :login do
  desc 'update database last_login for users from redis'
  task(to_database: :environment) do
    User.update_last_login
  end
end
