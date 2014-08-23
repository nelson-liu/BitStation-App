class Transaction < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :money_request

  has_many :comments, foreign_key: 'associated_transaction_id'

  enum status: [:pending, :completed, :failed]

  scope :public_transactions, -> { where(is_public: true) }

  extend ApplicationHelper
  include ApplicationHelper

  def self.display_data_from_cb_transaction(t, current_coinbase_id)
    begin
      r = {
        time: DateTime.parse(t['created_at']),
        display_time: DateTime.parse(t['created_at']).strftime('%b %d'),
        amount: friendly_amount_from_money(t['amount']),
        direction: t['sender'].nil? ? :from : ((t['sender']['id'] == current_coinbase_id) ? :to : :from),
        pending: t['status'] == 'pending',
        load: Rails.application.routes.url_helpers.transaction_path(id: t['id'])
      }
    rescue => e
      puts e.message
    end
    puts t

    if t['transfer_type']
      r[:transfer_type] = t['transfer_type']
      if t['transfer_type'] == "sell"
        r[:target] = "Coinbase Sell"
      else 
        r[:target] = "Coinbase Buy"
      end
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
        puts r[:target_type]
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
      comments: {
        count: comments.count,
      },
      like_link: Rails.application.routes.url_helpers.transaction_path(self),
      load: Rails.application.routes.url_helpers.transaction_path(self)
    }
  end
end
