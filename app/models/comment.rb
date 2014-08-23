class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :associated_transaction, class_name: 'Transaction'
end
