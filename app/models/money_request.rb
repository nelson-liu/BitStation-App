class MoneyRequest < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :requestee, class_name: 'User'

  enum status: [:pending, :paid, :denied]
end
