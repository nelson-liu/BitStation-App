# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :note do
    user nil
    associated_transaction nil
    content "MyText"
  end
end
