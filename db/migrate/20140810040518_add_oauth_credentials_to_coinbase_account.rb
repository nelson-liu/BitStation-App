class AddOauthCredentialsToCoinbaseAccount < ActiveRecord::Migration
  def change
    add_column :coinbase_accounts, :oauth_credentials, :text
  end
end
