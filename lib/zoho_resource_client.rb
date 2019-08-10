class ZohoResourceClient
  CONTACT_SEARCH_ENDPOINT = 'https://desk.zoho.com/api/v1/contacts/search'.freeze
  CONTACT_CREATE_ENDPOINT = 'https://desk.zoho.com/api/v1/contacts'.freeze
  TICKET_CREATE_ENDPOINT = 'https://desk.zoho.com/api/v1/tickets'.freeze

  def initialize(access_token:, email:, username: nil)
    @access_token = access_token
    @email = email
    @username = username
  end

  def retrieve_contact_id
    (find_contact || create_contact).fetch('id')
  end

  def create_ticket(ticket_attributes:)
    response_raw = HTTParty.post(
      TICKET_CREATE_ENDPOINT,
      headers: headers,
      body: ticket_attributes.to_json
    )
    JSON.parse(response_raw.body)
  end

  private

  def find_contact
    response_raw = HTTParty.get(
      CONTACT_SEARCH_ENDPOINT, query: search_params,
      headers: headers
    )
    return if response_raw.nil?

    JSON.parse(response_raw.body).fetch('data').first
  end

  def create_contact
    response_raw = HTTParty.post(
      CONTACT_CREATE_ENDPOINT,
      headers: headers,
      body: contact_body.to_json
    )
    JSON.parse(response_raw.body)
  end

  def search_params
    {
      email: @email,
      limit: 1,
      sortBy: 'modifiedTime'
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
      "lastName" => @username.presence || @email,
      "email" => @email
    }
  end
end
