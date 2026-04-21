require "spec_helper"

describe EmailCanonicalizer do
  describe ".canonicalize" do
    context "basic normalization" do
      it "converts uppercase letters to lowercase" do
        expect(EmailCanonicalizer.canonicalize("User@Example.COM")).to eq("user@example.com")
      end

      it "strips whitespace" do
        expect(EmailCanonicalizer.canonicalize("  user@example.com  ")).to eq("user@example.com")
      end
    end

    context "googlemail conversion" do
      it "converts @googlemail.com to @gmail.com" do
        expect(EmailCanonicalizer.canonicalize("user@googlemail.com")).to eq("user@gmail.com")
      end
    end

    context "gmail period handling" do
      it "removes periods from gmail addresses" do
        expect(EmailCanonicalizer.canonicalize("u.s.e.r@gmail.com")).to eq("user@gmail.com")
      end

      it "does not remove periods from non-gmail addresses" do
        expect(EmailCanonicalizer.canonicalize("user.name@example.com")).to eq("user.name@example.com")
      end

      it "removes periods from googlemail addresses after conversion" do
        expect(EmailCanonicalizer.canonicalize("user.name@googlemail.com")).to eq("username@gmail.com")
      end
    end

    context "plus tags handling" do
      it "removes everything after a plus sign" do
        expect(EmailCanonicalizer.canonicalize("user+tag@example.com")).to eq("user@example.com")
      end

      it "handles multiple plus signs" do
        expect(EmailCanonicalizer.canonicalize("user+tag+extra@example.com")).to eq("user@example.com")
      end
    end

    context "combined operations" do
      it "does all operations" do
        expect(EmailCanonicalizer.canonicalize("  User.Name+tag@GOOGLEMAIL.COM  ")).to eq("username@gmail.com")
      end
    end
  end
end
