class CoinbaseAccount < ActiveRecord::Base
  belongs_to :user

  validates :email, uniqueness: true, presence: true
  validates :user_id, uniqueness: true

  serialize :oauth_credentials, Hash

  def self.user_with_email(email)
    find_by(email: email).user rescue nil
  end

  def token_expires_in?(time)
    oauth_credentials ?
      (Time.at(oauth_credentials["expires_at"]) - Time.now) <= time :
      false
  end
end
