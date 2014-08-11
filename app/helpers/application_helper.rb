module ApplicationHelper
  def friendly_amount_from_money(amount, options = {})
    friendly_amount(amount.amount, amount.currency, options)
  end

  def friendly_amount(amount, currency, options = {})
    round = options[:round] || 2

    case currency
    when 'BTC'
      (amount * 1000).round(round).to_s + ' mBTC'
    when 'USD'
      amount.round(round).to_s + ' USD'
    end
  end
end
