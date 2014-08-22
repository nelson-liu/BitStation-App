class Transfer < ActiveRecord::Base
  belongs_to :user
  enum status: [:pending, :completed, :failed]
  enum action: [:buy, :sell]
  validates :amount, numericality: true

end
