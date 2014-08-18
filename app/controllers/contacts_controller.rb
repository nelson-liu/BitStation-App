class ContactsController < ApplicationController
  before_filter :ensure_signed_in_without_redirect, only: [:index, :create, :show, :create, :delete]
  before_filter :ensure_coinbase_account_linked, only: [:import]
  before_filter :check_for_unlinked_coinbase_account, only: [:index, :show, :create]

  include ActionView::Helpers::TextHelper

  LOAD_CONTACTS_PAGE_LIMIT = 500

  SHOW_CONTACT_RECENT_REQUEST_LIMIT = 10
  SHOW_CONTACT_RECENT_TRANSACTIONS_FETCH_LIMIT = 500
  SHOW_CONTACT_RECENT_TRANSACTIONS_DISPLAY_LIMIT = 10

  def index
    @contacts = current_user.contacts.order('name ASC')

    render layout: false
  end

  def import
    contacts = []

    1.upto(Float::INFINITY) do |p|
      cb_response = current_coinbase_client.transactions(p, limit: LOAD_CONTACTS_PAGE_LIMIT)
      transactions = cb_response['transactions'].map { |t| t['transaction'] }
      coinbase_id = cb_response['current_user']['id']

      break if transactions.empty?

      transactions.each do |t|
        target = t['recipient'] if t['sender'] && t['sender']['id'] == coinbase_id
        target = t['sender'] if t['recipient'] && t['recipient']['id'] == coinbase_id

        next if target.nil?

        name = target['name']
        email = target['email']
        user = CoinbaseAccount.user_with_email(email)

        contacts << {
          address: email,
          name: user ? user.name : name
        }
      end

      break if transactions.count < LOAD_CONTACTS_PAGE_LIMIT
    end

    count = 0

    contacts.uniq! { |c| c[:address] }
    contacts.each do |c|
      next if current_user.contacts.find_by(address: c[:address].to_s)
      current_user.contacts.create!(c)
      count += 1
    end

    redirect_to dashboard_url, flash: {success: "#{pluralize(count, 'contact')} have been imported from Coinbase transaction history. "}
  end

  def new
    render layout: false
  end

  def create
  end

  def show
    @contact = Contact.find(params[:id])

    if @contact && @contact.bitstation?
      @requests = current_user.outgoing_money_requests.where(requestee_id: @contact.to_user.id).to_a + current_user.incoming_money_requests.where(sender_id: @contact.to_user.id).to_a
      @requests.sort_by! { |r| r.created_at }.reverse!
      @requests = @requests.map { |r| r.to_display_data(current_user) }.first(SHOW_CONTACT_RECENT_REQUEST_LIMIT)
    end

    unless @contact.external?
      @transactions = current_coinbase_client.transactions(limit: SHOW_CONTACT_RECENT_TRANSACTIONS_FETCH_LIMIT)
      coinbase_id = @transactions['current_user']['id']
      @transactions = @transactions['transactions'].map { |x| x['transaction'] }

      @transactions.select! do |t|
        puts @contact.email
        ((t['sender']['email'] == @contact.email) rescue false) ||
        ((t['recipient']['email'] == @contact.email) rescue false)
      end
      @transactions = @transactions.first(SHOW_CONTACT_RECENT_TRANSACTIONS_DISPLAY_LIMIT)

      @transactions.map! { |t| Transaction.display_data_from_cb_transaction(t, coinbase_id) }
    end

    render layout: false
  end

  def destroy
    @contact = Contact.find(params[:id])

    @error = nil
    @success = nil

    if @contact
      if @contact.user == current_user
        @contact.destroy!
        @success = "You have successfully deleted #{@contact.name} from your contacts. "
      else
        @error = 'You can only delete your own contact. '
      end
    else
      @error = 'No such contact. '
    end

    respond_to do |format|
      format.js {}
    end
  end
end
