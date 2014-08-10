class User < ActiveRecord::Base
  has_one :coinbase_account

  validates :kerberos, uniqueness: true, presence: true
  validates :name, presence: true

  def update_coinbase_oauth_credentials(credentials)
    coinbase_account.update({oauth_credentials: credentials})
  end
end
