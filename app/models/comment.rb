class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :associated_transaction, class_name: 'Transaction'

  validates :user, presence: true
  validates :content, length: {minimum: 1}, presence: true
end
