class User < ActiveRecord::Base
  has_one :coinbase_account

  has_many :pending_outgoing_transactions, class_name: 'PendingTransaction', foreign_key: 'sender_id'
  has_many :pending_incoming_transactions, class_name: 'PendingTransaction', foreign_key: 'recipient_id'

  validates :kerberos, uniqueness: true, presence: true
  validates :name, presence: true

  def update_coinbase_oauth_credentials(credentials)
    coinbase_account.update({oauth_credentials: credentials})
  end

  def new_access_code
    update({access_code: generate_access_code, access_code_redeemed: false})
    access_code
  end

  def revoke_access_code
    update({access_code: nil, access_code_redeemed: false})
  end

  def self.user_with_unredeemed_access_code(code)
    where({access_code: code, access_code_redeemed: false}).first
  end

  def self.user_with_access_code(code)
    where({access_code: code}).first
  end

  private

    def generate_access_code
      require 'securerandom'
      SecureRandom.hex(32)
    end
end
