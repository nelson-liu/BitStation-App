class TransactionMailer < ActionMailer::Base
  default from: "BitStation@bs.ljh.me"

  layout 'basic_mailer'

  add_template_helper(ApplicationHelper)
  include ApplicationHelper

  def request_money(sender, requestee, amount, dollar_amount, message, respond_link, is_resend = false)
    return if requestee.coinbase_account.nil?

    @sender_name = sender.name
    @requestee_name = requestee.name
    @amount = friendly_amount(amount, 'BTC')
    @dollar_amount = friendly_amount(dollar_amount, 'USD')
    @has_messge = message && (!message.strip.empty?)
    @message = message
    @respond_link = respond_link
    @is_resend = is_resend

    mail to: requestee.coinbase_account.email,
         subject: "#{sender.name} is requesting #{friendly_amount(amount, 'BTC')} from you. "
  end

  def resend_money_request(r, respond_link)
    request_money(r.sender, r.requestee, r.amount, r.dollar_amount, r.message, respond_link)
  end
end
