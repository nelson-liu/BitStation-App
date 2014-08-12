# Preview all emails at http://localhost:3000/rails/mailers/transaction_mailer
class TransactionMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/transaction_mailer/request_money
  def request_money
    TransactionMailer.request_money
  end

end
