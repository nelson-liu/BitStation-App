require 'rails_helper'
require 'matchers/redirect_to_dashboard_with_error'

RSpec.describe TransactionsController, type: :controller do
  context "signed in with user with coinbase account linked" do
    before :each do
      set_user_session (@user_1 = create(:linked_user))
      @user_2 = create(:linked_user)

      allow_any_instance_of(Coinbase::OAuthClient).to receive(:balance).and_return(500.0)
      allow_any_instance_of(Coinbase::OAuthClient).to receive(:spot_price).and_return(500.0)
    end

    describe "POST #transact" do
      let(:transaction) { {kerberos: @user_2.kerberos, amount: '1', currency: 'BTC'} }

      context "with valid transaction" do
        before :each do post :transact, transaction end

        it "should redirect the user to oauth path" do
          expect(response.location).to match("https://coinbase.com/oauth/authorize")
        end
      end

      context "with invalid transactions" do
        it "should report error an unknown recipient" do
          post :transact, transaction.merge(kerberos: 'nonexist')
          expect(response).to redirect_to_dashboard_with_error('The designated recipient hasn\'t joined BitStation yet.')
        end

        it "should report error without an unknown currency " do
          post :transact, transaction.merge(currency: "WTF")
          expect(response).to redirect_to_dashboard_with_error('Invalid currency')
        end

        it "should report error without an amount" do
          post :transact, transaction.except(:amount)
          expect(response).to redirect_to_dashboard_with_error('Invalid transfer amount')
        end

        it "should report error with invalid BTC address" do
          post :transact, transaction.merge(kerberos: 'a' * 30)
          expect(response).to redirect_to_dashboard_with_error('Invalid BTC address')
        end

        it "should report error with unlinked recipient" do
          unlinked = create(:unlinked_user)
          post :transact, transaction.merge(kerberos: unlinked.kerberos)
          expect(response).to redirect_to_dashboard_with_error('recipient hasn\'t linked a Coinbase account yet')
        end

        it "should report error with below-minimum amount" do
          post :transact, transaction.merge(amount: 0.000001, currency: 'USD')
          expect(response).to redirect_to_dashboard_with_error(/minimum transaction amount is [0-9.]* USD/)
        end

        it "should report error in case of insufficient balance" do
          allow_any_instance_of(Coinbase::OAuthClient).to receive(:balance).and_return(0.5)
          post :transact, transaction
          expect(response).to redirect_to_dashboard_with_error('do not have enough funds')
        end
      end
    end

    describe "POST #request_money" do
      let (:raw_money_request) { {kerberos: @user_2.kerberos, amount: 1, currency: 'BTC'} }

      context "with AJAX request" do
        let (:money_request) { raw_money_request.merge({format: :js}) }

        context "with valid request" do
          before :each do post :request_money, money_request end

          it "should return JS matching 'success'" do
            expect(response.content_type).to eq Mime::JS
            expect(assigns(:success)).to_not be_nil
          end
        end

        context "with invalid requests" do
          it "should report error with invalid currency" do
            post :request_money, money_request.merge(currency: 'WTF')
            expect(assigns(:error)).to match('Invalid currency')
          end

          it "should report error with unknown requestee" do
            post :request_money, money_request.merge(kerberos: 'nonexist')
            expect(assigns(:error)).to match('requestee hasn\'t joined BitStation yet')
          end

          it "should report error with unlinked requestee" do
            unlinked = create(:unlinked_user)
            post :request_money, money_request.merge(kerberos: unlinked.kerberos)
            expect(assigns(:error)).to match('requestee hasn\'t linked a Coinbase account yet')
          end

          it "should report error with self-request" do
            post :request_money, money_request.merge(kerberos: @user_1.kerberos)
            expect(assigns(:error)).to match('Why requesting money from yourself')
          end

          it "should report error without an amount" do
            post :request_money, money_request.except(:amount)
            expect(assigns(:error)).to match('Invalid request amount')
          end

          it "should report error without a below-minimum amount" do
            post :request_money, money_request.merge({amount: 0.00001, currency: 'USD'})
            expect(assigns(:error)).to match(/Invalid request amount. The minimum transaction amount is [0-9.]* USD/)
          end

        end
      end
    end
  end
end