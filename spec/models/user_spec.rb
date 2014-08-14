require 'rails_helper'

RSpec.describe User, type: :model do
  it "has valid factory" do
    expect(build(:user)).to be_valid
  end

  it "has valid linked_user factory" do
    user = build(:linked_user)
    expect(user).to be_valid
    expect(user.coinbase_account).to_not be_nil
    expect(user.coinbase_account).to be_valid
  end
end