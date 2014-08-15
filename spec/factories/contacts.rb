# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contact do
    user nil
    name "MyString"
    address "MyString"
    type 1
  end
end
