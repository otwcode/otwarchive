require File.expand_path(File.join(File.dirname(__FILE__), '../test_functional_helper'))
require 'relevance/active_record_extensions'

describe "ActiveRecordExtensions" do
  fixtures :people, :poets, :poems
                         
  it "returns delegate target associations for delegate targets that are associations" do
    assoc = Authorship.reflect_on_association(:author)          
    assoc.should.not == nil
    assocs = Authorship.delegate_target_associations.should == [assoc]
  end
  
  it "can find by like" do
    assert_equal [people(:justin)], Person.find_by_like('Just', Person.user_columns)
    assert_equal [people(:justin)], Person.find_by_like('land', Person.user_columns)
    assert_equal [], Person.find_by_like('wibble', Person.user_columns)
  end
  
  it "gets the correct number of has one relationships" do
    Poet.has_ones.should.be.blank
    Person.has_ones.should.be.blank
  end

  it "gets the correct number of has many relationships" do
    Poet.has_manies.map(&:name).should == [:poems]
    Person.has_manies.should.be.blank
  end

  it "ignores 1-1 relationships when excluding throughs (regression!)" do
    Poem.has_manies(:exclude_has_many_throughs => true).should.be.blank
  end
  
  it "can exclude has_many_through when getting has many relationships" do
    Author.has_manies(:exclude_has_many_throughs => true).should == [Author.reflect_on_association(:authorships)]
  end  
  
  it "finds all records when given a blank template record" do
    Person.find_by_criteria(Person.new).size.should == Person.count
  end
  
  it "finds matching records using the template criteria" do
    Person.find_by_criteria(Person.new(:first_name=>'usti')).should == [people(:justin)]
  end
  
  # The doubling ('%%') is to work around Rails. Some of Rails Connection.quote
  # code paths call sprintf, others do not. 
  it "quotes properly when finding conditions by like" do
    expected = "first_name LIKE #{ActiveRecord::Base.connection.quote("%%in 'quotes'%%")} OR last_name LIKE #{ActiveRecord::Base.connection.quote("%%in 'quotes'%%")}"
    
    Person.conditions_by_like("in 'quotes'").should == expected
    Person.conditions_by_like("in 'quotes'", Person.user_columns).should == expected
    Person.conditions_by_like("in 'quotes'", [:first_name, :last_name]).should == expected
  end
end
