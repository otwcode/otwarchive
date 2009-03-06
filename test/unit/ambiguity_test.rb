require File.dirname(__FILE__) + '/../test_helper'

class AmbiguityTest < ActiveSupport::TestCase

  context "an ambiguity" do
    setup do
      @tag = create_ambiguity
      @character = create_character
      @fandom = create_fandom
    end
    context "using add on tags" do
      setup do
        @tag.add_disambiguator(@character)
        @tag.add_disambiguator(@fandom)
      end
      should "be able to have disambiguators in different categories" do
        assert_same_elements [@character, @fandom], @tag.disambiguators
      end
      context "with a disambiguator removed" do
        setup do
          @tag.remove_disambiguator(@character)
        end
        should "remove it" do
          assert_equal [@fandom], @tag.disambiguators
        end
      end
    end
    context "using update on names" do
      setup do
        @tag.update_disambiguators([@character.name, @fandom.name])
        @tag.reload
      end
      should "be able to have disambiguators in different categories" do
        assert_same_elements [@character, @fandom], @tag.disambiguators
      end
      context "with a disambiguator removed" do
        setup do
          @tag.update_disambiguators([@fandom.name])
          @tag.reload
        end
        should "remove it" do
          assert_equal [@fandom], @tag.disambiguators
        end
      end
    end
  end


end
