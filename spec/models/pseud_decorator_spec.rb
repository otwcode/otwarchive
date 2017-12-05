require 'spec_helper'

describe PseudDecorator do
  before(:all) do
    @pseud = create(:pseud)
    @search_results = [{
      "_id"=>"#{@pseud.id}",
      "_source"=>{
        "id"=>@pseud.id,
        "user_id"=>@pseud.user_id,
        "name"=>@pseud.name,
        "description"=>nil,
        "user_login"=>@pseud.user_login,
        "byline"=>@pseud.byline,
        "collection_ids"=>[1],
        "sortable_name"=>@pseud.name.downcase,
        "fandoms"=>[{"id"=>13, "name"=>"Stargate SG-1", "count"=>7}],
        "public_bookmarks_count"=>5,
        "general_works_count"=>10,
        "public_works_count"=>7
      }
    }]
  end

  describe ".decorate_from_search" do
    it "initializes decorators" do
      decs = PseudDecorator.decorate_from_search([@pseud], @search_results)
      expect(decs.length).to eq(1)
      expect(decs.first.name).to eq(@pseud.name)
    end
  end

  context "with search data" do
    before(:all) do
      @decorator = PseudDecorator.decorate_from_search([@pseud], @search_results).first
    end

    describe "#works_count" do
      it "should return the public count if there's no current user" do
        expect(@decorator.works_count).to eq(7)
      end
      it "should return the general count if there is a current user" do
        User.current_user = User.new
        expect(@decorator.works_count).to eq(10)
      end
    end

    describe "#bookmarks_count" do
      it "should return the public bookmarks count" do
        expect(@decorator.bookmarks_count).to eq(5)
      end
    end

    describe "#byline" do
      it "should match the pseud byline" do
        expect(@decorator.byline).to eq(@pseud.byline)
      end
    end

    describe "#user_login" do
      it "should match the user login" do
        expect(@decorator.user_login).to eq(@pseud.user.login)
      end
    end

    describe "#pseud_path" do
      it "should be the path to the pseud" do
        expect(@decorator.pseud_path).to eq("/users/#{@pseud.user.to_param}/pseuds/#{@pseud.to_param}")
      end
    end

    describe "#works_path" do
      it "should be the path to the pseud works page" do
        expect(@decorator.works_path).to eq("/users/#{@pseud.user.to_param}/pseuds/#{@pseud.to_param}/works")
      end
    end

    describe "#works_link" do
      it "should be an html link to the pseud works page" do
        expect(@decorator.works_link).to eq("<a href='/users/#{@pseud.user.to_param}/pseuds/#{@pseud.to_param}/works'>7 works</a>")
      end
    end

    describe "#bookmarks_path" do
      it "should be the path to the pseud bookmarks page" do
        expect(@decorator.bookmarks_path).to eq("/users/#{@pseud.user.to_param}/pseuds/#{@pseud.to_param}/bookmarks")
      end
    end

    describe "#bookmarks_link" do
      it "should be an html link to the pseud bookmarks page" do
        expect(@decorator.bookmarks_link).to eq("<a href='/users/#{@pseud.user.to_param}/pseuds/#{@pseud.to_param}/bookmarks'>5 bookmarks</a>")
      end
    end

    describe "#fandom_path" do
      it "should be the path to the pseud works page with the fandom id" do
        expect(@decorator.fandom_path(13)).to eq("/users/#{@pseud.user.to_param}/pseuds/#{@pseud.to_param}/works?fandom_id=13")
      end
    end

    describe "#fandom_link" do
      it "should be an html link to the pseud works page with the fandom id" do
        expect(@decorator.fandom_link(13)).to eq("<a href='/users/#{@pseud.user.to_param}/pseuds/#{@pseud.to_param}/works?fandom_id=13'>7 works in Stargate SG-1</a>")
      end
    end

    describe "#authored_items_links" do
      it "should combine the work and bookmark links" do
        str = "<a href='/users/#{@pseud.user.to_param}/pseuds/#{@pseud.to_param}/works'>7 works</a>, <a href='/users/#{@pseud.user.to_param}/pseuds/#{@pseud.to_param}/bookmarks'>5 bookmarks</a>"
        expect(@decorator.authored_items_links).to eq(str)
      end
    end

    describe "#constructed_byline" do
      it "should match the pseud byline" do
        expect(@decorator.constructed_byline).to eq(@pseud.byline)
      end
    end
  end
end
