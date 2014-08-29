class BitStationCoinbaseClient < Coinbase::OAuthClient
  def initialize(client_id, client_secret, user_credentials, user, options = {})
    @user = user
    @client_id = client_id
    @client_secret = client_secret
    super(client_id, client_secret, user_credentials, options)
  end

  def http_verb(verb, path, options = {})
    if @user.nil?
      super
    else
      @user.coinbase_account.with_lock do
        account = @user.coinbase_account
        old_credentials = account.oauth_credentials
        @oauth_token = OAuth2::AccessToken.from_hash(@oauth_client, old_credentials.symbolize_keys)

        result = super

        new_credentials = credentials
        account.update!(oauth_credentials: new_credentials) unless (old_credentials == new_credentials)

        return result
      end
    end
  end
end
