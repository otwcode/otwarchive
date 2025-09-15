class ChangeCollectionMultifandomAndOpenDoorsDefault < ActiveRecord::Migration[7.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    change_column_default :collections, :multifandom, from: nil, to: false
    change_column_default :collections, :open_doors, from: nil, to: false
  end
end
