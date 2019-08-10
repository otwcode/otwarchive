class ZohoAuthClient
  ACCESS_TOKEN_REQUEST_ENDPOINT = 'https://accounts.zoho.com/oauth/v2/token'.freeze

  # TODO: Can we get rid of this? We don't redirect, but it has to match
  # whatever was filled in when creating the original grant_code
  REDIRECT_URI = 'https://archiveofourown.org/support'.freeze

  # TODO: Can we reduce this?
  SCOPE = 'Desk.tickets.ALL,Desk.contacts.READ,Desk.contacts.WRITE,Desk.contacts.CREATE,Desk.basic.READ,Desk.search.READ'.freeze

  def initialize
    @access_token = access_token
  end

  def access_token
    response_raw = HTTParty.post(ACCESS_TOKEN_REQUEST_ENDPOINT + '?' + query_string(access_token_params))
    JSON.parse(response_raw.body)['access_token']
  end

  private

  def access_token_params
    {
      client_id: ArchiveConfig.ZOHO_CLIENT_ID,
      client_secret: ArchiveConfig.ZOHO_CLIENT_SECRET,
      redirect_uri: REDIRECT_URI,
      scope: SCOPE,
      grant_type: 'refresh_token',
      refresh_token: ArchiveConfig.ZOHO_REFRESH_TOKEN
    }
  end

  def query_string(params)
    params.map { |k, v| "#{k}=#{v}" }.join('&')
  end
end
