require 'test/unit'
require File.dirname(__FILE__) + "/test_helper.rb"
require File.dirname(__FILE__) + "/../init.rb"

class Post < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :tags
end

class User < ActiveRecord::Base
  belongs_to :company
  has_many :posts
end

class Company < ActiveRecord::Base
  has_many :users
  has_many :addresses
end

class Address < ActiveRecord::Base
  belongs_to :company
end

class Tag < ActiveRecord::Base
	has_and_belongs_to_many :posts
end

class SquirrelTest < Test::Unit::TestCase
  load_all_fixtures

  def test_simple_operators
		# Sanity Check
		posts = Post.find(:all)
		assert_equal 7, posts.length
    assert_equal 1, posts.first.id
		
    posts = Post.find(:all) { id == 1 }
		assert_equal 1, posts.length
    assert posts.all?{|p| p.id == 1 }

    posts = Post.find(:all) { -id == 1 }
    assert ! posts.empty?
    assert ! posts.any?{|p| p.id == 1 }

    posts = Post.find(:all) { title =~ "%Rails%" }
    assert_equal 2, posts.length
  end

	def test_simple_conditions_generate_the_proper_query_fragments
		query = Address.find(:query) do
			id == 1
			id === [2,3,4]
			city == nil
			city =~ "Cam%"
			city =~ /bridge/
			zip > "02143"
			id < 4
			id <=> (1..3)
		end
		conditions = query.conditions.conditions
		[
			["addresses.id = ?", 1],
			["addresses.id IN (?)", [2,3,4]],
			["addresses.city IS NULL"],
			["addresses.city LIKE ?", "Cam%"],
			["addresses.city REGEXP ?", "bridge"],
			["addresses.zip > ?", "02143"],
			["addresses.id < ?", 4],
			["addresses.id BETWEEN ? AND ?", 1, 3]
		].each_with_index do |ary, i|
			assert_equal conditions[i].to_find_conditions, ary
		end
	end
	
	def test_conjunction_blocks_join_with_correct_words
		query = Tag.find(:query) do
			any {
				id == 1
				id == 2
				all {
					name == "Stuff"
					name == "Rails"
				}
			}
			any {
				name == "Things"
				id == 3
			}
		end
		assert_equal ["((tags.id = ? OR tags.id = ? OR (tags.name = ? AND tags.name = ?))" +
                  " AND (tags.name = ? OR tags.id = ?))",
                  1,
                  2,
                  "Stuff",
                  "Rails",
                  "Things",
                  3],
		             query.conditions.to_find_conditions
	end
	
	def test_negation_by_not
		query = Company.find(:query) do
			any.not { id == 1; id == 2 }
			id.not == 3
		end
		assert_equal ["(NOT (companies.id = ?) AND NOT (companies.id = ? OR companies.id = ?))", 3, 1, 2],
                 query.conditions.to_find_conditions
	end

	def test_negation_by_minus
		query = Company.find(:query) do
			-any { id == 1; id == 2 }
			-id == 3
		end
		assert_equal ["(NOT (companies.id = ?) AND NOT (companies.id = ? OR companies.id = ?))", 3, 1, 2],
                 query.conditions.to_find_conditions
	end
	
	def test_ordering
		query = Address.find(:query) { order_by id }
		assert_equal "addresses.id", query.conditions.to_find_order
		
		query = Address.find(:query) { order_by -id }
		assert_equal "addresses.id DESC", query.conditions.to_find_order
		
		query = Address.find(:query) { order_by state, -id }
		assert_equal "addresses.state, addresses.id DESC", query.conditions.to_find_order
		
		query = Address.find(:query) { order_by -state, id, address.desc, company.name }
		assert_equal "addresses.state DESC, addresses.id, addresses.address DESC, companies.name", 
                 query.conditions.to_find_order
		
		query = Address.find(:query) { id == 1 }
		assert_equal nil, query.conditions.to_find_order
	end
	
	def test_extra_parameters
		# Get 6 posts
		posts = Post.find(:all) { id <=> (1..6) }
		assert_equal 6, posts.length
		
		# Select 6, but Limit to 3 posts
		posts = Post.find(:all, :limit => 3) { id <=> (1..6) }
		assert_equal 3, posts.length
		
		# Make sure the original find still works.
		posts = Post.find(:all, :conditions => "id = 2")
		assert_equal 1, posts.length
		assert_equal 2, posts.first.id
	end
	
	def test_does_not_include_paginator_on_non_paged_queries
	  assert posts = Post.find(:all) { id <=> (1..6) }
	  assert_raises(NoMethodError){ posts.pages }
	  assert_raises(NoMethodError){ posts.total_results }
  end
	
	def test_does_include_paginator_on_paged_queries
	  assert posts = Post.find(:all) { id <=> (1..6); paginate :page => 2, :per_page => 4 }
	  assert_not_nil posts.pages
	  assert_not_nil posts.total_results
	end
	
	def test_paginator_low_edge_cases
	  pages = Squirrel::Paginator.new(:count => 100, :offset => 0, :limit => 1)
	  assert_equal 100,    pages.last
	  assert_equal 1,      pages.current
	  assert_equal 1,      pages.first
	  assert_equal (1..1), pages.current_range
	end
	
	def test_paginator_high_edge_cases
	  pages = Squirrel::Paginator.new(:count => 100, :offset => 99, :limit => 1)
	  assert_equal 100,        pages.last
	  assert_equal 100,        pages.current
	  assert_equal 1,          pages.first
	  assert_equal (100..100), pages.current_range
  end
	
	def test_pages_are_sane
	  assert posts = Post.find(:all) { id <=> (1..6); paginate :page => 2, :per_page => 4 }
	  assert_not_nil       posts.pages
	  assert_equal 2,      posts.pages.last
	  assert_equal 2,      posts.pages.current
	  assert_equal 6,      posts.total_results
	  assert_equal 6,      posts.pages.total_results
	  assert_nil           posts.pages.next
	  assert_equal 1,      posts.pages.previous
	  assert_equal (5..6), posts.pages.current_range
	  
	  assert posts = Post.find(:all) { id <=> (1..6); paginate :page => 1, :per_page => 4 }
	  assert_not_nil       posts.pages
	  assert_equal 2,      posts.pages.last
	  assert_equal 1,      posts.pages.current
	  assert_equal 6,      posts.total_results
	  assert_equal 6,      posts.pages.total_results
	  assert_equal 2,      posts.pages.next
	  assert_nil           posts.pages.previous
	  assert_equal (1..4), posts.pages.current_range
  end

  def test_will_paginator_works_like_squirrel_paginator
	  assert posts = Post.find(:all) { id <=> (1..6); paginate :page => 2, :per_page => 4 }
    [ :next_page,
      :offset,
      :out_of_bounds?,
      :page_count,
      :previous_page, 
      :replace, 
      :total_entries= ].each do |m|
      assert posts.respond_to?(m)
    end

    assert_equal posts.pages.next,     posts.next_page
    assert_equal posts.pages.previous, posts.previous_page
    assert_equal posts.total_results,  posts.total_entries
  end
  
  def test_passing_extra_conditions
    assert posts = Post.find(:all, :conditions => "id = 3"){ id <=> (1..6) }
    assert_equal [3],  posts.map{|p| p.id }
  end
  
  def test_pagination_through_hash_parameter
    posts = Post.find(:all, :paginate => {:page => 2, :per_page => 2})
    assert_equal 2, posts.size
    assert_not_nil  posts.pages
    assert_equal 1, posts.pages.first
    assert_equal 4, posts.pages.last
    assert_equal 3, posts.first.id  
  end
	
	def test_relationships
    query = User.find(:query) do
      id == 1
      company.id == 2
      posts.id == 3
      company.addresses.id == 4
      company.users.id == 5
      posts.user.id == 6
    end
    assert_equal( {:company => {:addresses => {}, :users => {}}, :posts => {:user => {}}}, query.to_find_include )
    assert_equal(["(users.id = ? AND (companies.id = ?) AND (posts.id = ?)" + 
                  " AND ((addresses.id = ?)) AND ((users_companies.id = ?))" + 
                  " AND ((users_posts.id = ?)))",
                  1,
                  2,
                  3,
                  4,
                  5,
                  6],
                 query.to_find_conditions)
	end

  def test_has_many_proxy_associations
    user = User.find(2)
    query = user.posts.find(:query){ body.contains? "Rails" }
    assert_equal ["(posts.body LIKE ?)", "%Rails%"], query.to_find_conditions
    assert_equal( {}, query.to_find_include )

    assert_equal [Post.find(2), Post.find(5)], query.execute(:all)
  end

  def test_joins_inside_proxy_associations
    user = User.find(2)
    query = user.posts.find(:query){
      body.contains? "Ruby"
      tags.name == "Nothing"
    }
    assert_equal ["(posts.body LIKE ? AND (tags.name = ?))", "%Ruby%", "Nothing"], query.to_find_conditions
    assert_equal( {:tags => {}}, query.to_find_include )

    assert_equal [Post.find(7)], query.execute(:all)
  end

  def test_scopes_work_like_find_does
    assert_equal( {:conditions => User.find(:query){ id == 2 }.to_find_conditions},
                  User.scoped{ id == 2 }.proxy_options)
  end

  def test_scopes_can_be_nested
    assert_equal(User.find(1),
                 User.scoped{ name =~ "Jon%" }.scoped{ id < 3 }.first)
  end

  def test_conditions_can_be_rvalues
    query = User.find(:query){ posts.body == posts.tags.name }
    assert_equal ["((posts.body = tags.name))"], query.to_find_conditions
  end
end
