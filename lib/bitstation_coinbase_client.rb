class BitStationCoinbaseClient < Coinbase::OAuthClient
  # Lock the token within 30s of refreshing time
  TOKEN_LOCK_THRESHOLD = 30

  def initialize(client_id, client_secret, user_credentials, user, options = {})
    @user = user
    super(client_id, client_secret, user_credentials, options)
  end

  def http_verb(verb, path, options = {})
    if @user.nil? || @user.coinbase_account.nil? || !@user.coinbase_account.token_expires_in?(TOKEN_LOCK_THRESHOLD.seconds)
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
