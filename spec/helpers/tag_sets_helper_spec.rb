require 'spec_helper'

describe TagSetsHelper do
  describe 'nomination_notes' do
    before(:each) do
      @limit = HashWithIndifferentAccess.new
      @limit[:fandom] = 3
      @limit[:character] = 3
      @limit[:relationship] = 3
      @limit[:freeform] = 3
    end

    context 'for nominations allowing only freeforms' do
      it 'should say you can nominate up to a certain amount' do
        @limit[:fandom] = 0
        @limit[:character] = 0
        @limit[:relationship] = 0
        expect(helper.nomination_notes(@limit))
          .to eq('You can nominate up to 3 additional tags.')
      end
    end

    context 'for nominations allowing relationships' do
      it 'should have relationships info listed last' do
        expect(helper.nomination_notes(@limit))
          .to match('characters and 3 relationships for each one.')
      end
    end

    context 'for nominations allowing NO relationships' do
      it 'should not mention relationships' do
        @limit[:relationship] = 0
        expect(helper.nomination_notes(@limit))
          .to match('3 fandoms and up to 3 characters for each one.')
      end
    end

    context 'for nominations allowing fandoms, NO characters,
        and NO relationships' do
      it 'should mention only fandoms' do
        @limit[:relationship] = 0
        @limit[:character] = 0
        expect(helper.nomination_notes(@limit))
          .to match('You can nominate up to 3 fandoms.')
      end
    end

    context 'for nominations allowing fandoms, relationships,
        and NO characters' do
      it 'should mentions fandoms and relationships' do
        @limit[:character] = 0
        expect(helper.nomination_notes(@limit))
          .to match('3 fandoms and up to 3 relationships for each one.')
      end
    end

    context 'for nominations allowing characters, relationships, NO fandoms' do
      it 'should mention characters and relationships' do
        @limit[:fandom] = 0
        expect(helper.nomination_notes(@limit))
          .to match('You can nominate up to 3 characters and 3 relationships.')
      end
    end

    context 'for nominations allowing characters, NO relationships,
        NO fandoms' do
      it 'should mention only characters' do
        @limit[:fandom] = 0
        @limit[:relationship] = 0
        @limit[:freeform] = 0
        expect(helper.nomination_notes(@limit))
          .to eq('You can nominate up to 3 characters.')
      end
    end

    context 'for nominations allowing relationships, NO characters,
        NO fandoms' do
      it 'should mention only relationships' do
        @limit[:fandom] = 0
        @limit[:character] = 0
        @limit[:freeform] = 0
        expect(helper.nomination_notes(@limit))
          .to eq('You can nominate up to 3 relationships.')
      end
    end
  end

  describe 'noncanonical_info_class' do
    before(:each) do
      @tag_set_nomination = FactoryGirl.create(:tag_set_nomination)
      @owned_tag_set = @tag_set_nomination.owned_tag_set
      @nomination = @owned_tag_set.tag_nominations.first
    end

    context 'for valid nominations' do
      it 'should show basic information' do
        expect(helper.nomination_status(@fake_nomination))
          .to include('unreviewed').and include('?!')
            .and include('This nomination has not been reviewed yet.')
      end
    end

    context 'for approved nominations' do
      it 'should show correct class information' do
        @nomination.approved = true
        expect(helper.nomination_status(@nomination)).to include('approved')
          .and include('This nomination has been approved!')
            .and include('&#10004;')
      end
    end

    context 'for rejected nominations' do
      xit 'should show correct class information' do
        @nomination.approved = true
        expect(helper.nomination_status(@nomination)).to include('approved')
          .and include('This nomination was rejected')
            .and include('&#10006;')
      end
    end

    context 'for approved nominations' do
      xit 'should show correct class information' do
        @nomination.approved = true
        expect(helper.nomination_status(@nomination)).to include('approved')
          .and include('has not been reviewed yet and can still be changed.')
            .and include('?!')
      end
    end
  end
end
