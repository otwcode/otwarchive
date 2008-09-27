ActiveRecord::Schema.define(:version => 1) do

	create_table :posts do |t|
		t.column :title, :string
		t.column :body, :text
		t.column :user_id, :integer
	end

	create_table :users do |t|
		t.column :name, :string
		t.column :email, :string
		t.column :company_id, :integer
	end

	create_table :companies do |t|
		t.column :name, :string
	end

	create_table :addresses do |t|
		t.column :address, :string
		t.column :city, :string
		t.column :state, :string
		t.column :zip, :string
		t.column :company_id, :integer
	end

	create_table :tags do |t|
		t.column :name, :string
	end

	create_table :posts_tags, id => false do |t|
		t.column :post_id, :integer
		t.column :tag_id, :integer
	end

end