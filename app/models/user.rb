class User < ActiveRecord::Base
  has_one :coinbase_account
end
