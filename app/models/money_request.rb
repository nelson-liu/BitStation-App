class MoneyRequest < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :requestee, class_name: 'User'

  has_one :associated_transaction, class_name: 'Transaction'

  enum status: [:pending, :paid, :denied]

  include ApplicationHelper

  def to_display_data(current_user)
    {
      time: created_at,
      display_time: created_at.strftime('%b %d'),
      amount: friendly_amount(amount, 'BTC'),
      direction: sender == current_user ? :to : :from,
      money_direction: requestee == current_user ? :to : :from,
      pending: pending?,
      success: paid? ? 'paid' : nil,
      failure: denied? ? 'denied' : nil,
      target: (sender == current_user ? requestee : sender).name,
      target_type: :bitstation,
      load: Rails.application.routes.url_helpers.money_request_path(self)
    }
  end
end
