# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :money_request do
    sender_id 1
    requestee_id 1
    status 1
    amount "9.99"
    message "MyText"
  end
end
