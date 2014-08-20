# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transfer do
    amount "9.99"
    coinbase_fee "9.99"
    bank_fee "9.99"
    total_amount "9.99"
    payment_method_id "MyString"
    payment_method_name "MyString"
    action 1
  end
end
