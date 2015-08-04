require 'rails_helper'

RSpec.describe MoneyRequestsController, :type => :controller do
  context "signed in with user with coinbase account linked" do
    before :each do
      set_user_session (@user_1 = create(:linked_user))
      @user_2 = create(:linked_user)

      allow_any_instance_of(Coinbase::OAuthClient).to receive(:balance).and_return(500.0)
      allow_any_instance_of(Coinbase::OAuthClient).to receive(:spot_price).and_return(500.0)
    end

    describe "POST #create" do
      let (:raw_money_request) { {kerberos: @user_2.kerberos, amount: 1, currency: 'BTC'} }

      context "with AJAX request" do
        let (:money_request) { raw_money_request.merge({format: :js}) }

        context "with valid request" do
          before :each do post :create, money_request end

          it "should return JS matching 'success'" do
            expect(response.content_type).to eq Mime::JS
            expect(assigns(:success)).to_not be_nil
          end
        end

        context "with invalid requests" do
          it "should report error with invalid currency" do
            post :create, money_request.merge(currency: 'WTF')
            expect(assigns(:error)).to match('Invalid currency')
          end

          it "should report error with unknown requestee" do
            post :create, money_request.merge(kerberos: 'nonexist')
            expect(assigns(:error)).to match('requestee hasn\'t joined BitStation yet')
          end

          it "should report error with unlinked requestee" do
            unlinked = create(:unlinked_user)
            post :create, money_request.merge(kerberos: unlinked.kerberos)
            expect(assigns(:error)).to match('requestee hasn\'t linked a Coinbase account yet')
          end

          it "should report error with self-request" do
            post :create, money_request.merge(kerberos: @user_1.kerberos)
            expect(assigns(:error)).to match('Why requesting money from yourself')
          end

          it "should report error without an amount" do
            post :create, money_request.except(:amount)
            expect(assigns(:error)).to match('Invalid request amount')
          end

          it "should report error without a below-minimum amount" do
            post :create, money_request.merge({amount: 0.00001, currency: 'USD'})
            expect(assigns(:error)).to match(/Invalid request amount. The minimum transaction amount is [0-9.]* USD/)
          end

        end
      end
    end
  end
end
