require "spec_helper"

shared_examples "a justifiable model" do
  it "does not require a ticket ID by default" do
    record.assign_attributes(attributes)
    expect(record).to be_valid
  end

  context "when logged in as an admin" do
    let(:zoho_resource_client) { instance_double("ZohoResourceClient") }

    before do
      User.current_user = create(:admin)
      allow_any_instance_of(ZohoAuthClient).to receive(:access_token)
    end

    it "does not require a ticket ID if unchanged" do
      expect(ZohoResourceClient).not_to receive(:new)

      expect(record).to be_valid
    end

    it "requires a ticket ID" do
      expect(ZohoResourceClient).not_to receive(:new)

      record.assign_attributes(attributes)
      expect(record).not_to be_valid
      expect(record.errors[:ticket_number]).to contain_exactly("can't be blank", "is not a number")
    end

    it "is invalid if the ticket does not exist" do
      expect(ZohoResourceClient).to receive(:new).and_return(zoho_resource_client)
      expect(zoho_resource_client).to receive(:find_ticket)

      record.assign_attributes(attributes.merge(ticket_number: 480_000))
      expect(record).not_to be_valid
      expect(record.errors[:ticket_number]).to contain_exactly("must exist")
    end

    it "is invalid if the ticket is closed" do
      expect(ZohoResourceClient).to receive(:new).and_return(zoho_resource_client)
      expect(zoho_resource_client).to receive(:find_ticket).and_return({ "status" => "Closed" })

      record.assign_attributes(attributes.merge(ticket_number: 480_000))
      expect(record).not_to be_valid
      expect(record.errors[:ticket_number]).to contain_exactly("must exist")
    end

    context "when an open policy and abuse ticket exists" do
      let(:ticket) { { "departmentId" => ArchiveConfig.ABUSE_ZOHO_DEPARTMENT_ID, "status" => "Open" } }

      it "is invalid if the admin does not have role policy_and_abuse" do
        expect(ZohoResourceClient).to receive(:new).and_return(zoho_resource_client)
        expect(zoho_resource_client).to receive(:find_ticket).and_return(ticket)

        record.assign_attributes(attributes.merge(ticket_number: 480_000))
        expect(record).not_to be_valid
        expect(record.errors[:ticket_number]).to contain_exactly("must exist")
      end

      %w[policy_and_abuse superadmin].each do |role|
        it "is valid if the admin has role #{role}" do
          User.current_user.update!(roles: [role])
          expect(ZohoResourceClient).to receive(:new).and_return(zoho_resource_client)
          expect(zoho_resource_client).to receive(:find_ticket).and_return(ticket)

          record.assign_attributes(attributes.merge(ticket_number: 480_000))
          expect(record).to be_valid
        end
      end
    end

    context "when an open support ticket exists" do
      let(:ticket) { { "departmentId" => ArchiveConfig.SUPPORT_ZOHO_DEPARTMENT_ID, "status" => "Open" } }

      it "is invalid if the admin does not have role support" do
        expect(ZohoResourceClient).to receive(:new).and_return(zoho_resource_client)
        expect(zoho_resource_client).to receive(:find_ticket).and_return(ticket)

        record.assign_attributes(attributes.merge(ticket_number: 480_000))
        expect(record).not_to be_valid
        expect(record.errors[:ticket_number]).to contain_exactly("must exist")
      end

      %w[superadmin support].each do |role|
        it "is valid if the admin has role #{role}" do
          User.current_user.update!(roles: [role])
          expect(ZohoResourceClient).to receive(:new).and_return(zoho_resource_client)
          expect(zoho_resource_client).to receive(:find_ticket).and_return(ticket)

          record.assign_attributes(attributes.merge(ticket_number: 480_000))
          expect(record).to be_valid
        end
      end
    end
  end
end

describe Profile do
  it_behaves_like "a justifiable model" do
    let!(:record) { create(:user).profile.tap(&:save!) }
    let(:attributes) { { about_me: "I stole a fragment of the Rune of Death." } }
  end
end
