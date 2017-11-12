# frozen_string_literal: true

require 'spec_helper'

describe TagWranglingsController do
  include LoginMacros
  include RedirectExpectationHelper

  before do
    fake_login
    @current_user.roles << Role.new(name: 'tag_wrangler')
  end

  describe 'wrangle' do
    before do
      @fandom1 = FactoryGirl.create(:fandom, canonical: false)
    end

    it 'should display error when save canonical tags fails' do
      allow(Tag).to receive(:where).and_wrap_original do |m, *args|
        if args.length == 1 && args[0] == { id: [@fandom1.id.to_s] }
          [@fandom1]
        else
          m.call(*args)
        end
      end

      allow(@fandom1).to receive(:update_attributes).with(canonical: true).and_return(false)

      post :wrangle, params: { canonicals: [@fandom1.id] }

      expect(flash[:error]).to include("The following tags couldn\'t be made canonical: " + @fandom1.name)
    end
  end
end
