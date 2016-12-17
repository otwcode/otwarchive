require 'faker'

FactoryGirl.define do
  factory :related_work do
    parent_type "Work"
    parent_id { FactoryGirl.create(:work).id }
    work_id { FactoryGirl.create(:work).id }
  end

  factory :related_work_known_parent do
    parent_creator { FactoryGirl.create(:user) }
    parent_work { FactoryGirl.create(:work, authors: [parent_creator.default_pseud]) }
    parent_work { FactoryGirl.create(:related_work, work_id: parent_work.id) }
  end

  factory :related_work_known_child do
    child_creator { FactoryGirl.create(:user) }
    child_work { FactoryGirl.create(:work, authors: [child_creator.default_pseud]) }
    related_work { FactoryGirl.create(:related_work, work_id: child_work.id) }
  end
end