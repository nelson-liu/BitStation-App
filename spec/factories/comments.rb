# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    user ""
    transaction ""
    content "MyText"
  end
end
