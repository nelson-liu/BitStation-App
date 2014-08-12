class TransactionMailer < ActionMailer::Base
  default from: "BitStation@bs.ljh.me"

  add_template_helper(ApplicationHelper)
  include ApplicationHelper

  def request_money(sender, requestee, amount, message, respond_link)
    return if requestee.coinbase_account.nil?

    @sender_name = sender.name
    @amount = amount
    @has_messge = message && (!message.strip.empty?)
    @message = message
    @respond_link = respond_link

    mail to: requestee.coinbase_account.email,
         subject: "#{sender.name} is requesting #{friendly_amount(amount, 'BTC')} from you. "
  end
end
