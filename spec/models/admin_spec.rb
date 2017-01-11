require 'spec_helper'

describe Admin, :ready do


  it "can be created" do
    expect(create(:admin)).to be_valid
  end

  context "invalid" do

    it 'without a user name' do
      expect { create(:admin, login: nil) }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Login is too short (minimum is 3 characters), Login should use only letters, numbers, spaces, and .-_@ please.")
    end

    it 'without an email address' do
      expect { create(:admin, email: nil) }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Email should look like an email address.")
    end

    it 'without a password' do
      expect { create(:admin, password: nil) }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Password is too short (minimum is 4 characters), Password confirmation is too short (minimum is 4 characters)")
    end

    it 'without a password confirmation' do
      expect { create(:admin, password_confirmation: nil) }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Password confirmation is too short (minimum is 4 characters)")
    end
  end
  
  context "length of login" do
  
    it "if under #{ArchiveConfig.LOGIN_LENGTH_MIN} long characters" do
      expect { create(:admin, login: Faker::Lorem.characters(ArchiveConfig.LOGIN_LENGTH_MIN - 1)) }.to \
       raise_error(ActiveRecord::RecordInvalid, "Validation failed: Login is too short (minimum is #{ArchiveConfig.LOGIN_LENGTH_MIN} characters)")
    end
   
    # This should be is invalid if over #{ArchiveConfig.LOGIN_LENGTH_MAX} characters however 
    it "is invalid if over 100 characters" do
      expect { create(:admin, login: Faker::Lorem.characters(101)) }.to \
       raise_error(ActiveRecord::RecordInvalid, "Validation failed: Login is too long (maximum is 100 characters)")
    end
  end
  
  context "length of password" do
  
    it "is invalid if under 4 characters" do
      expect { create(:admin, password: Faker::Lorem.characters(3)) }.to \
       raise_error(ActiveRecord::RecordInvalid, "Validation failed: Password is too short (minimum is 4 characters), Password confirmation is too short (minimum is 4 characters)")
    end
  
    xit "is invalid if over 101 characters" do
      expect { create(:admin, password: Faker::Lorem.characters(1010))}.to \
       raise_error(ActiveRecord::RecordInvalid, "")
    end
  end

  context "uniqueness" do
    let(:existing_user) {create(:admin)}

    it "is invalid if login is not unique" do
      expect { create(:admin, login: existing_user.login) }.to \
       raise_error(ActiveRecord::RecordInvalid, "Validation failed: Login has already been taken")
    end

    it "is invalid if email already exists" do
      expect { create(:admin, email: existing_user.email) }.to \
       raise_error(ActiveRecord::RecordInvalid, "Validation failed: Email has already been taken")
    end

  end
end
