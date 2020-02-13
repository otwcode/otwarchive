# frozen_string_literal: true

class ZohoAuthClient
  ACCESS_TOKEN_REQUEST_ENDPOINT = "https://accounts.zoho.com/oauth/v2/token"
  ACCESS_TOKEN_CACHE_KEY = "/v1/zoho_access_token"

  # TODO: Can we reduce this?
  SCOPE = "Desk.tickets.ALL,Desk.contacts.READ,Desk.contacts.WRITE,Desk.contacts.CREATE,Desk.basic.READ,Desk.search.READ"

  def access_token
    if (cached_token = Rails.cache.read(ACCESS_TOKEN_CACHE_KEY)).present?
      return cached_token
    end

    response_raw = HTTParty.post(ACCESS_TOKEN_REQUEST_ENDPOINT, query: access_token_params)
    response_json = JSON.parse(response_raw.body)
    access_token = response_json["access_token"]

    if (expires_in = response_json["expires_in_sec"]).present?
      # We don't want the token to expire while we're in the middle of a sequence
      # of requests, so we take the stated expiration time and subtract a little.
      Rails.cache.write(ACCESS_TOKEN_CACHE_KEY, access_token,
                        expires_in: expires_in - 1.minute)
    end

    # Return the access token:
    access_token
  end

  private

  def access_token_params
    {
      client_id: ArchiveConfig.ZOHO_CLIENT_ID,
      client_secret: ArchiveConfig.ZOHO_CLIENT_SECRET,
      redirect_uri: ArchiveConfig.ZOHO_REDIRECT_URI,
      scope: SCOPE,
      grant_type: "refresh_token",
      refresh_token: ArchiveConfig.ZOHO_REFRESH_TOKEN
    }
  end
end
