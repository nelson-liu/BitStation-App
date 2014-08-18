class Contact < ActiveRecord::Base
  belongs_to :user

  def to_user
    external? ?
      nil :
      CoinbaseAccount.user_with_email(address)
  end

  def external?
    !is_valid_email?(address)
  end

  def bitstation?
    (!external?) && !to_user.nil?
  end

  def coinbase?
    (!external?) && to_user.nil?
  end

  def source
    if external?
      :external
    elsif bitstation?
      :bitstation
    else
      :coinbase
    end
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
end
