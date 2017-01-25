require 'spec_helper'

describe TagSetNominationsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:tag_set_nomination) { FactoryGirl.create(:tag_set_nomination) }
  let(:owned_tag_set) { tag_set_nomination.owned_tag_set }

  let(:tag_nominator) { tag_nominator_pseud.user }
  let(:tag_nominator_pseud) { tag_set_nomination.pseud }
  let(:moderator) { mod_pseud.user }
  let(:mod_pseud) {
    FactoryGirl.create(:pseud).tap do |pseud|
      owned_tag_set.add_moderator(pseud)
      owned_tag_set.save!
    end
  }

  let(:random_user) { FactoryGirl.create(:user) }

  describe 'GET index' do
    context 'user is not logged in' do
      it 'redirects and returns an error message' do
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
          it 'redirects and returns an error message' do
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
        context 'tag set exists' do
          context 'logged in user is moderator' do
            let(:user) { moderator.reload } # Why reload?

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
            let(:user) { random_user }

            it 'redirects and returns an error message' do
              get :index, tag_set_id: owned_tag_set.id
              it_redirects_to_with_error(tag_sets_path, "You can't see those nominations, sorry.")
            end
          end
        end

        # TODO: how can OwnedTagSet.find not raise an error but still return falsey?
        xcontext 'no tag set' do
          let(:user) { random_user }

          it 'redirects and returns an error message' do
            get :index, tag_set_id: nil
            it_redirects_to_with_error(tag_sets_path, "What nominations did you want to work with?")
          end
        end
      end
    end
  end

  describe 'GET show' do
    context 'user is not logged in' do
      it 'redirects and returns an error message' do
        get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context 'user is logged in' do
      context 'invalid params' do
        before do
          fake_login_known_user(tag_nominator)
        end

        # TODO: how can OwnedTagSet.find not raise an error but still return falsey?
        xcontext 'no tag set' do
          it 'redirects and returns an error message' do
            get :show, id: tag_set_nomination.id, tag_set_id: nil
            it_redirects_to_with_error(tag_sets_path, "What tag set did you want to nominate for?")
          end
        end

        # TODO: how can TagSetNomination.find not raise an error but still return falsey?
        xcontext 'no tag set nomination' do
          it 'redirects and returns an error message' do
            get :show, id: nil, tag_set_id: owned_tag_set.id
            it_redirects_to_with_error(user_tag_set_nominations_path(tag_nominator), "Which nominations did you want to work with?")
          end
        end
      end

      context 'valid params' do
        context 'user is not associated with nomination' do
          before do
            fake_login_known_user(random_user)
          end

          it 'redirects and returns an error message' do
            get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
            it_redirects_to_with_notice(tag_set_path(owned_tag_set),
                                        "You can only see your own nominations or nominations for a set you moderate.")
          end
        end

        context 'user is author of nomination' do
          before do
            fake_login_known_user(tag_nominator.reload) # Why reload?
          end

          it 'renders the show template' do
            get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
            expect(response).to render_template("show")
          end
        end

        context 'user is moderator of tag set' do
          before do
            fake_login_known_user(moderator.reload) # Why reload?
          end

          it 'renders the show template' do
            get :show, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
            expect(response).to render_template("show")
          end
        end
      end
    end
  end

  describe 'GET new' do
    context 'user is not logged in' do
      it 'redirects and returns an error message' do
        get :new, tag_set_id: owned_tag_set.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context 'user is logged in' do
      context 'tag set exists' do
        context 'user already has nominated tags for tag set' do
          before do
            fake_login_known_user(tag_nominator)
            get :new, tag_set_id: owned_tag_set.id
          end

          it 'redirects to edit page' do
            it_redirects_to(edit_tag_set_nomination_path(owned_tag_set, tag_set_nomination))
          end

          it 'does not build a new tag set nomination' do
            expect(assigns(:tag_set_nomination).new_record?).to be_falsey
            expect(assigns(:tag_set_nomination)).to eq(tag_set_nomination)
          end
        end

        context 'user has not yet nominated tags for tag set' do
          before do
            fake_login_known_user(random_user)
          end

          it 'renders the new template' do
            get :new, tag_set_id: owned_tag_set.id
            expect(response).to render_template("new")
          end

          it 'builds a new tag set nomination' do
            get :new, tag_set_id: owned_tag_set.id
            expect(assigns(:tag_set_nomination).new_record?).to be_truthy
            expect(assigns(:tag_set_nomination).pseud).to eq(random_user.default_pseud)
            expect(assigns(:tag_set_nomination).owned_tag_set).to eq(owned_tag_set)
          end

          it 'builds new freeform nominations until freeform_nomination_limit' do
            owned_tag_set.update_attribute(:freeform_nomination_limit, 3)
            get :new, tag_set_id: owned_tag_set.id
            expect(assigns(:tag_set_nomination).freeform_nominations.size).to eq(3)
          end

          context 'fandom_nomination_limit is > 0' do
            before do
              owned_tag_set.fandom_nomination_limit = 2
              owned_tag_set.character_nomination_limit = 4
              owned_tag_set.relationship_nomination_limit = 6
              owned_tag_set.save(validate: false)

              get :new, tag_set_id: owned_tag_set.id
            end

            it 'builds new fandom nominations until fandom_nomination_limit' do
              expect(assigns(:tag_set_nomination).fandom_nominations.size).to eq(2)
            end

            it 'builds new character nominations for each fandom nomination' do
              assigns(:tag_set_nomination).fandom_nominations.each do |fandom_nom|
                expect(fandom_nom.character_nominations.size).to eq(4)
              end
            end

            it 'builds new relationship nominations for each fandom nomination' do
              assigns(:tag_set_nomination).fandom_nominations.each do |fandom_nom|
                expect(fandom_nom.relationship_nominations.size).to eq(6)
              end
            end
          end

          context 'fandom_nomination_limit is 0' do
            before do
              owned_tag_set.fandom_nomination_limit = 0
              owned_tag_set.character_nomination_limit = 4
              owned_tag_set.relationship_nomination_limit = 6
              owned_tag_set.save(validate: false)

              get :new, tag_set_id: owned_tag_set.id
            end

            it 'does not build new fandom nominations' do
              expect(assigns(:tag_set_nomination).fandom_nominations.size).to eq(0)
            end

            it 'builds new character nominations until character_nomination_limit' do
              expect(assigns(:tag_set_nomination).character_nominations.size).to eq(4)
            end

            it 'builds new relationship nominations until relationship_nomination_limit' do
              expect(assigns(:tag_set_nomination).relationship_nominations.size).to eq(6)
            end
          end
        end
      end

      # TODO: how can OwnedTagSet.find not raise an error but still return falsey?
      xcontext 'no tag set' do
        it 'redirects and returns an error message' do
          fake_login_known_user(random_user)
          get :new, tag_set_id: nil
          it_redirects_to_with_error(tag_sets_path, "What tag set did you want to nominate for?")
        end
      end
    end
  end

  describe 'GET edit' do
    context 'user is not logged in' do
      it 'redirects and returns an error message' do
        get :edit, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context 'user is logged in' do
      context 'invalid params' do
        before do
          fake_login_known_user(tag_nominator)
        end

        # TODO: how can OwnedTagSet.find not raise an error but still return falsey?
        xcontext 'no tag set' do
          it 'redirects and returns an error message' do
            get :edit, id: tag_set_nomination.id, tag_set_id: nil
            it_redirects_to_with_error(tag_sets_path, "What tag set did you want to nominate for?")
          end
        end

        # TODO: how can TagSetNomination.find not raise an error but still return falsey?
        xcontext 'no tag set nomination' do
          it 'redirects and returns an error message' do
            get :edit, id: nil, tag_set_id: owned_tag_set.id
            it_redirects_to_with_error(user_tag_set_nominations_path(tag_nominator), "Which nominations did you want to work with?")
          end
        end
      end

      context 'valid params' do
        let!(:fandom_nom) { FandomNomination.create(tag_set_nomination: tag_set_nomination,
                                                    tagname: "New Fandom", approved: false, rejected: false) }

        context 'user is not associated with nomination' do
          before do
            fake_login_known_user(random_user)
          end

          it 'redirects and returns an error message' do
            get :edit, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
            it_redirects_to_with_notice(tag_set_path(owned_tag_set),
                                        "You can only see your own nominations or nominations for a set you moderate.")
          end
        end

        context 'user is author of nomination' do
          before do
            fake_login_known_user(tag_nominator.reload) # Why reload?

            owned_tag_set.fandom_nomination_limit = 1
            owned_tag_set.character_nomination_limit = 3
            owned_tag_set.relationship_nomination_limit = 2
            owned_tag_set.freeform_nomination_limit = 4
            owned_tag_set.save(validate: false)
          end

          it 'renders the edit template' do
            get :edit, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
            expect(response).to render_template("edit")
          end

          context 'number of tag nominations matches limits specified on tag set' do
            before do
              add_character_nominations(owned_tag_set.character_nomination_limit)
              add_relationship_nominations(owned_tag_set.relationship_nomination_limit)
              add_freeform_nominations(owned_tag_set.freeform_nomination_limit)

              get :edit, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
            end

            it 'returns existing associated tag nominations' do
              expect(assigns(:tag_set_nomination).fandom_nominations).to eq([fandom_nom])
              expect(assigns(:tag_set_nomination).fandom_nominations[0].character_nominations.count).to eq(3)
              expect(assigns(:tag_set_nomination).fandom_nominations[0].relationship_nominations.count).to eq(2)
              expect(assigns(:tag_set_nomination).freeform_nominations.count).to eq(4)
            end

            it 'does not build new tag nominations' do
              expect(assigns(:tag_set_nomination).fandom_nominations[0].character_nominations.size).to eq(3)
              expect(assigns(:tag_set_nomination).fandom_nominations[0].relationship_nominations.size).to eq(2)
              expect(assigns(:tag_set_nomination).freeform_nominations.size).to eq(4)
            end
          end

          context 'fewer tag nominations than limit specified on tag set' do
            before do
              add_character_nominations(1)
              add_relationship_nominations(1)
              add_freeform_nominations(1)

              get :edit, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
            end

            it 'returns existing associated tag nominations' do
              expect(assigns(:tag_set_nomination).fandom_nominations).to eq([fandom_nom])
              expect(assigns(:tag_set_nomination).fandom_nominations[0].character_nominations.count).to eq(1)
              expect(assigns(:tag_set_nomination).fandom_nominations[0].relationship_nominations.count).to eq(1)
              expect(assigns(:tag_set_nomination).freeform_nominations.count).to eq(1)
            end

            it 'builds new tag nominations until _nomination_limit is reached' do
              expect(assigns(:tag_set_nomination).fandom_nominations[0].character_nominations.size).to eq(3)
              expect(assigns(:tag_set_nomination).fandom_nominations[0].relationship_nominations.size).to eq(2)
              expect(assigns(:tag_set_nomination).freeform_nominations.size).to eq(4)
            end
          end

          def add_character_nominations(num)
            num.times do
              CharacterNomination.create(tag_set_nomination: tag_set_nomination, fandom_nomination: fandom_nom,
                                         tagname: "New Character #{num}")
              num -= 1
            end
          end

          def add_relationship_nominations(num)
            num.times do
              RelationshipNomination.create(tag_set_nomination: tag_set_nomination, fandom_nomination: fandom_nom,
                                            tagname: "New Relationship #{num}")
              num -= 1
            end
          end

          def add_freeform_nominations(num)
            num.times do
              FreeformNomination.create(tag_set_nomination: tag_set_nomination, tagname: "New Freeform #{num}")
              num -= 1
            end
          end
        end

        context 'user is moderator of tag set' do
          let!(:character_nom) { CharacterNomination.create(tag_set_nomination: tag_set_nomination,
                                                            fandom_nomination: fandom_nom, tagname: "New Character") }
          let!(:relationship_nom) { RelationshipNomination.create(tag_set_nomination: tag_set_nomination,
                                                                  fandom_nomination: fandom_nom,
                                                                  tagname: "New Relationship") }
          let!(:freeform_nom) { FreeformNomination.create(tag_set_nomination: tag_set_nomination,
                                                          tagname: "New Freeform") }

          before do
            fake_login_known_user(moderator.reload) # Why reload?
            get :edit, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
          end

          it 'renders the edit template' do
            expect(response).to render_template("edit")
          end

          it 'returns associated tag nominations' do
            expect(assigns(:tag_set_nomination).fandom_nominations).to include(fandom_nom)
            expect(assigns(:tag_set_nomination).fandom_nominations[0].character_nominations).to include(character_nom)
            expect(assigns(:tag_set_nomination).fandom_nominations[0].relationship_nominations).to include(relationship_nom)
            expect(assigns(:tag_set_nomination).freeform_nominations).to include(freeform_nom)
          end
        end
      end
    end
  end

  describe 'POST create' do
    context 'user is not logged in' do
      it 'redirects and returns an error message' do
        post :create, tag_set_id: owned_tag_set.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context 'user is logged in' do
      context 'invalid params' do
        before do
          fake_login_known_user(random_user)
        end

        # TODO: how can OwnedTagSet.find not raise an error but still return falsey?
        xcontext 'no tag set' do
          it 'redirects and returns an error message' do
            post :create, tag_set_id: nil
            it_redirects_to_with_error(tag_sets_path, "What tag set did you want to nominate for?")
          end
        end

        context 'pseud_id param does not match user' do
          it 'redirects and returns an error message' do
            post :create, tag_set_id: owned_tag_set.id, tag_set_nomination: { pseud_id: tag_nominator.default_pseud.id }
            it_redirects_to_with_error(root_path, "You can't nominate tags with that pseud.")
          end
        end
      end

      context 'valid params' do
        before do
          fake_login_known_user(random_user.reload) # Why reload?
        end

        context 'tag set nomination saves successfully' do
          before do
            owned_tag_set.update_attribute(:character_nomination_limit, 1)
            post :create,
                 tag_set_id: owned_tag_set.id,
                 tag_set_nomination: { pseud_id: random_user.default_pseud.id,
                                       owned_tag_set_id: owned_tag_set.id }.merge(nomination_attributes)
          end

          context 'all tag nominations are canonical' do
            let(:nomination_attributes) {
              { fandom_nominations_attributes: {
                  "0": { tagname: "New Fandom",
                         character_nominations_attributes: {
                             "0": { tagname: "New Character",
                                    from_fandom_nomination: true } } } }
              }
            }

            it 'creates a new tag set nomination' do
              new_tag_set_nomination = TagSetNomination.last
              expect(assigns(:tag_set_nomination)).to eq(new_tag_set_nomination)
              expect(new_tag_set_nomination.pseud).to eq(random_user.default_pseud)
              expect(new_tag_set_nomination.owned_tag_set).to eq(owned_tag_set)
            end

            it 'creates associated tag nominations' do
              new_fandom_nomination = FandomNomination.last
              expect(assigns(:tag_set_nomination).fandom_nominations.count).to eq(1)
              expect(assigns(:tag_set_nomination).fandom_nominations[0]).to eq(new_fandom_nomination)
              expect(new_fandom_nomination.tagname).to eq("New Fandom")
              expect(new_fandom_nomination.character_nominations.count).to eq(1)
              expect(new_fandom_nomination.character_nominations[0].tagname).to eq("New Character")
            end

            it 'returns a flash message and redirects to tag set nomination page' do
              it_redirects_to_with_notice(tag_set_nomination_path(owned_tag_set, TagSetNomination.last),
                                          "Your nominations were successfully submitted.")
            end
          end

          context 'at least one character or relationship nomination is noncanonical' do
            # TODO: I can force test #request_nancanonical_info for these 2 tests by adding the
            # [:tag_set_nomination][:character_nominations_attributes][:from_fandom_nomination] param, but I don't
            # think the resulting params can actually be triggered by the UI
            # If so, how do I trigger the state where a new CharacterNom or RelationshipNom is created
            # with parented: false && parent_tagname: "", without failing CastNomination#known_fandom validation?
            context 'noncanonical character nominations are created' do
              let(:nomination_attributes) {
                { character_nominations_attributes: {
                    "0": { tagname: "New Character",
                           parent_tagname: "",
                           from_fandom_nomination: true } }
                }
              }

              it 'returns a flash message about noncanonical tags' do
                expect(flash[:notice]).to eq("Your nominations were successfully submitted." +
                                                 " Please consider editing to add fandoms to any of your non-canonical tags!")
              end
            end

            context 'noncanonical relationship nominations are created' do
              let(:nomination_attributes) {
                { relationship_nominations_attributes: {
                    "0": { tagname: "New Relationship",
                           parent_tagname: "",
                           from_fandom_nomination: true } }
                }
              }

              it 'returns a flash message about noncanonical tags' do
                expect(flash[:notice]).to eq("Your nominations were successfully submitted." +
                                                 " Please consider editing to add fandoms to any of your non-canonical tags!")
              end
            end
          end
        end

        context 'tag set nomination save fails' do
          let!(:old_tag_set_nom_count) { owned_tag_set.tag_set_nominations.count }

          before do
            owned_tag_set.nominated = false
            owned_tag_set.fandom_nomination_limit = 1
            owned_tag_set.character_nomination_limit = 2
            owned_tag_set.relationship_nomination_limit = 3
            owned_tag_set.freeform_nomination_limit = 1
            owned_tag_set.save(validate: false)

            post :create,
                 tag_set_id: owned_tag_set.id,
                 tag_set_nomination: { pseud_id: random_user.default_pseud.id,
                                       owned_tag_set_id: owned_tag_set.id }
          end

          it 'builds a new tag set nomination' do
            new_tag_set_nom_count = owned_tag_set.tag_set_nominations.count
            expect(old_tag_set_nom_count).to eq(new_tag_set_nom_count)
            expect(assigns(:tag_set_nomination).new_record?).to be_truthy
            expect(assigns(:tag_set_nomination).pseud).to eq(random_user.default_pseud)
            expect(assigns(:tag_set_nomination).owned_tag_set).to eq(owned_tag_set)
          end

          it 'builds new tag nominations until limits' do
            expect(assigns(:tag_set_nomination).fandom_nominations.size).to eq(1)
            expect(assigns(:tag_set_nomination).fandom_nominations[0].character_nominations.size).to eq(2)
            expect(assigns(:tag_set_nomination).fandom_nominations[0].relationship_nominations.size).to eq(3)
            expect(assigns(:tag_set_nomination).freeform_nominations.size).to eq(1)
          end

          it 'renders the new template' do
            expect(response).to render_template("new")
          end
        end
      end
    end
  end

  describe 'PUT update' do
    context 'user is not logged in' do
      it 'redirects and returns an error message' do
        put :update, tag_set_id: owned_tag_set.id, id: tag_set_nomination.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context 'user is logged in' do
      context 'invalid params' do
        before do
          fake_login_known_user(tag_nominator)
        end

        # TODO: how can OwnedTagSet.find not raise an error but still return falsey?
        xcontext 'no tag set' do
          it 'redirects and returns an error message' do
            put :update, tag_set_id: nil, id: tag_set_nomination.id, tag_set_nomination: {}
            it_redirects_to_with_error(tag_sets_path, "What tag set did you want to nominate for?")
          end
        end

        context 'pseud_id param does not match user' do
          it 'redirects and returns an error message' do
            put :update, tag_set_id: owned_tag_set.id, id: tag_set_nomination.id,
                tag_set_nomination: { pseud_id: random_user.default_pseud.id }
            it_redirects_to_with_error(root_path, "You can't nominate tags with that pseud.")
          end
        end

        # TODO: how can TagSetNomination.find not raise an error but still return falsey?
        xcontext 'no tag set nomination' do
          it 'redirects and returns an error message' do
            put :update, id: nil, tag_set_id: owned_tag_set.id, tag_set_nomination: {}
            it_redirects_to_with_error(user_tag_set_nominations_path(tag_nominator), "Which nominations did you want to work with?")
          end
        end
      end

      context 'valid params' do
        context 'user is not associated with nomination' do
          before do
            fake_login_known_user(random_user)
          end

          it 'redirects and returns an error message' do
            put :update, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id, tag_set_nomination: {}
            it_redirects_to_with_notice(tag_set_path(owned_tag_set),
                                        "You can only see your own nominations or nominations for a set you moderate.")
          end
        end

        context 'user is author of nomination' do
          before do
            fake_login_known_user(tag_nominator.reload) # Why reload?
          end

          context 'tag set nomination saves successfully' do
            before do
              owned_tag_set.update_attribute(:character_nomination_limit, 1)
              put :update,
                  tag_set_id: owned_tag_set.id,
                  id: tag_set_nomination.id,
                  tag_set_nomination: { pseud_id: tag_nominator_pseud.id,
                                        owned_tag_set_id: owned_tag_set.id }.merge(nomination_attributes)
              tag_set_nomination.reload
            end

            context 'all tag nominations are canonical' do
              let(:nomination_attributes) {
                { fandom_nominations_attributes: {
                    "0": { tagname: "Renamed Fandom",
                           character_nominations_attributes: {
                               "0": { tagname: "Renamed Character",
                                      from_fandom_nomination: true } } } }
                }
              }

              it 'updates the tag set nomination and associated tag nominations' do
                expect(tag_set_nomination.fandom_nominations[0].tagname).to eq("Renamed Fandom")
                expect(tag_set_nomination.fandom_nominations[0].character_nominations[0].tagname).to eq("Renamed Character")
              end

              it 'returns a flash message and redirects to tag set nomination page' do
                it_redirects_to_with_notice(tag_set_nomination_path(owned_tag_set, tag_set_nomination),
                                            "Your nominations were successfully updated.")
              end
            end

            context 'at least one character or relationship nomination is noncanonical' do
              # TODO: I can force test #request_nancanonical_info for these 2 tests by adding the
              # [:tag_set_nomination][:character_nominations_attributes][:from_fandom_nomination] param, but I don't
              # think the resulting params can actually be triggered by the UI
              # If so, how do I trigger the state where a new CharacterNom or RelationshipNom is created
              # with parented: false && parent_tagname: "", without failing CastNomination#known_fandom validation?
              let(:nomination_attributes) {
                { character_nominations_attributes: {
                    "0": { tagname: "Renamed Character",
                           parent_tagname: "",
                           from_fandom_nomination: true } }
                }
              }

              it 'returns a flash message about noncanonical tags' do
                expect(flash[:notice]).to eq("Your nominations were successfully updated." +
                                                 " Please consider editing to add fandoms to any of your non-canonical tags!")
              end
            end
          end

          context 'tag set nomination save fails' do
            before do
              owned_tag_set.nominated = false
              owned_tag_set.fandom_nomination_limit = 1
              owned_tag_set.character_nomination_limit = 2
              owned_tag_set.relationship_nomination_limit = 3
              owned_tag_set.freeform_nomination_limit = 1
              owned_tag_set.save(validate: false)

              put :update,
                  tag_set_id: owned_tag_set.id,
                  id: tag_set_nomination.id,
                  tag_set_nomination: { pseud_id: tag_nominator_pseud.id,
                                        owned_tag_set_id: owned_tag_set.id }
            end

            it 'builds new tag nominations until limits' do
              expect(assigns(:tag_set_nomination).fandom_nominations.size).to eq(1)
              expect(assigns(:tag_set_nomination).fandom_nominations[0].character_nominations.size).to eq(2)
              expect(assigns(:tag_set_nomination).fandom_nominations[0].relationship_nominations.size).to eq(3)
              expect(assigns(:tag_set_nomination).freeform_nominations.size).to eq(1)
            end

            it 'renders the edit template' do
              expect(response).to render_template("edit")
            end
          end
        end

        context 'user is moderator of tag set' do
          before do
            fake_login_known_user(moderator.reload) # Why reload?
            owned_tag_set.update_attribute(:character_nomination_limit, 1)
            put :update,
                tag_set_id: owned_tag_set.id,
                id: tag_set_nomination.id,
                tag_set_nomination: { pseud_id: mod_pseud.id,
                                      owned_tag_set_id: owned_tag_set.id,
                                      fandom_nominations_attributes: {
                                          "0": { tagname: "Renamed Fandom",
                                                 character_nominations_attributes: {
                                                     "0": { tagname: "Renamed Character",
                                                            from_fandom_nomination: true } } } } }
            tag_set_nomination.reload
          end

          it 'updates the tag set nomination and associated tag nominations' do
            expect(tag_set_nomination.fandom_nominations[0].tagname).to eq("Renamed Fandom")
            expect(tag_set_nomination.fandom_nominations[0].character_nominations[0].tagname).to eq("Renamed Character")
          end

          it 'returns a flash message and redirects to tag set nomination page' do
            it_redirects_to_with_notice(tag_set_nomination_path(owned_tag_set, tag_set_nomination),
                                        "Your nominations were successfully updated.")
          end
        end
      end
    end
  end

  describe 'DELETE destroy' do
    context 'user is not logged in' do
      it 'redirects and returns an error message' do
        delete :destroy, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context 'user is logged in' do
      context 'invalid params' do
        before do
          fake_login_known_user(tag_nominator)
        end

        # TODO: how can OwnedTagSet.find not raise an error but still return falsey?
        xcontext 'no tag set' do
          it 'redirects and returns an error message' do
            delete :destroy, id: tag_set_nomination.id, tag_set_id: nil
            it_redirects_to_with_error(tag_sets_path, "What tag set did you want to nominate for?")
          end
        end

        # TODO: how can TagSetNomination.find not raise an error but still return falsey?
        xcontext 'no tag set nomination' do
          it 'redirects and returns an error message' do
            delete :destroy, id: nil, tag_set_id: owned_tag_set.id
            it_redirects_to_with_error(user_tag_set_nominations_path(tag_nominator), "Which nominations did you want to work with?")
          end
        end
      end

      context 'valid params' do
        context 'user is not moderator of tag set' do
          before do
            fake_login_known_user(tag_nominator.reload) # Why reload?
          end

          context 'at least one tag nominations associated with tag_set_nomination is reviewed' do
            before do
              allow(TagSetNomination).to receive(:find) { tag_set_nomination } # hmm, is this the best way?
              allow(tag_set_nomination).to receive(:unreviewed?) { false }
            end

            it 'does not delete the tag set nomination' do
              delete :destroy, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
              expect(tag_set_nomination.reload).to eq(tag_set_nomination)
            end

            it 'redirects and returns an error message' do
              delete :destroy, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
              it_redirects_to_with_error(tag_set_nomination_path(owned_tag_set, tag_set_nomination),
                                         "You cannot delete nominations after some of them have been reviewed, sorry!")
            end
          end

          context 'all tag nominations associated with tag_set_nomination are unreviewed' do
            before do
              allow(TagSetNomination).to receive(:find) { tag_set_nomination } # hmm, is this the best way?
              allow(tag_set_nomination).to receive(:unreviewed?) { true }
            end

            it 'deletes the tag set nomination' do
              expect { delete :destroy, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id }.
                  to change { TagSetNomination.count }.by(-1)
            end

            it 'redirects and returns a success message' do
              delete :destroy, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
              it_redirects_to_with_notice(tag_set_path(owned_tag_set), "Your nominations were deleted.")
            end
          end
        end

        context 'user is moderator of tag set' do
          before do
            allow(TagSetNomination).to receive(:find) { tag_set_nomination } # hmm, is this the best way?
            allow(tag_set_nomination).to receive(:unreviewed?) { false }
            fake_login_known_user(moderator.reload) # Why reload?
          end

          it 'deletes the tag set nomination' do
            expect { delete :destroy, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id }.
                to change { TagSetNomination.count }.by(-1)
          end

          it 'redirects and returns a success message' do
            delete :destroy, id: tag_set_nomination.id, tag_set_id: owned_tag_set.id
            it_redirects_to_with_notice(tag_set_path(owned_tag_set), "Your nominations were deleted.")
          end
        end
      end
    end
  end

  describe 'GET confirm_destroy_multiple' do
    context 'user is not logged in' do
      it 'redirects and returns an error message' do
        get :confirm_destroy_multiple, tag_set_id: owned_tag_set.id
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context 'user is logged in' do
      before do
        fake_login_known_user(random_user)
      end

      context 'tag set exists' do
        it 'renders the confirm_destroy_multiple template' do
          get :confirm_destroy_multiple, tag_set_id: owned_tag_set.id
          expect(response).to render_template("confirm_destroy_multiple")
        end
      end

      # TODO: how can OwnedTagSet.find not raise an error but still return falsey?
      xcontext 'no tag set' do
        it 'redirects and returns an error message' do
          get :confirm_destroy_multiple, tag_set_id: nil
          it_redirects_to_with_error(tag_sets_path, "What tag set did you want to nominate for?")
        end
      end
    end
  end

  describe 'DELETE destroy_multiple' do

  end

  describe 'PUT update_multiple' do

  end
end
