class Transfer < ActiveRecord::Base
  belongs_to :user
  enum status: [:pending, :completed, :failed]
  validates :amount, numericality: true

end
