require 'spec_helper'

describe TagSetNominationsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:tag_set_nomination) { FactoryGirl.create(:tag_set_nomination) }
  let(:owned_tag_set) { tag_set_nomination.owned_tag_set }

  let(:tag_nominator) { tag_nominator_pseud.user }
  let(:tag_nominator_pseud) { tag_set_nomination.pseud }
  let(:moderator) { mod_pseud.user }
  let(:mod_pseud) { FactoryGirl.create(:pseud) }

  describe 'GET index' do
    before do
      owned_tag_set.add_moderator(mod_pseud)
      owned_tag_set.save!
      moderator.reload
    end

    context 'user is not logged in' do
      it 'redirects and shows an error message' do
        get :index, user_id: moderator.login, tag_set_id: owned_tag_set.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context 'user is logged in' do
      before do
        fake_login_known_user(user)
      end

      context 'user_id param is truthy' do
        let(:user) { tag_nominator }

        context 'user_id does not match logged in user' do
          it 'redirects and shows an error message' do
            get :index, user_id: "invalid", tag_set_id: owned_tag_set.id
            it_redirects_to_with_error(tag_sets_path, "You can only view your own nominations, sorry.")
          end
        end

        context 'user_id matches logged in user' do
          before do
            get :index, user_id: tag_nominator.login, tag_set_id: owned_tag_set.id
          end

          it 'renders the index template' do
            expect(response).to render_template("index")
          end

          it 'returns expected tag set nominations' do
            expect(assigns(:tag_set_nominations)).to include(tag_set_nomination)
          end
        end
      end

      context 'user_id param is falsey' do
        context 'tag set is found' do
          context 'logged in user is moderator' do
            let(:user) { moderator }

            it 'renders the index template' do
              get :index, tag_set_id: owned_tag_set.id
              expect(response).to render_template("index")
            end

            context 'no unreviewed tag_nominations' do
              it 'returns a flash notice about no unreviewed nominations' do
                get :index, tag_set_id: owned_tag_set.id
                expect(flash[:notice]).to eq("No nominations to review!")
              end
            end

            context 'unreviewed tag_nominations exist' do
              let(:fandom_nom) { FandomNomination.create(tag_set_nomination: tag_set_nomination,
                                                         tagname: "New Fandom", approved: false, rejected: false) }
              let!(:unreviewed_character_nom) { CharacterNomination.create(tag_set_nomination: tag_set_nomination,
                                                                           fandom_nomination: fandom_nom,
                                                                           tagname: "New Character",
                                                                           approved: false, rejected: false) }
              let!(:unreviewed_relationship_nom) { RelationshipNomination.create(tag_set_nomination: tag_set_nomination,
                                                                                 fandom_nomination: fandom_nom,
                                                                                 tagname: "New Relationship",
                                                                                 approved: false, rejected: false) }

              it 'does not return a flash notice about no unreviewed nominations' do
                get :index, tag_set_id: owned_tag_set.id
                expect(flash[:notice]).not_to eq("No nominations to review!")
              end

              context 'tag set freeform_nomination_limit is > 0' do
                before do
                  owned_tag_set.update_attribute(:freeform_nomination_limit, 2)
                end

                context 'unreviewed freeform_nominations' do
                  context 'unreviewed freeform nominations <= 30' do
                    before do
                      add_unreviewed_freeform_nominations(30)
                      expect(owned_tag_set.freeform_nominations.count).to eq(30)

                      get :index, tag_set_id: owned_tag_set.id
                    end

                    it 'returns all ordered freeform nominations' do
                      expect(assigns(:nominations_count)[:freeform]).to eq(30)
                      expect(assigns(:nominations)[:freeform].count).to eq(30)
                      expect(assigns(:nominations)[:freeform].first.tagname).to eq("New Freeform 1")
                    end

                    it 'does not return a flash notice about too many nominations' do
                      expect(flash[:notice]).not_to eq("There are too many nominations to show at once, so here's a " +
                                                           "randomized selection! Additional nominations will appear " +
                                                           "after you approve or reject some.")
                    end
                  end

                  context 'unreviewed freeform nominations > 30' do
                    before do
                      add_unreviewed_freeform_nominations(31)
                      expect(owned_tag_set.freeform_nominations.count).to eq(31)

                      get :index, tag_set_id: owned_tag_set.id
                    end

                    it 'returns 30 freeform nominations' do
                      expect(assigns(:nominations_count)[:freeform]).to eq(31)
                      expect(assigns(:nominations)[:freeform].count).to eq(30)
                    end

                    it 'returns a flash notice about too many nominations' do
                      expect(flash[:notice]).to eq("There are too many nominations to show at once, so here's a " +
                                                       "randomized selection! Additional nominations will appear " +
                                                       "after you approve or reject some.")
                    end
                  end

                  def add_unreviewed_freeform_nominations(num)
                    num.times do
                      FreeformNomination.create(tag_set_nomination: tag_set_nomination, tagname: "New Freeform #{num}",
                                                approved: false, rejected: false)
                      num -= 1
                    end
                  end
                end

                context 'reviewed freeform_nominations' do
                  it 'does not return freeform nominations' do
                    freeform_nom = FreeformNomination.create(tag_set_nomination: tag_set_nomination,
                                                             tagname: "New Freeform")
                    owned_tag_set.tag_set.from_owned_tag_set = true
                    owned_tag_set.add_tagnames("freeform", [freeform_nom.tagname])
                    get :index, tag_set_id: owned_tag_set.id

                    expect(assigns(:nominations_count)[:freeform]).to eq(0)
                    expect(assigns(:nominations)[:freeform]).not_to include(freeform_nom)
                  end
                end
              end

              context 'tag set freeform_nomination_limit is 0' do
                it 'does not return freeform nominations' do
                  owned_tag_set.update_attribute(:freeform_nomination_limit, 0)
                  FreeformNomination.create(tag_set_nomination: tag_set_nomination, tagname: "New Freeform",
                                            approved: false, rejected: false)
                  get :index, tag_set_id: owned_tag_set.id
                  expect(assigns(:nominations)[:freeform]).to be_nil
                end
              end

              context 'tag set fandom_nomination_limit is > 0' do
                before do
                  owned_tag_set.fandom_nomination_limit = 2
                  owned_tag_set.character_nomination_limit = 2
                  owned_tag_set.relationship_nomination_limit = 2
                  owned_tag_set.save(validate: false)
                end

                context 'unreviewed fandom nominations' do
                  context 'unreviewed fandom nominations <= 30' do
                    before do
                      add_unreviewed_fandom_nominations(29)
                      expect(owned_tag_set.fandom_nominations.count).to eq(30)

                      get :index, tag_set_id: owned_tag_set.id
                    end

                    it 'returns all ordered fandom nominations' do
                      expect(assigns(:nominations_count)[:fandom]).to eq(30)
                      expect(assigns(:nominations)[:fandom].count).to eq(30)
                      expect(assigns(:nominations)[:fandom].first).to eq(fandom_nom)
                    end

                    it 'does not return associated character and relationship nominations' do
                      expect(assigns(:nominations)[:cast]).not_to include(unreviewed_character_nom)
                      expect(assigns(:nominations)[:cast]).not_to include(unreviewed_relationship_nom)
                    end

                    it 'does not return a flash notice about too many nominations' do
                      expect(flash[:notice]).not_to eq("There are too many nominations to show at once, so here's a " +
                                                           "randomized selection! Additional nominations will appear " +
                                                           "after you approve or reject some.")
                    end
                  end

                  context 'unreviewed fandom nominations > 30' do
                    before do
                      add_unreviewed_fandom_nominations(30)
                      expect(owned_tag_set.fandom_nominations.count).to eq(31)

                      get :index, tag_set_id: owned_tag_set.id
                    end

                    it 'returns 30 fandom nominations' do
                      expect(assigns(:nominations_count)[:fandom]).to eq(31)
                      expect(assigns(:nominations)[:fandom].count).to eq(30)
                    end

                    it 'returns a flash notice about too many nominations' do
                      expect(flash[:notice]).to eq("There are too many nominations to show at once, so here's a " +
                                                       "randomized selection! Additional nominations will appear " +
                                                       "after you approve or reject some.")
                    end
                  end

                  def add_unreviewed_fandom_nominations(num)
                    num.times do
                      FandomNomination.create(tag_set_nomination: tag_set_nomination, tagname: "New Fandom #{num}",
                                              approved: false, rejected: false)
                      num -= 1
                    end
                  end
                end

                context 'rejected fandom nominations' do
                  before do
                    owned_tag_set.remove_tagnames("fandom", [fandom_nom.tagname])
                    get :index, tag_set_id: owned_tag_set.id
                  end

                  it 'does not return fandom nominations' do
                    expect(assigns(:nominations)[:fandom]).not_to include(fandom_nom)
                  end

                  it 'does not return associated character and relationship nominations' do
                    expect(assigns(:nominations)[:cast]).not_to include(unreviewed_character_nom)
                    expect(assigns(:nominations)[:cast]).not_to include(unreviewed_relationship_nom)
                  end
                end

                context 'approved fandom nominations' do
                  let(:reviewed_character_nom) { CharacterNomination.create(tag_set_nomination: tag_set_nomination,
                                                                            fandom_nomination: fandom_nom,
                                                                            tagname: "Character To Be Approved") }
                  let(:reviewed_relationship_nom) { RelationshipNomination.create(tag_set_nomination: tag_set_nomination,
                                                                                  fandom_nomination: fandom_nom,
                                                                                  tagname: "Relationship To Be Approved") }

                  before do
                    owned_tag_set.tag_set.from_owned_tag_set = true
                    owned_tag_set.add_tagnames("fandom", [fandom_nom.tagname])
                    owned_tag_set.add_tagnames("character", [reviewed_character_nom.tagname])
                    owned_tag_set.add_tagnames("relationship", [reviewed_relationship_nom.tagname])
                  end

                  it 'does not return fandom nominations' do
                    get :index, tag_set_id: owned_tag_set.id
                    expect(assigns(:nominations)[:fandom]).not_to include(fandom_nom)
                  end

                  it 'does not return associated reviewed character and relationship nominations' do
                    get :index, tag_set_id: owned_tag_set.id
                    expect(assigns(:nominations)[:cast]).not_to include(reviewed_character_nom)
                    expect(assigns(:nominations)[:cast]).not_to include(reviewed_relationship_nom)
                  end

                  context 'character_ and relationship_nomination_limit are > 0' do
                    before do
                      expect(owned_tag_set.character_nomination_limit).to be > 0
                      expect(owned_tag_set.relationship_nomination_limit).to be > 0

                      get :index, tag_set_id: owned_tag_set.id
                    end

                    it 'returns associated unreviewed character and relationship nominations' do
                      expect(assigns(:nominations)[:cast]).to eq([unreviewed_character_nom, unreviewed_relationship_nom])
                    end
                  end

                  context 'character_nomination_limit is 0, relationship_nomination_limit is > 0' do
                    before do
                      owned_tag_set.update_attribute(:character_nomination_limit, 0)
                      expect(owned_tag_set.relationship_nomination_limit).to be > 0

                      get :index, tag_set_id: owned_tag_set.id
                    end

                    it 'returns associated unreviewed character and relationship nominations' do
                      expect(assigns(:nominations)[:cast]).to eq([unreviewed_character_nom, unreviewed_relationship_nom])
                    end
                  end

                  context 'character_ and relationship_nomination_limit are 0' do
                    before do
                      owned_tag_set.update_attribute(:character_nomination_limit, 0)
                      owned_tag_set.update_attribute(:relationship_nomination_limit, 0)

                      get :index, tag_set_id: owned_tag_set.id
                    end

                    it 'does not return associated character and relationship nominations' do
                      expect(assigns(:nominations)[:cast]).to be_nil
                    end
                  end
                end
              end

              context 'tag set fandom_nomination_limit is 0' do
                before do
                  owned_tag_set.update_attribute(:fandom_nomination_limit, 0)
                end

                it 'renders the index template' do
                  get :index, tag_set_id: owned_tag_set.id
                  expect(response).to render_template("index")
                end

                context 'character_ and relationship_nomination_limit are > 0' do
                  before do
                    owned_tag_set.character_nomination_limit = 2
                    owned_tag_set.relationship_nomination_limit = 2
                    owned_tag_set.save(validate: false)
                  end

                  context 'unreviewed character and relationship nominations <= 30' do
                    before do
                      add_unreviewed_character_nominations(29)
                      expect(owned_tag_set.character_nominations.count).to eq(30)
                      add_unreviewed_relationship_nominations(29)
                      expect(owned_tag_set.relationship_nominations.count).to eq(30)

                      get :index, tag_set_id: owned_tag_set.id
                    end

                    it 'returns all ordered character and relationship nominations' do
                      expect(assigns(:nominations_count)[:character]).to eq(30)
                      expect(assigns(:nominations)[:character].count).to eq(30)
                      expect(assigns(:nominations)[:character].first).to eq(unreviewed_character_nom)
                      expect(assigns(:nominations_count)[:relationship]).to eq(30)
                      expect(assigns(:nominations)[:relationship].count).to eq(30)
                      expect(assigns(:nominations)[:relationship].first).to eq(unreviewed_relationship_nom)
                    end

                    it 'does not return a flash notice about too many nominations' do
                      expect(flash[:notice]).not_to eq("There are too many nominations to show at once, so here's a " +
                                                           "randomized selection! Additional nominations will appear " +
                                                           "after you approve or reject some.")
                    end
                  end

                  context 'unreviewed character or relationship nominations > 30' do
                    before do
                      add_unreviewed_relationship_nominations(30)
                      expect(owned_tag_set.relationship_nominations.count).to eq(31)

                      get :index, tag_set_id: owned_tag_set.id
                    end

                    it 'returns 30 character and relationship nominations' do
                      expect(assigns(:nominations_count)[:character]).to eq(1)
                      expect(assigns(:nominations)[:character].count).to eq(1)
                      expect(assigns(:nominations_count)[:relationship]).to eq(31)
                      expect(assigns(:nominations)[:relationship].count).to eq(30)
                    end

                    it 'returns a flash notice about too many nominations' do
                      expect(flash[:notice]).to eq("There are too many nominations to show at once, so here's a " +
                                                       "randomized selection! Additional nominations will appear " +
                                                       "after you approve or reject some.")
                    end
                  end

                  def add_unreviewed_character_nominations(num)
                    num.times do
                      CharacterNomination.create(tag_set_nomination: tag_set_nomination, fandom_nomination: fandom_nom,
                                                 tagname: "New Character #{num}", approved: false, rejected: false)
                      num -= 1
                    end
                  end

                  def add_unreviewed_relationship_nominations(num)
                    num.times do
                      RelationshipNomination.create(tag_set_nomination: tag_set_nomination, fandom_nomination: fandom_nom,
                                                    tagname: "New Relationship #{num}", approved: false, rejected: false)
                      num -= 1
                    end
                  end
                end

                context 'character_nomination_limit is 0' do
                  it 'does not return character nominations' do
                    owned_tag_set.update_attribute(:character_nomination_limit, 0)
                    get :index, tag_set_id: owned_tag_set.id
                    expect(assigns(:nominations)[:character]).to be_nil
                  end
                end

                context 'relationship_nomination_limit is 0' do
                  it 'does not return relationship nominations' do
                    owned_tag_set.update_attribute(:relationship_nomination_limit, 0)
                    get :index, tag_set_id: owned_tag_set.id
                    expect(assigns(:nominations)[:relationship]).to be_nil
                  end
                end
              end
            end
          end

          context 'logged in user is not moderator' do
            let(:user) { FactoryGirl.create(:user) }

            it 'redirects and shows an error message' do
              get :index, tag_set_id: owned_tag_set.id
              it_redirects_to_with_error(tag_sets_path, "You can't see those nominations, sorry.")
            end
          end
        end

        # is testing this even possible?
        # how can OwnedTagSet.find not raise an error but still return falsey?
        xcontext 'tag set is not found' do
          let(:user) { FactoryGirl.create(:user) }

          it 'redirects and shows an error message' do
            get :index, tag_set_id: nil
            it_redirects_to_with_error(tag_sets_path, "What nominations did you want to work with?")
          end
        end
      end
    end
  end

  describe 'GET show' do
    context 'user is not logged in' do
      it 'redirects and shows an error message' do
        get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context 'user is logged in' do
      context 'invalid params' do
        before do
          fake_login_known_user(tag_nominator)
        end

        # is testing this even possible?
        # how can OwnedTagSet.find not raise an error but still return falsey?
        xcontext 'no tag set' do
          it 'redirects and shows an error message' do
            get :show, id: tag_set_nomination.id, tag_set_id: nil
            it_redirects_to_with_error(tag_sets_path, "What tag set did you want to nominate for?")
          end
        end

        # is testing this even possible?
        # how can TagSetNomination.find not raise an error but still return falsey?
        xcontext 'no tag set nomination' do
          it 'redirects and shows an error message' do
            get :show, id: nil, tag_set_id: owned_tag_set.id
            it_redirects_to_with_error(user_tag_set_nominations_path(tag_nominator), "Which nominations did you want to work with?")
          end
        end
      end

      context 'valid params' do
        context 'logged in user is not author of nomination' do
          before do
            owned_tag_set.add_moderator(mod_pseud)
            owned_tag_set.save!
            moderator.reload
          end

          context 'user is also not moderator of tag set' do
            before do
              random_user = FactoryGirl.create(:user)
              fake_login_known_user(random_user)
            end

            it 'redirects and shows an error message' do
              get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
              it_redirects_to_with_notice(tag_set_path(owned_tag_set),
                                          "You can only see your own nominations or nominations for a set you moderate.")
            end
          end

          context 'user is moderator of tag set' do
            before do
              fake_login_known_user(moderator)
            end

            it 'renders the show template' do
              get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
              expect(response).to render_template("show")
            end
          end
        end

        context 'logged in user is author of nomination' do
          before do
            fake_login_known_user(tag_nominator)
          end

          context 'user is not moderator of tag set' do
            it 'renders the show template' do
              tag_nominator.reload # Whywhywhywhy

              get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
              expect(response).to render_template("show")
            end
          end

          context 'user is also moderator of tag set' do
            before do
              owned_tag_set.add_moderator(tag_nominator_pseud)
              owned_tag_set.save!
              tag_nominator.reload
            end

            it 'renders the show template' do
              get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
              expect(response).to render_template("show")
            end
          end
        end
      end
    end
  end

  describe 'GET new' do

  end

  describe 'GET edit' do

  end

  describe 'POST create' do

  end

  describe 'PUT update' do

  end

  describe 'DELETE destroy' do

  end

  describe 'GET confirm_destroy_multiple' do

  end

  describe 'DELETE destroy_multiple' do

  end

  describe 'PUT update_multiple' do

  end
end
