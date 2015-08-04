require 'securerandom'

FactoryGirl.define do
  factory :user do
    sequence(:kerberos) { |n| "mit#{n}" }
    name { Faker::Name.name }
    auth_token { SecureRandom.hex }

    factory :linked_user do
      association :coinbase_account
    end

    factory :unlinked_user do
      coinbase_account nil
    end
  end
end