class TransactionMailer < ActionMailer::Base
  default from: "bitstation@bs.ljh.me"

  add_template_helper(ApplicationHelper)

  def request_money(sender, requestee, amount, message, respond_link)
    return if requestee.coinbase_account.nil?

    @sender_name = sender.name
    @amount = amount
    @has_messge = message && (!message.strip.empty?)
    @message = message
    @respond_link = respond_link

    mail to: requestee.coinbase_account.email,
         subject: "#{sender.name} is requesting #{amount} BTC from you. "
  end
end
