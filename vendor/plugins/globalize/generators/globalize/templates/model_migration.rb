<%#:mode=rhtml: %>
class <%= migration_class_name %> < ActiveRecord::Migration
  def self.up
<% attributes_for_migrations.each_key do |key| -%>
    #Fields for <%= key.split('/').first %>
<% attributes_for_migrations[key].each do |field_data| -%>
    add_column :<%= key.split('/').last %>, :<%= field_data[0] %>, :<%= field_data[1] %><%= ", :default => #{field_data[2].blank? ? "''" : field_data[2]}" %>
<% end -%>
<% end -%>
  end

  def self.down
<% attributes_for_migrations.each_key do |key| -%>
    #Fields for <%= key.split('/').first %>
<% attributes_for_migrations[key].each do |field_data| -%>
    remove_column :<%= key.split('/').last %>, :<%= field_data[0] %>
<% end -%>
<% end -%>
  end
end