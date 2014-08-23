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

  ADDRESS_TYPE_LABEL_CLASS = {
    bitstation: 'danger',
    coinbase: 'primary',
    external: 'warning'
  }

  ADDRESS_TYPE_LABEL_TEXT = {
    char: {
      bitstation: 'M',
      coinbase: 'C',
      external: 'E'
    }, short: {
      bitstation: 'MIT',
      coinbase: 'CB',
      external: 'Ext'
    }
  }

  def address_type_label(type, text_level = :char, options = {})
    type = type.to_sym
    html_class = "label label-#{ADDRESS_TYPE_LABEL_CLASS[type]} address-type-label-#{text_level} "
    html_class += options.delete(:class) if options[:class]
    content_tag(:span, ADDRESS_TYPE_LABEL_TEXT[text_level][type],
      options.merge({
        class: html_class
      })
    );
  end

  def coinbase_account_linkage_status_message(status)
      result += '<p class="autocomplete-coinbase-link-status text-success">Coinbase account linked</p>'
    else
      result += '<p class="autocomplete-coinbase-link-status text-danger">No Coinbase account linked</p>'
  end
end
