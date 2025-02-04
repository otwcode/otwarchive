# frozen_string_literal: true

class IncreaseTagNameLimit < ActiveRecord::Migration[7.0]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def up
    change_column :tags, :name, :string, limit: 150
  end

  def down
    # This is only safe to run if no users have created tags with names > 100 characters.
    # Otherwise, tags wil need to be renamed first and _then_ this migration torn down.
    change_column :tags, :name, :string, limit: 100
  end
end
