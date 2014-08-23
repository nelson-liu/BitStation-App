class Note < ActiveRecord::Base
  belongs_to :user
  belongs_to :associated_transaction
end
