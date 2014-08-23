class Transaction < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :money_request

  enum status: [:pending, :completed, :failed]

  scope :public_transactions, -> { where(is_public: true) }

  extend ApplicationHelper
  include ApplicationHelper

  def self.display_data_from_cb_transaction(t, current_coinbase_id)
    r = {
      time: DateTime.parse(t['created_at']),
      display_time: DateTime.parse(t['created_at']).strftime('%b %d'),
      amount: friendly_amount_from_money(t['amount']),
      direction: (t['sender']['id'] == current_coinbase_id) ? :to : :from,
      pending: t['status'] == 'pending',
      load: Rails.application.routes.url_helpers.transaction_path(id: t['id'])
    }

    if t['transfer_type']
      r[:transfer_type] = t['transfer_type']
    else
      if r[:direction] == :to
        r[:target] = t['recipient'] ? (CoinbaseAccount.find_by_email(t['recipient']['email']).user.name rescue t['recipient']['name']) : 'External Account'
        r[:target_type] = t['recipient'] ?
          (CoinbaseAccount.find_by_email(t['recipient']['email']) ? :bitstation : :coinbase) :
          :external
      else
        r[:target] = t['sender'] ? (CoinbaseAccount.find_by_email(t['sender']['email']).user.name rescue t['sender']['name']) : 'External Account'
        r[:target_type] = t['sender'] ?
          (CoinbaseAccount.find_by_email(t['sender']['email']) ? :bitstation : :coinbase) :
          :external
      end
    end

    r
  end

  def sender_name
    sender.name
  end

  def recipient_name
    recipient ? recipient.name : 'External User'
  end

  def has_message?
    message && !message.strip.empty?
  end

  def to_activity
    {
      title: "#{sender_name} gave #{recipient_name} #{friendly_amount(amount, 'BTC')}! ",
      content: has_message? ? "\"#{message}\"" : 'Without saying anything :( ',
      like_link: Rails.application.routes.url_helpers.transaction_path(self)
    }
  end
end
