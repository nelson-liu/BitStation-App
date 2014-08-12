require 'test_helper'

class TransactionMailerTest < ActionMailer::TestCase
  test "request_money" do
    mail = TransactionMailer.request_money
    assert_equal "Request money", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
