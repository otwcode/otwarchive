# frozen_string_literal: true

require "spec_helper"

shared_examples "a password resets limitable" do
  describe "#password_resets_remaining" do
    shared_examples "return the maximum number of attempts" do
      it "returns the maximum number of attempts" do
        expect(subject.password_resets_remaining).to eq(ArchiveConfig.PASSWORD_RESET_LIMIT)
      end
    end

    context "with 0 resets requested" do
      it_behaves_like "return the maximum number of attempts"
    end

    context "with under the maximum number of resets requested" do
      before do
        subject.resets_requested = ArchiveConfig.PASSWORD_RESET_LIMIT - 1
      end

      context "when the last reset request time is not set" do
        it_behaves_like "return the maximum number of attempts"
      end

      context "when the cooldown period has not passed" do
        before do
          subject.reset_password_sent_at = Time.current
        end

        it "returns the expected number of attempts" do
          expect(subject.password_resets_remaining).to eq(1)
        end
      end

      context "when the cooldown period has passed" do
        before do
          subject.reset_password_sent_at = ArchiveConfig.PASSWORD_RESET_COOLDOWN_HOURS.hours.ago
        end

        it_behaves_like "return the maximum number of attempts"
      end
    end

    shared_examples "no more reset requests left" do
      context "when the last reset request time is not set" do
        it_behaves_like "return the maximum number of attempts"
      end

      context "when the cooldown period has not passed" do
        before do
          subject.reset_password_sent_at = Time.current
        end

        it "returns 0 remaining attempts" do
          expect(subject.password_resets_remaining).to eq(0)
        end
      end

      context "when the cooldown period has passed" do
        before do
          subject.reset_password_sent_at = ArchiveConfig.PASSWORD_RESET_COOLDOWN_HOURS.hours.ago
        end

        it_behaves_like "return the maximum number of attempts"
      end
    end

    context "with the maximum number of resets requested" do
      before do
        subject.resets_requested = ArchiveConfig.PASSWORD_RESET_LIMIT
      end

      it_behaves_like "no more reset requests left"
    end

    context "with over the maximum number of resets requested" do
      before do
        subject.resets_requested = ArchiveConfig.PASSWORD_RESET_LIMIT + 1
      end

      it_behaves_like "no more reset requests left"
    end
  end

  describe "#password_resets_limit_reached?" do
    shared_examples "limit not yet reached" do
      it "has not reached the requests limit" do
        expect(subject.password_resets_limit_reached?).to be_falsy
      end
    end

    context "with 0 resets requested" do
      it_behaves_like "limit not yet reached"
    end

    context "with the maximum number of password resets requested" do
      before do
        subject.resets_requested = ArchiveConfig.PASSWORD_RESET_LIMIT
      end

      context "when the last reset request time is not set" do
        it_behaves_like "limit not yet reached"
      end

      context "when the cooldown period has passed" do
        before do
          subject.reset_password_sent_at = ArchiveConfig.PASSWORD_RESET_COOLDOWN_HOURS.hours.ago
        end

        it "has not reached the requests limit" do
          expect(subject.password_resets_limit_reached?).to be_falsy
        end
      end

      context "when the cooldown period has not passed" do
        before do
          subject.reset_password_sent_at = Time.current
        end

        it "has reached the requests limit" do
          expect(subject.password_resets_limit_reached?).to be_truthy
        end
      end
    end
  end

  describe "#update_password_resets_requested" do
    context "with 0 resets requested" do
      it "increments the password reset requests field" do
        expect { subject.update_password_resets_requested }
          .to change { subject.resets_requested }
          .to(1)
      end
    end

    context "with under the maximum number of password resets requested" do
      before do
        subject.resets_requested = ArchiveConfig.PASSWORD_RESET_LIMIT - 1
      end

      context "when the cooldown period has passed" do
        before do
          subject.reset_password_sent_at = ArchiveConfig.PASSWORD_RESET_COOLDOWN_HOURS.hours.ago
        end

        it "resets the password reset request field to 1" do
          expect { subject.update_password_resets_requested }
            .to change { subject.resets_requested }
            .to(1)
        end
      end

      context "when the cooldown period has not passed" do
        before do
          subject.reset_password_sent_at = Time.current
        end

        it "increments the password reset requests field" do
          expect { subject.update_password_resets_requested }
            .to change { subject.resets_requested }
            .by(1)
        end
      end
    end

    context "with the maximum number of password resets requested" do
      before do
        subject.resets_requested = ArchiveConfig.PASSWORD_RESET_LIMIT
      end

      context "when the cooldown period has passed" do
        before do
          subject.reset_password_sent_at = ArchiveConfig.PASSWORD_RESET_COOLDOWN_HOURS.hours.ago
        end

        it "resets the password reset request field to 1" do
          expect { subject.update_password_resets_requested }
            .to change { subject.resets_requested }
            .to(1)
        end
      end
    end
  end
end

describe User do
  it_behaves_like "a password resets limitable"
end
