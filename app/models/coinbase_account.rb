class CoinbaseAccount < ActiveRecord::Base
  belongs_to :user

  validates :email, uniqueness: true, presence: true
  validates :user_id, uniqueness: true

  serialize :oauth_credentials, Hash
end
