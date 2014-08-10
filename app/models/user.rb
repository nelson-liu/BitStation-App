class User < ActiveRecord::Base
  has_one :coinbase_account

  has_many :pending_outgoing_transactions, class_name: 'PendingTransaction', foreign_key: 'sender_id'
  has_many :pending_incoming_transactions, class_name: 'PendingTransaction', foreign_key: 'recipient_id'

  validates :kerberos, uniqueness: true, presence: true
  validates :name, presence: true

  def update_coinbase_oauth_credentials(credentials)
    coinbase_account.update({oauth_credentials: credentials})
  end
end
