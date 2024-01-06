require "spec_helper"

describe KudoMailer do
  describe "batch_kudo_notification" do
    subject(:email) { KudoMailer.batch_kudo_notification(creator.id, kudos_json) }

    let!(:creator) { work.users.first }
    let(:work) { create(:work) }

    context "when there is one work" do
      context "with one guest kudos" do
        let(:kudos_json) do
          hash = {}
          hash["#{work.class.name}_#{work.id}"] = { guest_count: 1, names: [] }
          hash.to_json
        end

        it_behaves_like "an email with a valid sender"

        it "has the correct subject line" do
          subject = "[#{ArchiveConfig.APP_SHORT_NAME}] You've got kudos!"
          expect(email).to have_subject(subject)
        end

        # Test both body contents
        it_behaves_like "a multipart email"

        it_behaves_like "a translated email"

        describe "HTML version" do
          it "has the correct content" do
            expect(email).to have_html_part_content("<b style=\"color:#990000\">A guest</b>")
            expect(email).to have_html_part_content("left kudos on <")
          end
        end

        describe "text version" do
          it "has the correct content" do
            expect(email).to have_text_part_content("A guest left kudos on \"#{work.title}\"")
          end
        end
      end
    end
  end

  describe "obeys the set locale preference feature flag" do
    let(:user) { create(:user) }
    let(:work) { create(:work, authors: [user.default_pseud]) }
    let(:kudos_json) do
      hash = {}
      hash["#{work.class.name}_#{work.id}"] = { guest_count: 1, names: [] }
      hash.to_json
    end
    let(:locale) { create(:locale) }

    context "when the set locale preference feature flag is on" do
      before { $rollout.activate_user(:set_locale_preference, user) }

      context "and the user has non-default locale set" do
        before { user.preference.update!(preferred_locale: locale.id) }

        it "sends a localised email" do
          expect(I18n).to receive(:with_locale).with(locale.iso)
          expect(KudoMailer.batch_kudo_notification(user.id, kudos_json)).to be_truthy
        end
      end

      context "and the user has the default locale set" do
        before { user.preference.update!(preferred_locale: Locale.default.id) }

        it "sends an English email" do
          expect(I18n).to receive(:with_locale).with("en")
          expect(KudoMailer.batch_kudo_notification(user.id, kudos_json)).to be_truthy
        end
      end
    end

    context "when the set locale preference feature flag is off" do
      before { $rollout.deactivate_user(:set_locale_preference, user) }

      context "and the user has non-default locale set" do
        before { user.preference.update!(preferred_locale: locale.id) }

        it "sends an English email" do
          expect(I18n).to receive(:with_locale).with("en")
          expect(KudoMailer.batch_kudo_notification(user.id, kudos_json)).to be_truthy
        end
      end

      context "and the user has the default locale set" do
        before { user.preference.update!(preferred_locale: Locale.default.id) }

        it "sends an English email" do
          expect(I18n).to receive(:with_locale).with("en")
          expect(KudoMailer.batch_kudo_notification(user.id, kudos_json)).to be_truthy
        end
      end
    end
  end
end
