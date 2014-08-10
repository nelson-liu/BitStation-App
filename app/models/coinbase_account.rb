class CoinbaseAccount < ActiveRecord::Base
  belongs_to :user
  serialize :oauth_credentials, Hash
end
