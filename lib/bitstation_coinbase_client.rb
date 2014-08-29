class BitStationCoinbaseClient < Coinbase::OAuthClient
  require 'fileutils'

  def initialize(client_id, client_secret, user_credentials, user, options = {})
    @user = user
    @client_id = client_id
    @client_secret = client_secret
    super(client_id, client_secret, user_credentials, options)

    # To make sure the lock directory exists
    FileUtils.mkdir_p(lock_directory)
  end

  def http_verb(verb, path, options = {})
    Rails.logger.info '#' * 80
    Rails.logger.info "http_verb invoked with verb = #{verb}"

    if @user.nil?
      super
    else
      @user.with_lock do
        old_credentials = @user.coinbase_account.oauth_credentials
        @oauth_token = OAuth2::AccessToken.from_hash(@oauth_client, old_credentials.symbolize_keys)

        result = super

        new_credentials = credentials
        @user.update!(oauth_credentials: new_credentials) unless (old_credentials == new_credentials)

        return result
      end
    end
  end

  private

    def lock_directory
      @lock_directory ||= Rails.root.join('tmp/api_locks')
    end

    def lock_path
      @user ?
        lock_directory.join("#{@user.try(:id)}") :
        nil
    end

end


# tmp/api_locks/:id