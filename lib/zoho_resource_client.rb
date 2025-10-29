# frozen_string_literal: true

class ZohoResourceClient
  CONTACT_SEARCH_ENDPOINT = "https://desk.zoho.com/api/v1/contacts/search"
  CONTACT_CREATE_ENDPOINT = "https://desk.zoho.com/api/v1/contacts"
  TICKET_SEARCH_ENDPOINT = "https://desk.zoho.com/api/v1/tickets/search"
  TICKET_CREATE_ENDPOINT = "https://desk.zoho.com/api/v1/tickets"

  def initialize(access_token:, email: nil)
    @access_token = access_token
    @email = email
  end

  def retrieve_contact_id
    (find_contact || create_contact).fetch("id")
  end

  def find_ticket(ticket_number)
    response = HTTParty.get(
      TICKET_SEARCH_ENDPOINT,
      query: search_params.merge(ticketNumber: ticket_number),
      headers: headers
    ).parsed_response

    # Note that Zoho returns an empty 204 if the ticket is marked as spam.
    return if response.blank? || response.key?("errorCode")

    response.fetch("data").first
  end

  def create_ticket(ticket_attributes:)
    HTTParty.post(
      TICKET_CREATE_ENDPOINT,
      headers: headers,
      body: ticket_attributes.to_json
    ).parsed_response
  end

  def create_ticket_attachment(ticket_id:, attachment_attributes:)
    response = HTTParty.post(
      ticket_attachment_create_endpoint(ticket_id),
      headers: headers,
      body: attachment_attributes
    ).parsed_response
    raise response["message"] if response["errorCode"]

    response
  end

  def find_contact
    response = HTTParty.get(
      CONTACT_SEARCH_ENDPOINT,
      query: search_params.merge(email: @email),
      headers: headers
    ).parsed_response
    return if response.blank? || response.key?("errorCode")

    response.fetch("data").first
  end

  def create_contact
    HTTParty.post(
      CONTACT_CREATE_ENDPOINT,
      headers: headers,
      body: contact_body.to_json
    ).parsed_response
  end

  def search_params
    {
      limit: 1,
      sortBy: "modifiedTime"
    }
  end

  def headers
    {
      "Content-Type" => "application/json",
      "orgId" => ArchiveConfig.ZOHO_ORG_ID,
      "Authorization" => "Zoho-oauthtoken #{@access_token}"
    }
  end

  def contact_body
    {
      "lastName" => @email,
      "email" => @email
    }
  end

  private

  def ticket_attachment_create_endpoint(ticket_id)
    "#{ArchiveConfig.ZOHO_URL}/api/v1/tickets/#{ticket_id}/attachments"
  end
end
