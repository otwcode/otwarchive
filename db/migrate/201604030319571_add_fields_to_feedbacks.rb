class AddFieldsToFeedbacks < ActiveRecord::Migration
  def change
    add_column    :feedbacks, :username, :string
    add_column    :feedbacks, :language, :string
  end
end
