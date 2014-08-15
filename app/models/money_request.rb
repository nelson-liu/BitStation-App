class MoneyRequest < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :requestee, class_name: 'User'

  has_one :associated_transaction, class_name: 'Transaction'

  enum status: [:pending, :paid, :denied]
end
