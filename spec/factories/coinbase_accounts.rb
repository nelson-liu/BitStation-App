FactoryGirl.define do
  factory :coinbase_account do
    email { Faker::Internet.email }
    oauth_credentials do
      {
        :token_type=>"bearer",
        :scope=>"balance addresses user transactions",
        :access_token=>"5a02e91e9d10f615f961579547814f118e765a8f052eae8ca2362fc4ad04aff0",
        :refresh_token=>"aa95fe89f85c318b57b93f97a4316d6e6e54ed271ff1ebc58946c2981f89a428",
        :expires_at=>1.day.from_now
      }
    end
  end
end