
class Geo::Country < ActiveRecord::Base
  is_indexed :fields => ['name']
end
