class Contact < ActiveRecord::Base
  belongs_to :user

  validates :address, uniqueness: {scope: :user_id}, presence: true
  validates :name, length: {minimum: 1, maximum: 50}

  validate :address_is_valid

  def to_user
    case self.class.source_from_address(address)
    when :bitstation
      User.find_by(kerberos: address)
    when :coinbase
      CoinbaseAccount.user_with_email(address)
    when :external
      nil
    end
  end

  def to_search_suggestion
    {
      'address' => address,
      'name' => name,
      'tokens' => name.split(' ') + [address],
      'type' => source.to_s
    }
  end

  def external?
    self.class.source_from_address(address) == :external
  end

  def bitstation?
    self.class.source_from_address(address) == :bitstation
  end

  def coinbase?
    self.class.source_from_address(address) == :coinbase
  end

  def source
    self.class.source_from_address(address)
  end

  def self.source_from_address(address)
    return nil if address.nil?
    return User.address_type(address)
  end

  def self.normalize_address(address)
    address.strip!
    return nil if source_from_address(address).nil?
    address
  end

  def address=(address)
    super self.class.normalize_address(address)
  end

  def name=(name)
    super name.strip
  end

  def source
    self.class.source_from_address(address)
  end

  def email
    case source
    when :external
      nil
    when :bitstation
      to_user.coinbase_account.email
    when :coinbase
      address
    end
  end

  private
    def is_valid_email?(e)
      begin
        m = Mail::Address.new(e)
        m.domain && m.address
      rescue Mail::Field::ParseError => e
        false
      end
    end

    def address_is_valid
      errors.add(:address, 'Invalid address. ') if self.class.source_from_address(address).nil?
    end
end
