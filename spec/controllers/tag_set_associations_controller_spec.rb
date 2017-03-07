require 'spec_helper'

describe TagSetAssociationsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:tag_set_association) { FactoryGirl.create(:tag_set_association) }
  let(:owned_tag_set) { tag_set_association.owned_tag_set }
  let(:mod_pseud) {
    FactoryGirl.create(:pseud).tap do |pseud|
      owned_tag_set.add_moderator(pseud)
      owned_tag_set.save!
    end
  }
  let(:moderator) { mod_pseud.user }

  describe 'PUT update_multiple' do
    context 'when user is not logged in' do
      it 'should redirect and return an error message' do
        put :update_multiple, tag_set_id: owned_tag_set.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you " \
          "were trying to reach. Please log in.")
      end
    end

    context 'when logged in user is moderator of tag set' do
      before do
        fake_login_known_user(moderator.reload)
      end

      context 'and no tag associations are saved' do
        it 'should redirect and return a notice' do
          put :update_multiple, tag_set_id: owned_tag_set.id
          it_redirects_to(tag_set_path(owned_tag_set))
          expect(flash[:notice]).to include('Nominated associations were added.')
        end
      end

      context 'and all tag associations are saved' do
        let(:random_fandom_tag) { FactoryGirl.create(:fandom) }
        let(:random_relationship_tag) { FactoryGirl.create(:relationship) }

        before do
          params = {
            tag_set_id: owned_tag_set.id,
            "create_association_#{random_relationship_tag.id}_#{random_fandom_tag.name}": '1',
          }
          put :update_multiple, params
        end

        it 'should create the new tag association' do
          expect(TagSetAssociation.count).to eq(1)
          assoc = TagSetAssociation.last
          expect(assoc.owned_tag_set).to eq(owned_tag_set)
          expect(assoc.tag).to eq random_relationship_tag
          expect(assoc.parent_tag).to eq random_fandom_tag
        end

        it 'should redirect and return a notice' do
          it_redirects_to(tag_set_path(owned_tag_set))
          expect(flash[:notice]).to include('Nominated associations were added.')
        end
      end

      context 'and some tag associations cannot be saved' do
        it 'should redirect and return an error message' do
          params = {
            tag_set_id: owned_tag_set.id,
            'create_association_99999999_Hawaii+Seven-0+(2022)': '1',
          }
          put :update_multiple, params
          expect(response).to render_template('index')
          expect(flash[:error]).to include("We couldn't add all of your specified associations.")
        end
      end
    end
  end
end
