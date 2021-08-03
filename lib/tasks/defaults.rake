namespace :defaults do
  desc "Create default roles by name"
  task(create_roles: :environment) do
    %w[archivist opendoors protected_user tag_wrangler translation_admin translator].each do |role|
      Role.find_or_create_by(name: role)
    end
  end
end
