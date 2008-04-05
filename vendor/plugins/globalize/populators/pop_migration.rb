ENV["RAILS_ENV"] = 'development'
require 'config/environment'
include Globalize

# This isn't currently being used

model = Language
items = model.find(:all)
fields = model.column_names

recs = []
items.each do |i|
  atts = i.attributes_before_type_cast
  ary = fields.map {|f| atts[f] }
  recs.push(ary.inspect)
end

puts "[\n  " + recs.join(",\n  ") + "\n]" 